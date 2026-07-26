hardware gpu 24gb

image vllm/vllm-openai:v0.25.0

command

OBLITERATUS/Qwen3-4B-OBLITERATED --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.93 --tool-call-parser hermes --reasoning-parser qwen3 --enable-auto-tool-choice --max-model-len 150000 --max-num-batched-tokens 8192 --enable-prefix-caching --tensor-parallel-size 1

disk 5gb

volume 10gb

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN }}"
