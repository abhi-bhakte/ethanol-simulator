# Fault Prediction API (Quick Setup)

Use this service when MATLAB calls `utils/predict_fault_api.m`.

## 1) Setup on a new Windows PC

From project root:

```powershell
cd explaination_module
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## 2) Start API

```powershell
python api_server.py
```

API URL: `http://127.0.0.1:5000`

## 3) Verify API

```powershell
Invoke-RestMethod -Method Get -Uri "http://127.0.0.1:5000/health"
```

## 4) If model files are missing

```powershell
python model_training.py
python api_server.py
```

## 5) MATLAB call example

```matlab
vars = [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2];
[label, probs, conf] = predict_fault_api(vars);
```
