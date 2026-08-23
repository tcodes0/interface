#! /usr/bin/env bash
# Copyright 2025-present R. Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
# runs vllm, use as entry point

set -euo pipefail
shopt -s globstar
trap 'err $LINENO' ERR

err() {
  echo "ERROR: command failed at line $1" >&2
}

MODEL_NAME=${MODEL_NAME:-"Qwen/Qwen3.8-27B-FP8"}
GPU_MEMORY_UTILIZATION=${GPU_MEMORY_UTILIZATION:-0.9}
MAX_NUM_BATCHED_TOKENS=${MAX_NUM_BATCHED_TOKENS:-2048}
MAX_MODEL_LEN=${MAX_MODEL_LEN:-auto}
ENFORCE_EAGER=${ENFORCE_EAGER:-"--enforce-eager"}
TENSOR_PARALLEL_SIZE=${TENSOR_PARALLEL_SIZE:-2}
ENABLE_PREFIX_CACHING=${ENABLE_PREFIX_CACHING:-"--enable-prefix-caching"}
KV_CACHE_DTYPE=${KV_CACHE_DTYPE:-"fp8"}
REASONING_PARSER=${REASONING_PARSER:-"qwen3"}
TOOL_CALL_PARSER=${TOOL_CALL_PARSER:-"qwen3_coder"}
LANGUAGE_MODEL_ONLY=${LANGUAGE_MODEL_ONLY:-"--language-model-only"}
EXTRA_ARGS=${EXTRA_ARGS:-""}

# speculative config
SC_NUM_SPECULATIVE_TOKENS=${SC_NUM_SPECULATIVE_TOKENS:-2}
SC_METHOD=${SC_METHOD:-"qwen3_5_mtp"} # 3_5 is correct, it's the architecture
SPECULATIVE_CONFIG=${SPECULATIVE_CONFIG:-"--speculative-config  {\"method\":\"$SC_METHOD\",\"num_speculative_tokens\":$SC_NUM_SPECULATIVE_TOKENS}"}

# generation config
TEMPERATURE=${TEMPERATURE:-1.0}
TOP_P=${TOP_P:-0.95}
TOP_K=${TOP_K:-20}
MIN_P=${MIN_P:-0.0}
PRESENCE_PENALTY=${PRESENCE_PENALTY:-0.0}
REPETITION_PENALTY=${REPETITION_PENALTY:-1.0}
OVERIDE_GENERATION_CONFIG=${OVERIDE_GENERATION_CONFIG:-"--override-generation-config {\"temperature\":$TEMPERATURE, \"top_p\":$TOP_P, \"top_k\":$TOP_K, \"min_p\":$MIN_P, \"presence_penalty\":$PRESENCE_PENALTY, \"repetition_penalty\":$REPETITION_PENALTY}"}

# chat template kwargs
PRESERVE_THINKING=${PRESERVE_THINKING:-false}
ENABLE_THINKING=${ENABLE_THINKING:-true}

DEFAULT_CHAT_TEMPLATE_KWARGS=${DEFAULT_CHAT_TEMPLATE_KWARGS:-"--default-chat-template-kwargs {\"preserve_thinking\": $PRESERVE_THINKING, \"enable_thinking\": $ENABLE_THINKING}"}

# rope parameters
MROPE_INTERLEAVED=${MROPE_INTERLEAVED:-true}
MROPE_SECTION=${MROPE_SECTION:-"[11, 11, 10]"}
ROPE_TYPE=${ROPE_TYPE:-"yarn"}
ROPE_THETA=${ROPE_THETA:-10000000}
PARTIAL_ROTARY_FACTOR=${PARTIAL_ROTARY_FACTOR:-0.25}
FACTOR=${FACTOR:-4.0}
ORIGINAL_MAX_POSITION_EMBEDDINGS=${ORIGINAL_MAX_POSITION_EMBEDDINGS:-262144}
HF_OVERRIDES=${HF_OVERRIDES:-"--hf-overrides {\"text_config\": {\"rope_parameters\": {\"mrope_interleaved\": $MROPE_INTERLEAVED, \"mrope_section\": $MROPE_SECTION, \"rope_type\": \"$ROPE_TYPE\", \"rope_theta\": $ROPE_THETA, \"partial_rotary_factor\": $PARTIAL_ROTARY_FACTOR, \"factor\": $FACTOR, \"original_max_position_embeddings\": $ORIGINAL_MAX_POSITION_EMBEDDINGS}}}"}

exec vllm serve "$MODEL_NAME" \
  --host 0.0.0.0 \
  --port 8000 \
  --trust-remote-code \
  --enable-auto-tool-choice \
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
  --max-num-batched-tokens "$MAX_NUM_BATCHED_TOKENS" \
  --max-model-len "$MAX_MODEL_LEN" \
  --tensor-parallel-size "$TENSOR_PARALLEL_SIZE" \
  --reasoning-parser "$REASONING_PARSER" \
  --tool-call-parser "$TOOL_CALL_PARSER" \
  --kv-cache-dtype "$KV_CACHE_DTYPE" \
  "$ENABLE_PREFIX_CACHING" \
  "$ENFORCE_EAGER" \
  "$LANGUAGE_MODEL_ONLY" \
  "$SPECULATIVE_CONFIG" \
  "$OVERIDE_GENERATION_CONFIG" \
  "$EXTRA_ARGS" \
  "$HF_OVERRIDES" \
  "$DEFAULT_CHAT_TEMPLATE_KWARGS"
