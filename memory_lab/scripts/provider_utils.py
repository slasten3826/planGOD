from __future__ import annotations

import json
import os
import subprocess
import urllib.request
import urllib.error


def ollama_run(model: str, prompt: str) -> str:
    result = subprocess.run(
        ["ollama", "run", model],
        input=prompt,
        text=True,
        capture_output=True,
        encoding="utf-8",
    )
    if result.returncode != 0:
        stderr = result.stderr.strip()
        raise RuntimeError(f"ollama failed ({result.returncode}): {stderr}")
    return result.stdout.strip()


def _http_chat(api_url: str, api_key: str, payload: dict) -> str:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        api_url,
        data=data,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            body = resp.read().decode("utf-8")
            obj = json.loads(body)
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"API ERROR ({e.code}): {body}") from e
    except Exception as e:
        raise RuntimeError(f"NETWORK ERROR: {e}") from e

    try:
        message = obj["choices"][0]["message"]
        content = message.get("content")
        if isinstance(content, str) and content.strip():
            return content.strip()
        reasoning = message.get("reasoning_content")
        finish_reason = obj["choices"][0].get("finish_reason")
        if reasoning and finish_reason == "length":
            raise RuntimeError(
                "GLM returned reasoning only and exhausted max_tokens before final content"
            )
        raise RuntimeError(f"UNEXPECTED FORMAT: {obj}")
    except RuntimeError:
        raise
    except Exception as e:
        raise RuntimeError(f"UNEXPECTED FORMAT: {obj}") from e


def deepseek_run(model: str, prompt: str) -> str:
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if not api_key:
        raise RuntimeError("DEEPSEEK_API_KEY is not set")
    payload = {
        "model": model or "deepseek-chat",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2,
    }
    return _http_chat("https://api.deepseek.com/v1/chat/completions", api_key, payload)


def glm_run(model: str, prompt: str) -> str:
    api_key = os.getenv("MODAL_GLM_API_KEY") or os.getenv("GLM_API_KEY")
    if not api_key:
        raise RuntimeError("MODAL_GLM_API_KEY or GLM_API_KEY is not set")
    payload = {
        "model": model or "zai-org/GLM-5-FP8",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2,
        "max_tokens": int(os.getenv("MEMORY_LAB_GLM_MAX_TOKENS", "1600")),
    }
    return _http_chat("https://api.us-west-2.modal.direct/v1/chat/completions", api_key, payload)


def run_prompt(provider: str, model: str, prompt: str) -> str:
    if provider == "ollama":
        return ollama_run(model, prompt)
    if provider == "deepseek":
        return deepseek_run(model, prompt)
    if provider == "glm":
        return glm_run(model, prompt)
    raise ValueError(f"unknown provider: {provider}")
