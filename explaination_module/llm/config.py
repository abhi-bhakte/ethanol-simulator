from pathlib import Path
import os

from dotenv import load_dotenv


class Settings:
    def __init__(self) -> None:
        self.root_dir = Path(__file__).resolve().parent
        load_dotenv(self.root_dir / ".env")
        self.ollama_base_url = os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434")
        self.ollama_model = os.getenv("OLLAMA_MODEL", "llama2")
        self.ollama_timeout = int(os.getenv("OLLAMA_TIMEOUT", "180"))
        self.max_tokens = int(os.getenv("LLM_MAX_TOKENS", "700"))
        self.temperature = float(os.getenv("LLM_TEMPERATURE", "0.2"))
        self.top_p = float(os.getenv("LLM_TOP_P", "0.9"))
        self.port = int(os.getenv("LLM_PORT", "8001"))


settings = Settings()
