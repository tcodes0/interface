hardware gpu 48gb x 2

image vllm/vllm-openai:latest

command

poolside/Laguna-S-2.1-INT4 --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.95 --max-num-batched-tokens 8192 --enable-prefix-caching --trust-remote-code
--max-model-len 4096
--tensor-parallel-size 2
--tool-call-parser poolside_v1
--reasoning-parser poolside_v1
--enable-auto-tool-choice
--default-chat-template-kwargs '{"enable_thinking": true}'

disk 5gb

volume 75gb

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
NCCL_P2P_DISABLE=1 # issues with 2 gpus
TORCH_LOGS="+inductor"
TORCHINDUCTOR_CACHE_DIR=/workspace/.cache/torchinductor

temperature 0.7
top_p 0.95

notes:

recommended context 262K, up to 1M with quality loss, see model card for int4 quant
speculative decoding, add flag:
    --speculative-config '{"model":"poolside/Laguna-S-2.1-DFlash-INT4","num_speculative_tokens":15,"method":"dflash"}'
