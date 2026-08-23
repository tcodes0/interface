# links

https://github.com/vllm-project/recipes/blob/main/Qwen/Qwen3.5.md
https://huggingface.co/Qwen/Qwen3.8-27B-FP8

# hardware (vast.ai prices)

- 48GB vram

| gpu count | gpu             | cost $/h |
| --------- | --------------- | -------- |
| 2         | RTX 3090        | 0.3      |
| 2         | RTX PRO 4000 BW | 0.44     |
| 1         | 48 GB RTX 4090  | 0.6      |
| 1         | RTX 6000 Ada    | 0.63     |
| 1         | RTX PRO 5000 BW | 0.74     |

# image

vllm/vllm-openai:v0.27.1

# context is 262k, up to 1M add

--max-model-len 1010000
--hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}'

# no thinking

--default-chat-template-kwargs '{"enable_thinking": false}'

## preserved thinking

not supported well in clients yet, to disable add
--default-chat-template-kwargs '{"preserve_thinking": false}'

# generation config

TEMPERATURE=1.0
TOP_P=0.95
TOP_K=20
MIN_P=0.0
PRESENCE_PENALTY=0.0
REPETITION_PENALTY=1.0

# disk

45Gb (model 31Gb)

# env

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN=***********
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
