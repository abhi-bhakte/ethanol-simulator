# LLM Interpretation Service (`llm`)

Converts IG fault explanation output into operator-readable text using Ollama-hosted Llama model.

## Prerequisites

- Python environment from `explaination_module/requirements.txt`
- Ollama installed: https://ollama.com/download
- NVIDIA driver/GPU optional (CPU is supported, GPU recommended)

## 1) Start Ollama

```powershell
ollama serve
```

In another terminal, pull the configured model (default `llama2`):

```powershell
ollama pull llama2
```

## 2) Optional model download helper

From `explaination_module`:

```powershell
python -m llm.download_llama2
```

## 3) Run LLM API

From `explaination_module`:

```powershell
uvicorn llm.api_server:app --host 127.0.0.1 --port 8001 --reload
```

## Endpoints

- `GET /` - Service online status
- `GET /health` - Model readiness (`interpreter.is_ready()`)
- `POST /interpret` - Generate operator-facing interpretation

## `/interpret` Request

```json
{
  "process_name": "Ethanol-Water Distillation",
  "process_context": "plant/process context text",
  "ig_result": {
    "fault_name": "Coolant Flow Reduction",
    "top_features": [
      {
        "feature": "Reactor Coolant Flow (F102)",
        "feature_code": "F102_CoolantFlow_Lhr",
        "attribution": -0.72,
        "value": 120.0
      }
    ]
  }
}
```

## Environment Variables

Configured via `llm/.env` (loaded by `llm/config.py`):

- `OLLAMA_BASE_URL` (default `http://127.0.0.1:11434`)
- `OLLAMA_MODEL` (default `llama2`)
- `OLLAMA_TIMEOUT` (default `180`)
- `LLM_MAX_TOKENS` (default `700`)
- `LLM_TEMPERATURE` (default `0.2`)
- `LLM_TOP_P` (default `0.9`)
- `LLM_PORT` (default `8001`)

## March 2026 Documentation Update

- Restored this README after prior deletion.
- Synced endpoint and runtime details with current `llm/api_server.py` and `llm/model_manager.py` implementation.
