# links

https://github.com/vllm-project/recipes/blob/main/Qwen/Qwen3.5.md
https://huggingface.co/Qwen/Qwen3.8-27B-FP8

# hardware (vast.ai prices)

| num | gpu             | cost $/h | vram |
| --- | --------------- | -------- | ---- |
| 2   | RTX 3090        | 0.3      | 48   |
| 2   | RTX PRO 4000 BW | 0.44     | 48   |
| 1   | 48 GB RTX 4090  | 0.6      | 48   |
| 1   | RTX 6000 Ada    | 0.63     | 48   |
| 1   | RTX PRO 5000 BW | 0.74     | 48   |

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

## per request tuning

add to litellm JSON params

"extra_body": {
"chat_template_kwargs": {
"enable_thinking": false,
"preserve_thinking": false
}
}

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

# benchmarks

```
vllm bench serve \
  --base-url http://127.0.0.1:8000 \
  --model Qwen/Qwen3.8-27B-FP8 \
  --num-prompts 20 \
  --random-input-len 4096 \
  --random-output-len 1024 \
  --max-concurrency 1 \
  --header "Authorization=Bearer $VLLM_API_KEY" \
  --temperature 1.0 \
  --top-p 0.95 \
  --top-k 20
```

## 2 RTX PRO 4000

MTP tokens = 3
2 and 4 also tested, 3 seemed better

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  309.35
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.06
Output token throughput (tok/s):         66.20
Peak output token throughput (tok/s):    25.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          331.02
---------------Time to First Token----------------
Mean TTFT (ms):                          2522.55
Median TTFT (ms):                        2795.87
P99 TTFT (ms):                           2798.58
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          12.65
Median TPOT (ms):                        11.90
P99 TPOT (ms):                           17.05
---------------Inter-token Latency----------------
Mean ITL (ms):                           40.50
Median ITL (ms):                         40.50
P99 ITL (ms):                            41.16
---------------Speculative Decoding---------------
Acceptance rate (%):                     73.47
Acceptance length:                       3.20
Drafts:                                  6393
Draft tokens:                            19179
Accepted tokens:                         14090
Per-position acceptance (%):
  Position 0:                            83.42
  Position 1:                            72.91
  Position 2:                            64.07
==================================================
```
