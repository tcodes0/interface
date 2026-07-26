hardware gpu 48gb

image vllm/vllm-openai:v0.25.0

command

cyankiwi/Qwen3.6-27B-AWQ-INT4 --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.95 --max-num-batched-tokens 262000 --enable-prefix-caching --trust-remote-code
--max-model-len 4096
--tensor-parallel-size 1
--reasoning-parser qwen3
--enable-auto-tool-choice
--tool-call-parser qwen3_coder
--language-model-only
--kv-cache-dtype fp8

disk 5gb

volume 23gb

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN }}"
HF_HUB_VERBOSITY=debug
VLLM_LOGGING_LEVEL=debug
TRANSFORMERS_VERBOSITY=debug
XDG_CACHE_HOME=/workspace/.cache
VLLM_CACHE_ROOT=/workspace/.cache/vllm
TORCH_HOME=/workspace/.cache/torch
TRITON_CACHE_DIR=/workspace/.cache/triton
FLASHINFER_WORKSPACE_DIR=/workspace/.cache/flashinfer
TORCH_LOGS="+inductor"
TORCHINDUCTOR_CACHE_DIR=/workspace/.cache/torchinductor

speculative config:
--speculative-config '{"method":"qwen3_next_mtp","num_speculative_tokens":2}'

A40 135K context without quant
recommended context 262K, up to 1M