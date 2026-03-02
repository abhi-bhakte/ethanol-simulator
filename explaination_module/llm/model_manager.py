import json
from typing import Any, Dict

import requests

from .config import settings
from .prompts import SYSTEM_PROMPT, build_user_prompt


class LlamaInterpreter:
    def __init__(self) -> None:
        self._ready = False

    def load(self) -> None:
        tags_url = f"{settings.ollama_base_url}/api/tags"
        try:
            response = requests.get(tags_url, timeout=settings.ollama_timeout)
            response.raise_for_status()
            data = response.json()
        except Exception as exc:
            raise RuntimeError(
                "Ollama server is not reachable. Start Ollama and run 'ollama serve'."
            ) from exc

        available = {item.get("name", "") for item in data.get("models", [])}
        if settings.ollama_model not in available and f"{settings.ollama_model}:latest" not in available:
            raise RuntimeError(
                f"Model '{settings.ollama_model}' is not available in Ollama. Run download_llama2.py."
            )

        self._ready = True

    def is_ready(self) -> bool:
        return self._ready

    @staticmethod
    def _extract_runtime_context(process_context: str) -> str:
        return process_context.strip()

    def interpret(self, ig_result: Dict[str, Any], process_context: str, process_name: str) -> str:
        if not self._ready:
            raise RuntimeError("Model is not loaded")

        runtime_context = self._extract_runtime_context(process_context)

        prompt = build_user_prompt(
            ig_result=ig_result,
            process_context=runtime_context,
            process_name=process_name,
        )

        print("\n" + "=" * 80)
        print("[LLM INPUT] process_name:")
        print(process_name)
        print("\n[LLM INPUT] process_context:")
        print(runtime_context)
        print("\n[LLM INPUT] ig_result JSON:")
        print(json.dumps(ig_result, ensure_ascii=False, indent=2))
        print("\n[LLM INPUT] final prompt:")
        print(prompt)
        print("=" * 80 + "\n")

        url = f"{settings.ollama_base_url}/api/chat"
        payload = {
            "model": settings.ollama_model,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
            ],
            "stream": False,
            "options": {
                "temperature": settings.temperature,
                "top_p": settings.top_p,
                "num_predict": settings.max_tokens,
            },
        }

        response = requests.post(url, json=payload, timeout=settings.ollama_timeout)
        response.raise_for_status()
        data = response.json()
        text = data["message"]["content"].strip()

        return text
