links
https://github.com/vllm-project/recipes/blob/main/Qwen/Qwen3.5.md
https://huggingface.co/Qwen/Qwen3.8-27B-FP8

hardware (vast.ai prices)
- 48GB vram
- 1 gpu: 48 GB RTX 4090 mod 0.6/h, RTX 6000 Ada 0.63/h, RTX PRO 5000 Blackwell 0.74/h
- 2 gpu: RTX 3090 0.3/h, RTX PRO 4000 BW 0.44/h

image vllm/vllm-openai:v0.27.1

command

 <!-- vllm serve -->
Qwen/Qwen3.8-27B-FP8 --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.9 --max-num-batched-tokens 2048 --enable-prefix-caching --trust-remote-code
--max-model-len auto # 262k, up to 1M
--tensor-parallel-size 2
--reasoning-parser qwen3
--enable-auto-tool-choice
--tool-call-parser qwen3_coder
--language-model-only
--kv-cache-dtype fp8
--speculative-config '{"method":"qwen3_5_mtp","num_speculative_tokens":2}'
--override-generation-config '{"temperature":1.0, "top_p":0.95, "top_k":20, "min_p":0.0, "presence_penalty":0.0, "repetition_penalty":1.0}'
--default-chat-template-kwargs '{"preserve_thinking": false}' # not supported well in clients yet

1M context add

--max-model-len 1010000
--hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}'

no thinking
--default-chat-template-kwargs '{"enable_thinking": false}'

disk 45Gb (model 31Gb)

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
HF_TOKEN=***********
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

--host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.9 --max-num-batched-tokens 2048 --enable-prefix-caching --trust-remote-code --max-model-len auto --tensor-parallel-size 2 --reasoning-parser qwen3 --enable-auto-tool-choice
--tool-call-parser qwen3_coder --language-model-only --kv-cache-dtype fp8 --speculative-config '{\"method\":\"qwen3_5_mtp\",\"num_speculative_tokens\":2}' --override-generation-config '{\"temperature\":1.0, \"top_p\":0.95, \"top_k\":20, \"min_p\":0.0, \"presence_penalty\":0.0, \"repetition_penalty\":1.0}' --default-chat-template-kwargs '{\"preserve_thinking\": false}'