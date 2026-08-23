hardware A6000 48gb

image vllm/vllm-openai:v0.25.0

command

cyankiwi/Qwen3.6-27B-AWQ-INT4 --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.9 --max-num-batched-tokens 8192 --enable-prefix-caching --trust-remote-code
--max-model-len auto # 262k, up to 500k
--tensor-parallel-size 1
--reasoning-parser qwen3
--enable-auto-tool-choice
--tool-call-parser qwen3_coder
--language-model-only
--kv-cache-dtype fp8
--speculative-config '{"method":"qwen3_next_mtp","num_speculative_tokens":8}'
--enforce-eager # with speculative needs this flag, crashes OOM
--override-generation-config '{"temperature":0.6, "presence_penalty": 1}'

disk 5gb

volume 25gb

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN }}"
HF_HUB_VERBOSITY=info # set to debug if needed
VLLM_LOGGING_LEVEL=info # set to debug if needed
TRANSFORMERS_VERBOSITY=warning # set to debug if needed
XDG_CACHE_HOME=/workspace/.cache
VLLM_CACHE_ROOT=/workspace/.cache/vllm
TORCH_HOME=/workspace/.cache/torch
TRITON_CACHE_DIR=/workspace/.cache/triton
FLASHINFER_WORKSPACE_DIR=/workspace/.cache/flashinfer
# TORCH_LOGS="+inductor" # very verbose omit if not debugging
TORCHINDUCTOR_CACHE_DIR=/workspace/.cache/torchinductor

speculative config:
increasing tokens increases speed directly, too high it crashes

recommended context 262K, up to 1M
<30 tok/s on rtx 4500 blackwell nvfp4 quant
33 tok/s on A40
36 tok/s on A6000
This model is slow without sd, but sd causes OOM's and other crashes, need to run low context.

look into MTP (multi token prediction) vs speculative decoding for moe qwen 3.6, community reports good results. --spec-method mtp --spec-tokens 2 ?