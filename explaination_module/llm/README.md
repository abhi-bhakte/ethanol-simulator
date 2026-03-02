# LLM Module (Llama 2)

This folder hosts everything related to LLM-based conversion of IG explanations into human-readable operator guidance.

## GPU Setup (Windows, NVIDIA)

This API uses Ollama as the LLM runtime. GPU acceleration is handled by Ollama (not directly by Python code).

### 1) Install prerequisites

- Install/update NVIDIA driver (latest stable)
- Install Ollama for Windows: https://ollama.com/download

### 2) Verify GPU is visible

```powershell
nvidia-smi
```

If this command fails, fix driver/CUDA runtime visibility first.

### 3) Start Ollama and pull model

In terminal A:

```powershell
ollama serve
```

In terminal B:

```powershell
ollama pull llama2
ollama run llama2 "test"
```

### 4) Confirm model is using GPU

```powershell
ollama ps
```

Check the processor/backend column. It should show GPU usage (not CPU-only).

### 5) Run this Python API

```powershell
uvicorn llm.api_server:app --host 127.0.0.1 --port 8001 --reload
```

No extra Python-side GPU flags are required for this LLM path.

### Troubleshooting

- If `ollama ps` shows CPU only, restart Ollama after driver update.
- Ensure no remote desktop/VM limitation is hiding the GPU.
- Re-test with `ollama run llama2 "hello"` before calling `/interpret`.

## 1) Create environment

From `explaination_module`:

```powershell
python -m venv .venv_llm
.\.venv_llm\Scripts\Activate.ps1
pip install -r requirements.txt
```

## 2) Install Ollama (one-time)

Install Ollama for Windows:
- https://ollama.com/download

## 3) Download Llama 2 model

```powershell
python -m llm.download_llama2
```

Or directly:

```powershell
ollama pull llama2
```

## 4) Configure runtime

Copy `.env.example` values into your environment if you want custom settings:
- `OLLAMA_BASE_URL`
- `OLLAMA_MODEL`
- `OLLAMA_TIMEOUT`
- `LLM_MAX_TOKENS`
- `LLM_TEMPERATURE`
- `LLM_TOP_P`
- `LLM_PORT`

## 5) Run API

Ensure Ollama service is running (`ollama serve`) in another terminal, then:

```powershell
uvicorn llm.api_server:app --host 127.0.0.1 --port 8001 --reload
```

## 6) Test API

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://127.0.0.1:8001/interpret" `
  -ContentType "application/json" `
  -InFile "llm/sample_interpret_request.json"
```

## Endpoints

- `GET /` : service status
- `GET /health` : model readiness
- `POST /interpret` : convert IG result into operator-readable explanation

## Input contract for `/interpret`

- `process_name` (string)
- `process_context` (string)
- `ig_result` (JSON object, can include `fault_label`, `confidence`, `top_features`, etc.)

## Notes

- Keep process context factual and plant-specific to reduce hallucinations.
- You can maintain reference text in `process_context_template.md` and pass selected sections per request.
- This backend avoids `llama-cpp-python` build errors on Windows.
