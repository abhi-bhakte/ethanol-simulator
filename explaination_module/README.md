# Fault Prediction API

Simple REST API for fault prediction in ethanol-water distillation process.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Start the server:
```bash
python api_server.py
```

Server runs on `http://127.0.0.1:5000`

## Usage

### From MATLAB

```matlab
% Make prediction
vars = [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2];
[label, probs, conf] = predict_fault_api(vars);
```

### API Endpoints

**Health Check:**
```
GET http://127.0.0.1:5000/health
```

**Prediction:**
```
POST http://127.0.0.1:5000/predict
Content-Type: application/json

{
  "features": [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2]
}
```

**Response Format:**
```json
{
  "fault_label": 0,
  "probabilities": [0.95, 0.02, ...],
  "confidence": 0.95,
  "explanation": {
    "method": "integrated_gradients",
    "feature_attributions": [...],
    "top_features": [
      {"feature": "F101_FeedFlow_Lhr", "attribution": 0.72, "value": 700},
      {"feature": "T103_CSTRTemp_C", "attribution": 0.55, "value": 30},
      {"feature": "T104_Tray8Temp_C", "attribution": 0.85, "value": 99}
    ],
    "baseline": "mean_of_normal_class"
  },
  "status": "success"
}
```

Note: `top_features` are sorted by **process flow order** (upstream → downstream), not by attribution magnitude.

## Files

- `api_server.py` - FastAPI server
- `model_training.py` - Model training script
- `model_artifacts/` - Trained model files
- `requirements.txt` - Python dependencies

## Notes

- Server must be running for MATLAB to make predictions
- Model loads once at startup for fast predictions
- Returns fault label, probabilities, confidence score, and feature explanations
- **Top features are sorted by process flow order (upstream → downstream)** to reflect physical causality in the system, not just by attribution magnitude
