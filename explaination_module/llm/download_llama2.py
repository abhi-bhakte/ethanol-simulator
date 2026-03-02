from .config import settings
import shutil
import subprocess


def main() -> None:
    if shutil.which("ollama") is None:
        raise RuntimeError(
            "Ollama CLI is not installed or not on PATH. Install Ollama from https://ollama.com/download"
        )

    print(f"Pulling model '{settings.ollama_model}' from Ollama...")
    result = subprocess.run(
        ["ollama", "pull", settings.ollama_model],
        check=False,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"ollama pull failed:\n{result.stderr}")

    print("Model download complete in Ollama local store")
    print(result.stdout)


if __name__ == "__main__":
    main()
