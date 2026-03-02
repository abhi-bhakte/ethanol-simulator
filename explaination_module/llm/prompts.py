import json
from typing import Any, Dict


SYSTEM_PROMPT = (
    "You are a chemical plant assistant for Indian diploma-level operators. "
    "Use simple English words and short sentences only. "
    "Use only provided process context and IG data. "
    "If information is missing, say it clearly."
)


def build_user_prompt(ig_result: Dict[str, Any], process_context: str, process_name: str) -> str:
    ig_json = json.dumps(ig_result, indent=2, ensure_ascii=False)
    active_fault = str(ig_result.get("fault_name", "Unknown")).strip()

    return (
        f"Process: {process_name}\n\n"
        "Reference process context:\n"
        f"{process_context}\n\n"
        "Integrated Gradients result (JSON):\n"
        f"{ig_json}\n\n"
        f"Active fault (highest priority): {active_fault}\n"
        "Write in simple operator English.\n"
        "Reasoning priority: active fault first, top_features second, alarm status third.\n"
        "Follow context locality/propagation/fault-map rules.\n"
        "Do not mention causes or variables not supported by top_features.\n"
        "If conflict exists, say uncertainty instead of wrong cause.\n"
        "Return ONLY two clauses separated by ' | ' in this exact format:\n"
        "Effects: <two short sentences> | Corrective action: <two short sentences with valve tag if relevant>\n"
        "Each clause must contain exactly 2 clear sentences (around 10-18 words each).\n"
        "Effects sentence 1: immediate process impact. Effects sentence 2: likely downstream impact.\n"
        "Effects must NOT include action words: adjust, increase, reduce, open, close, monitor, set.\n"
        "Effects must NOT include valve tags (V102, V201, V301, V401).\n"
        "Corrective action must include only operator steps and valve guidance.\n"
        "Example: Effects: Tray profile is disturbed. Product quality may go off-spec. | Corrective action: Adjust V401 stepwise. Monitor T106, T105, and T104 trend.\n"
        "If data is unclear, write: Data is not clear. Watch trend.\n"
        "Both clauses are required. Use only process context, fault_name, top_features, and alarm status. "
        "Do not invent variable directions: if a top variable is decreased, do not say it increased (and vice versa)."
    )
