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
import pathlib
from typing import List, Dict, Optional

import joblib
import numpy as np
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


@app.on_event("startup")
async def load_model():
    """Load model artifacts and initialize explainer at server startup"""
    global MODEL, SCALER, INDEX_TO_LABEL, EXPLAINER, BASELINE
    
    try:
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
        BASELINE = tf.constant(baseline_array, dtype=tf.float64)
        
        print(f"✓ Baseline loaded from {BASELINE_PATH}")
        print(f"  Baseline type: mean of normal class (scaled)")
        
        # Initialize Integrated Gradients explainer
        EXPLAINER = IntegratedGradients(
            model=MODEL,
            baseline=BASELINE,
            m_steps=50,
            batch_size=32
        )
        
        print(f"✓ Integrated Gradients explainer initialized (m_steps=50)")
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
        x = np.array(request.features, dtype=float).reshape(1, -1)
        x_scaled = SCALER.transform(x)
        x_scaled_tensor = tf.constant(x_scaled[0], dtype=tf.float64)
        
        # Predict
        probs = MODEL.predict(x_scaled, verbose=0)[0]
        pred_index = int(np.argmax(probs))
        pred_label = int(INDEX_TO_LABEL[pred_index])
        confidence = float(probs[pred_index])
        probs_list = [float(p) for p in probs]
        
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
        
        # Get top 3 features by importance, then sort ONLY those 3 by process flow
        top_3_by_importance = feature_importance_sorted[:3]
        top_3_by_flow = sort_features_by_process_flow(top_3_by_importance)
        
        # Build explanation object
        explanation = {
            "method": "integrated_gradients",
            "feature_attributions": feature_importance,
            "top_features": top_3_by_flow,  # Top 3 sorted by process flow
            "baseline": "mean_of_normal_class"
        }
        
        # Debug logging
        print(f"[INFO] Prediction: {pred_label} | Confidence: {confidence:.3f}")
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
        app,
        host="127.0.0.1",
        port=5000,
        log_level="info"
    )
