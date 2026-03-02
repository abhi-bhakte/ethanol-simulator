from typing import Any, Dict

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import uvicorn

from .config import settings
from .model_manager import LlamaInterpreter


app = FastAPI(
    title="LLM IG Interpretation API",
    description="Converts IG explanation output to human-readable process guidance using Llama 2",
    version="1.0.0",
)

interpreter = LlamaInterpreter()


class InterpretRequest(BaseModel):
    process_name: str = Field(default="Ethanol-Water Distillation")
    process_context: str
    ig_result: Dict[str, Any]


class InterpretResponse(BaseModel):
    interpretation: str
    model_name: str = "Llama-2-7B-Chat-GGUF"
    status: str = "success"


@app.on_event("startup")
async def startup_event() -> None:
    try:
        interpreter.load()
    except Exception as exc:
        print(f"Failed to load model: {exc}")


@app.get("/")
async def root() -> Dict[str, str]:
    return {"service": "LLM IG Interpretation API", "status": "online"}


@app.get("/health")
async def health() -> Dict[str, Any]:
    return {"ready": interpreter.is_ready()}


@app.post("/interpret", response_model=InterpretResponse)
async def interpret(request: InterpretRequest) -> InterpretResponse:
    if not interpreter.is_ready():
        raise HTTPException(status_code=503, detail="Llama model not loaded")

    try:
        text = interpreter.interpret(
            ig_result=request.ig_result,
            process_context=request.process_context,
            process_name=request.process_name,
        )
        return InterpretResponse(interpretation=text)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


if __name__ == "__main__":
    uvicorn.run("llm.api_server:app", host="127.0.0.1", port=settings.port, reload=True)
