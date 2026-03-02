"""
FastAPI server for fault prediction
Provides REST API endpoint for MATLAB to call for predictions

Important Note on Feature Ordering:
    When displaying top contributing features in results, they are sorted according
    to the process flow order (upstream → downstream) rather than by attribution
    magnitude alone. This reflects the physical causality in the ethanol production
    system where upstream variables affect downstream ones.
    
    Process Flow Sequence:
        F101_FeedFlow_Lhr → F102_CoolantFlow_Lhr / T101_CoolantTemp_C (parallel) →
        T102_JacketTemp_C → T103_CSTRTemp_C → C101_EthanolConc_molL →
        L101_CSTRLevel_m → F105_DistillFlow_Lhr → T106_Tray3Temp_C →
        T105_Tray5Temp_C → T104_Tray8Temp_C
"""
import os
import pathlib
import json
from typing import List, Dict, Optional

import joblib
import numpy as np
import requests
import tensorflow as tf
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

from ig import IntegratedGradients

# Path configuration
ARTIFACT_DIR = pathlib.Path(__file__).resolve().parent / "model_artifacts"
MODEL_PATH = ARTIFACT_DIR / "fault_fnn.keras"
SCALER_PATH = ARTIFACT_DIR / "scaler.joblib"
LABEL_MAP_PATH = ARTIFACT_DIR / "label_map.joblib"
BASELINE_PATH = ARTIFACT_DIR / "baseline.joblib"

# Optional LLM interpretation service configuration
LLM_INTERPRET_URL = os.getenv("LLM_INTERPRET_URL", "http://127.0.0.1:8001/interpret")
LLM_TIMEOUT_SECONDS = int(os.getenv("LLM_TIMEOUT_SECONDS", "8"))
DEFAULT_PROCESS_NAME = "Ethanol-Water Distillation"
DEFAULT_PROCESS_CONTEXT = (
    "Plant context: CSTR reactor followed by distillation column. "
    "Main process direction is reactor to distillation.\n"
    "Variable order: F101,F102,T101,T102,T103,C101,L101,F105,T106,T105,T104.\n"
    "Reactor-side variables: F101,F102,T101,T102,T103,C101,L101. "
    "Column-side variables: F105,T106,T105,T104,reflux(V401).\n"
    "Locality rule: first explain the unit where top features are present. "
    "Do not claim reactor feed cause if evidence is only tray/reflux variables.\n"
    "Propagation rule: downstream impact can be mentioned only when upstream variables also show deviation. "
    "Do not force upstream causes from downstream-only evidence.\n"
    "Feed behavior: F101/F105 down can reduce throughput and upset composition/separation. "
    "F101/F105 up can increase loading and control difficulty.\n"
    "Cooling behavior: F102 down or T102/T103 up indicates weaker cooling and hot-reactor risk. "
    "F102 up or T102/T103 down indicates stronger cooling and cold-reactor risk.\n"
    "Reflux behavior: use T106/T105/T104 as primary indicators. "
    "High reflux typically raises tray temperatures and shifts profile; low reflux typically lowers tray temperatures and shifts profile. "
    "For reflux faults, keep effects in distillation unit unless reactor variables are also top features.\n"
    "Fault map: Reflux Valve Set High/Low -> column tray-profile and separation effects first. "
    "Coolant faults -> reactor thermal effects first. Feed faults -> throughput/loading/composition effects first.\n"
    "Action map: feed->V102, coolant->V301, distillation feed->V201, reflux->V401.\n"
    "Effects text must contain plant impact only and must not include action verbs or valve tags. "
    "Corrective action must contain operator steps only and may include valve tags.\n"
    "If evidence is mixed, state uncertainty and ask operator to watch trend."
)

# Integrated Gradients performance tuning
IG_M_STEPS = int(os.getenv("IG_M_STEPS", "20"))
IG_BATCH_SIZE = int(os.getenv("IG_BATCH_SIZE", "32"))

# Feature names for interpretability
FEATURE_NAMES = [
    "F101_FeedFlow_Lhr",
    "F102_CoolantFlow_Lhr",
    "T101_CoolantTemp_C",
    "T102_JacketTemp_C",
    "F105_DistillFlow_Lhr",
    "T106_Tray3Temp_C",
    "T105_Tray5Temp_C",
    "T104_Tray8Temp_C",
    "T103_CSTRTemp_C",
    "C101_EthanolConc_molL",
    "L101_CSTRLevel_m"
]

FEATURE_DISPLAY_NAMES = {
    "F101_FeedFlow_Lhr": "Reactor Feed Flow (F101)",
    "F102_CoolantFlow_Lhr": "Reactor Coolant Flow (F102)",
    "T101_CoolantTemp_C": "Reactor Coolant Temperature (T101)",
    "T102_JacketTemp_C": "Reactor Jacket Temperature (T102)",
    "T103_CSTRTemp_C": "Reactor Temperature (T103)",
    "C101_EthanolConc_molL": "Reactor Concentration (C101)",
    "L101_CSTRLevel_m": "Reactor Level (L101)",
    "F105_DistillFlow_Lhr": "Distillation Feed Flow (F105)",
    "T106_Tray3Temp_C": "Tray 3 Temperature (T106)",
    "T105_Tray5Temp_C": "Tray 5 Temperature (T105)",
    "T104_Tray8Temp_C": "Tray 8 Temperature (T104)",
}

FAULT_NAMES = [
    "Normal Operation",           # 0
    "Feed Flow Reduction",        # 1
    "Reaction Rate Change",       # 2
    "Coolant Flow Reduction",     # 3
    "Distillation Flow Reduction",# 4
    "Reflux Valve Set High",      # 5
    "Reboiler Power Reduction",   # 6
    "Feed Flow Increase",         # 7
    "Coolant Flow Increase",      # 8
    "Distillation Feed Valve Stuck",# 9
    "Reflux Valve Set Low",       # 10
    "Feed Flow Leakage",          # 11
    "Coolant Flow Leakage",       # 12
]


def display_feature_name(feature_code: str) -> str:
    return FEATURE_DISPLAY_NAMES.get(feature_code, feature_code)


def fault_name_from_label(label: int) -> str:
    if 0 <= label < len(FAULT_NAMES):
        return FAULT_NAMES[label]
    return "Unknown"

# Process flow order (upstream to downstream) for sorting results
# This represents the physical causality in the ethanol production system
PROCESS_FLOW_ORDER = [
    "F101_FeedFlow_Lhr",        # Feed inlet
    "F102_CoolantFlow_Lhr",     # Coolant inlet (parallel with T101)
    "T101_CoolantTemp_C",       # Coolant temperature (parallel with F102)
    "T102_JacketTemp_C",        # Jacket temperature
    "T103_CSTRTemp_C",          # CSTR reactor temperature
    "C101_EthanolConc_molL",    # Ethanol concentration
    "L101_CSTRLevel_m",         # CSTR level
    "F105_DistillFlow_Lhr",     # Distillation column flow
    "T106_Tray3Temp_C",         # Tray 3 temperature
    "T105_Tray5Temp_C",         # Tray 5 temperature
    "T104_Tray8Temp_C"          # Tray 8 temperature (bottom)
]

def sort_features_by_process_flow(features_list):
    """
    Sort features according to process flow order (upstream to downstream).
    
    This ensures that when displaying top features, they appear in the order
    that reflects the physical causality of the process, where upstream
    variables affect downstream ones.
    
    Args:
        features_list: List of feature dictionaries with 'feature' key
        
    Returns:
        Sorted list maintaining process flow sequence
    """
    # Create a mapping of feature name to its position in process flow
    flow_position = {name: idx for idx, name in enumerate(PROCESS_FLOW_ORDER)}
    
    # Sort by process flow order (lower index = more upstream)
    return sorted(features_list, key=lambda x: flow_position.get(x['feature'], 999))

# Initialize FastAPI app
app = FastAPI(
    title="Fault Prediction API",
    description="API for predicting faults in ethanol-water distillation process",
    version="1.0.0"
)

# Enable CORS for local access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model storage (loaded once at startup)
MODEL = None
SCALER = None
INDEX_TO_LABEL = None
EXPLAINER = None
BASELINE = None


class PredictionRequest(BaseModel):
    """Request model for prediction"""
    features: List[float]
    include_llm: bool = False
    include_ig: bool = True
    process_context: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "features": [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2]
            }
        }


class PredictionResponse(BaseModel):
    """Response model for prediction with explanation"""
    fault_label: int
    probabilities: List[float]
    confidence: float
    explanation: Dict
    status: str = "success"


def get_llm_interpretation(ig_result: Dict, process_context: Optional[str] = None) -> Dict[str, Optional[str]]:
    """
    Call LLM interpretation API and return a normalized status payload.

    Returns:
        {
            "llm_interpretation": <str|None>,
            "llm_status": "success"|"unavailable"|"error",
            "llm_error": <str|None>
        }
    """
    payload = {
        "process_name": DEFAULT_PROCESS_NAME,
        "process_context": process_context or DEFAULT_PROCESS_CONTEXT,
        "ig_result": ig_result,
    }

    try:
        print("[LLM] Requesting interpretation...")
        response = requests.post(LLM_INTERPRET_URL, json=payload, timeout=LLM_TIMEOUT_SECONDS)
        response.raise_for_status()
        data = response.json()
        print("[LLM] Raw response JSON:")
        print(json.dumps(data, ensure_ascii=True, indent=2))
        print("[LLM] Interpretation text:")
        print(data.get("interpretation", "").strip())
        return {
            "llm_interpretation": data.get("interpretation", "").strip(),
            "llm_status": "success",
            "llm_error": None,
        }
    except requests.RequestException as exc:
        return {
            "llm_interpretation": None,
            "llm_status": "unavailable",
            "llm_error": str(exc),
        }
    except Exception as exc:
        return {
            "llm_interpretation": None,
            "llm_status": "error",
            "llm_error": str(exc),
        }


@app.on_event("startup")
async def load_model():
    """Load model artifacts and initialize explainer at server startup"""
    global MODEL, SCALER, INDEX_TO_LABEL, EXPLAINER, BASELINE
    
    try:
        # Prefer non-allocating GPU behavior (prevents large initial GPU reservation)
        try:
            gpus = tf.config.list_physical_devices("GPU")
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            if gpus:
                print(f"✓ TensorFlow GPU devices detected: {len(gpus)}")
            else:
                print("[WARN] No TensorFlow GPU devices detected (running on CPU)")
        except Exception as gpu_exc:
            print(f"[WARN] Could not configure TensorFlow GPU settings: {gpu_exc}")

        print("Loading model artifacts...")
        MODEL = tf.keras.models.load_model(MODEL_PATH)
        SCALER = joblib.load(SCALER_PATH)
        
        label_to_index = joblib.load(LABEL_MAP_PATH)
        INDEX_TO_LABEL = {idx: label for label, idx in label_to_index.items()}
        
        print(f"✓ Model loaded from {MODEL_PATH}")
        print(f"✓ Scaler loaded from {SCALER_PATH}")
        print(f"✓ Label mapping loaded: {len(INDEX_TO_LABEL)} classes")
        print(f"✓ INDEX_TO_LABEL mapping: {INDEX_TO_LABEL}")
        
        # Load baseline from artifact (mean of normal class samples)
        baseline_array = joblib.load(BASELINE_PATH)
        BASELINE = tf.constant(baseline_array, dtype=tf.float32)
        
        print(f"✓ Baseline loaded from {BASELINE_PATH}")
        print(f"  Baseline type: mean of normal class (scaled)")
        
        # Initialize Integrated Gradients explainer
        EXPLAINER = IntegratedGradients(
            model=MODEL,
            baseline=BASELINE,
            m_steps=IG_M_STEPS,
            batch_size=IG_BATCH_SIZE
        )
        
        print(f"✓ Integrated Gradients explainer initialized (m_steps={IG_M_STEPS}, batch_size={IG_BATCH_SIZE})")
        # Warm-up to reduce first-request latency spikes
        try:
            _warm = np.zeros((1, 11), dtype=np.float32)
            _ = MODEL.predict(_warm, verbose=0)
            print("✓ Model warm-up inference completed")
        except Exception as warm_exc:
            print(f"[WARN] Warm-up inference failed: {warm_exc}")

        print("Server ready for predictions with explanations!")
    except Exception as e:
        print(f"ERROR loading model: {e}")
        raise


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "Fault Prediction API",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    model_loaded = MODEL is not None
    scaler_loaded = SCALER is not None
    
    return {
        "status": "healthy" if model_loaded and scaler_loaded else "unhealthy",
        "model_loaded": model_loaded,
        "scaler_loaded": scaler_loaded,
        "num_classes": len(INDEX_TO_LABEL) if INDEX_TO_LABEL else 0
    }


@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Predict fault from process variables with integrated gradients explanation.
    
    Expected 11 features in order:
    1. F101_FeedFlow_Lhr
    2. F102_CoolantFlow_Lhr
    3. T101_CoolantTemp_C
    4. T102_JacketTemp_C
    5. F105_DistillFlow_Lhr
    6. T106_Tray3Temp_C
    7. T105_Tray5Temp_C
    8. T104_Tray8Temp_C
    9. T103_CSTRTemp_C
    10. C101_EthanolConc_molL
    11. L101_CSTRLevel_m
    
    Returns prediction with feature attribution explanations.
    """
    if MODEL is None or SCALER is None or EXPLAINER is None:
        raise HTTPException(status_code=503, detail="Model or explainer not loaded")
    
    if len(request.features) != 11:
        raise HTTPException(
            status_code=400,
            detail=f"Expected 11 features, got {len(request.features)}"
        )
    
    try:
        # Prepare input
        x = np.array(request.features, dtype=np.float32).reshape(1, -1)
        x_scaled = SCALER.transform(x).astype(np.float32)
        x_scaled_tensor = tf.constant(x_scaled[0], dtype=tf.float32)
        
        # Predict
        probs = MODEL.predict(x_scaled, verbose=0)[0]
        pred_index = int(np.argmax(probs))
        pred_label = int(INDEX_TO_LABEL[pred_index])
        confidence = float(probs[pred_index])
        probs_list = [float(p) for p in probs]
        
        top_3_by_importance = []
        top_3_by_flow = []

        if request.include_ig:
            # Compute explanation using predicted class
            ig_attributions, _, _ = EXPLAINER.explain(
                sample=x_scaled_tensor,
                target_class_idx=pred_index
            )

            # Convert to numpy and extract feature attributions
            attributions = ig_attributions.numpy()

            # Create feature importance ranking
            feature_importance = [
                {
                    "feature": FEATURE_NAMES[i],
                    "attribution": float(attributions[i]),
                    "value": float(request.features[i])
                }
                for i in range(len(FEATURE_NAMES))
            ]

            # Sort by absolute attribution (most important first)
            feature_importance_sorted = sorted(
                feature_importance,
                key=lambda x: abs(x["attribution"]),
                reverse=True
            )

            # Get top 3 by importance, then drop weak consecutive features (<25% rule)
            top_3_candidates = feature_importance_sorted[:3]
            top_3_by_importance = []
            if top_3_candidates:
                top_3_by_importance.append(top_3_candidates[0])
                if len(top_3_candidates) >= 2:
                    first_abs = abs(top_3_candidates[0]["attribution"])
                    second_abs = abs(top_3_candidates[1]["attribution"])
                    if first_abs > 0 and (second_abs / first_abs) >= 0.25:
                        top_3_by_importance.append(top_3_candidates[1])
                        if len(top_3_candidates) >= 3:
                            third_abs = abs(top_3_candidates[2]["attribution"])
                            if second_abs > 0 and (third_abs / second_abs) >= 0.25:
                                top_3_by_importance.append(top_3_candidates[2])
            top_3_by_flow = sort_features_by_process_flow(top_3_by_importance)

            # Build explanation object
            explanation = {
                "method": "integrated_gradients",
                "feature_attributions": feature_importance,
                "top_features": top_3_by_flow,  # Top 3 sorted by process flow
                "baseline": "mean_of_normal_class"
            }
        else:
            explanation = {
                "method": "none",
                "feature_attributions": [],
                "top_features": [],
                "baseline": "mean_of_normal_class"
            }

        # Optional LLM-based operator-friendly interpretation
        if request.include_llm and request.include_ig:
            top_3_by_flow_display = [
                {
                    "feature": display_feature_name(item["feature"]),
                    "feature_code": item["feature"],
                    "attribution": item["attribution"],
                    "value": item["value"],
                }
                for item in top_3_by_flow
            ]

            llm_input = {
                "fault_name": fault_name_from_label(pred_label),
                "top_features": top_3_by_flow_display,
            }
            llm_result = get_llm_interpretation(
                ig_result=llm_input,
                process_context=request.process_context,
            )
            explanation["llm_status"] = llm_result["llm_status"]
            if llm_result["llm_interpretation"]:
                explanation["llm_interpretation"] = llm_result["llm_interpretation"]
            if llm_result["llm_error"]:
                explanation["llm_error"] = llm_result["llm_error"]
        elif request.include_llm and not request.include_ig:
            explanation["llm_status"] = "skipped"
            explanation["llm_error"] = "LLM requested but include_ig=false (no IG context to interpret)."
        
        # Debug logging
        print(f"[INFO] Prediction: {pred_label} | Confidence: {confidence:.3f}")
        if request.include_ig:
            print(f"[INFO] Top 3 features (by importance): {[f['feature'] for f in top_3_by_importance]}")
            print(f"[INFO] Top 3 features (by process flow): {[f['feature'] for f in top_3_by_flow]}")
        
        return PredictionResponse(
            fault_label=pred_label,
            probabilities=probs_list,
            confidence=confidence,
            explanation=explanation,
            status="success"
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


if __name__ == "__main__":
    print("Starting Fault Prediction API Server...")
    print("=" * 60)
    uvicorn.run(
        "api_server:app",
        host="127.0.0.1",
        port=5000,
        log_level="info",
        reload=True
    )
