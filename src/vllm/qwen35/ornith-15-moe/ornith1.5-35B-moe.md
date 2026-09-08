# ornith-ai/Ornith-1.5-35B-A3B-FP8

https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-FP8

## links

for a more performant MTP use shisa-ai/Ornith-1.5-35B-A3B-MTP-FP8
OOM easily on 64Gb, fits with MTP off (lol)

## hardware

48GB minimum
2x 5090 recommended

## image

ghcr.io/rthomazel/interface/vllm/qwen35:v0.0.12 or latest

## docker flags

-p 8000:8000 -p 22:22 --shm-size=16g --cap-add=SYS_PTRACE --cap-add=SYS_NICE --security-opt=seccomp=unconfined --ulimit=memlock=-1

## long context

default is 262k

VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
max-model-len 1000000
"rope_type": "yarn"
"factor": 4.0
"original_max_position_embeddings": 262144

### thinking tuning per request

add to litellm JSON params

```
## control thinking on/off
"extra_body": {
    "chat_template_kwargs": {
        "enable_thinking": false
    }
}
```

## default generation config

TEMPERATURE=0.6
TOP_P=0.95
TOP_K=20
MIN_P=0.0
PRESENCE_PENALTY=0.0
REPETITION_PENALTY=1.0

## disk

model 39Gb
disk 10Gb
volume 42Gb

## env

VLLM_API_KEY=sk-keepit69
HF_HOME=/workspace/.huggingface
HF_TOKEN=\***\*\*\*\*\*\***
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

> if it hangs on two gpus

NCCL_P2P_DISABLE=1 # maybe not needed on 1 card
EXTRA_ARGS=--disable-custom-all-reduce
