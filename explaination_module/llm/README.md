# LLM Module (Optional, Quick Setup)

Use this only if you need natural-language interpretation from IG outputs.

## 1) Python environment

From project root:

```powershell
cd explaination_module
python -m venv .venv_llm
.\.venv_llm\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## 2) Install Ollama (one-time)

Download and install: https://ollama.com/download

## 3) Start Ollama and pull model

Terminal A:

```powershell
ollama serve
```

Terminal B:

```powershell
ollama pull llama2
ollama run llama2 "test"
```

## 4) Start LLM API

```powershell
uvicorn llm.api_server:app --host 127.0.0.1 --port 8001 --reload
```

## 5) Test endpoint

```powershell
Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:8001/interpret" -ContentType "application/json" -InFile "llm/sample_interpret_request.json"
```
