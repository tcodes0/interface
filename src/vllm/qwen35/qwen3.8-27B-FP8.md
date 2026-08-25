# links

https://github.com/vllm-project/recipes/blob/main/Qwen/Qwen3.5.md
https://huggingface.co/Qwen/Qwen3.8-27B-FP8

# hardware

48GB, gives around 160K context.

# image

vllm/vllm-openai:v0.27.1

# long context

default is 262k

--max-model-len 1010000
--hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}'

524000, update factor to 2.0. Keep other params the same, They are architectural.

# no thinking

--default-chat-template-kwargs '{"enable_thinking": false}'

## preserved thinking

keep preserve thinking off unless your client supports it, otherwise turn it on.
--default-chat-template-kwargs '{"preserve_thinking": false}'

## thinking tuning per request

add to litellm JSON params

```
# control thinking on/off
"extra_body": {
    "chat_template_kwargs": {
    "enable_thinking": false,
    "preserve_thinking": false
    }
}
```

```
# how much thinking. Setting a max helps with overall control, but not required.
"max_tokens": 16384,
"extra_body": {
  "thinking_token_budget": 10000
}
```

# default generation config

TEMPERATURE=1.0
TOP_P=0.95
TOP_K=20
MIN_P=0.0
PRESENCE_PENALTY=0.0
REPETITION_PENALTY=1.0

## ideas to tweak

A — current
T=1.0, top_p=.95, top_k=20, min_p=0

B — more deterministic
T=.8,  top_p=.95, top_k=20, min_p=0

C — focused
T=.8,  top_p=.95, top_k=20, min_p=.05

# disk

45Gb (model 31Gb)

# env

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=0
HF_TOKEN=****\*\*\*****
XDG_CACHE_HOME=/workspace/.cache
VLLM_CACHE_ROOT=/workspace/.cache/vllm
TORCH_HOME=/workspace/.cache/torch
TRITON_CACHE_DIR=/workspace/.cache/triton
FLASHINFER_WORKSPACE_DIR=/workspace/.cache/flashinfer
TORCHINDUCTOR_CACHE_DIR=/workspace/.cache/torchinductor

> set to debug if needed

HF_HUB_VERBOSITY=info
VLLM_LOGGING_LEVEL=info
TRANSFORMERS_VERBOSITY=info

> very verbose omit if not debugging

TORCH_LOGS="+inductor"
