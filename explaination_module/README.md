# Fault Prediction API (explaination_module)

FastAPI service for fault prediction in the ethanol-water simulator, with Integrated Gradients (IG) explanations and optional LLM interpretation.

## Current Module Layout

- `api_server.py` - Main prediction API (`/predict`)
- `ig.py` - Integrated Gradients implementation
- `model_training.py` - Model training script
- `model_artifacts/` - Saved model/scaler/label-map/baseline
- `llm/` - Optional LLM interpretation microservice
- `llm_async/` - Reserved placeholder (currently empty)
- `requirements.txt` - Pinned Python dependencies

## Setup

From `ethanol-simulator/explaination_module`:

```powershell
py -3.11 -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## Run the Prediction API

```powershell
python api_server.py
```

Server starts at `http://127.0.0.1:5000` (reload enabled).

## Endpoints

- `GET /` - Service status
- `GET /health` - Model/scaler readiness
- `POST /predict` - Fault prediction + explanation

## `/predict` Request

```json
{
  "features": [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2],
  "include_ig": true,
  "include_llm": false,
  "process_context": "optional custom process context"
}
```

Notes:
- `features` must contain exactly 11 values.
- `include_ig` defaults to `true`.
- `include_llm` defaults to `false`.
- If `include_llm=true`, this API calls `LLM_INTERPRET_URL` (default: `http://127.0.0.1:8001/interpret`).

## March 2026 Documentation Update

- Restored this README after prior deletion.
- Requirements are currently pinned from local environment (`pip freeze`).
- Consolidated and synced documentation with current API behavior (`include_llm`, `include_ig`, process-flow-sorted top features).
