hardware 2x A40 ampere 48gb each, 96gb total

image vllm/vllm-openai:v0.26.0

command

poolside/Laguna-S-2.1-INT4 --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.94 --max-num-batched-tokens 4096 --trust-remote-code --max-num-seqs 1
--max-model-len 300000
--tensor-parallel-size 2
--tool-call-parser poolside_v1
--reasoning-parser poolside_v1
--enable-auto-tool-choice
--default-chat-template-kwargs '{"enable_thinking": true}'
--safetensors-load-strategy=prefetch
--compilation-config '{"pass_config":{"fuse_norm_quant":false}}' # simple compilation, reduces performance
--override-generation-config '{"temperature":0.7,"top_p":0.95,"top_k":20}'
--disable-custom-all-reduce

disk 5gb

volume 75gb

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN }}"
HF_HUB_VERBOSITY=info # change to debug if needed
VLLM_LOGGING_LEVEL=info # change to debug if needed
TRANSFORMERS_VERBOSITY=warning # change to debug if needed
XDG_CACHE_HOME=/workspace/.cache
VLLM_CACHE_ROOT=/workspace/.cache/vllm
TORCH_HOME=/workspace/.cache/torch
TRITON_CACHE_DIR=/workspace/.cache/triton
FLASHINFER_WORKSPACE_DIR=/workspace/.cache/flashinfer
NCCL_P2P_DISABLE=1 # issues with 2 gpus
NCCL_PROTO=Simple # robust but might add latency
TORCH_LOGS=+inductor # very verbose use only for debug
TORCHINDUCTOR_CACHE_DIR=/workspace/.cache/torchinductor
PYTORCH_ALLOC_CONF="expandable_segments:True"

notes:

recommended context 262K, up to 1M with quality loss, see model card for int4 quant
speculative decoding, add flag:
--speculative-config '{"model":"poolside/Laguna-S-2.1-DFlash-INT4","num_speculative_tokens":15,"method":"dflash"}'

perf:

57-60 tok/s 181K context 0.9 gpu
57-60 tok/s 500K context 0.94 gpu
65 tok/s 300K context 0.94 gpu spec decode

extra docker args:
--gpus all --cap-add=SYS_PTRACE --cap-add=SYS_RESOURCE --security-opt seccomp=unconfined --ulimit memlock=-1
--ulimitcore=-1 --shm-size=16g --ipc=host
