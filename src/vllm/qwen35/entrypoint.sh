#! /usr/bin/env bash
# Copyright 2026-present R. Thomazella. All rights reserved.
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

VLLM_MONITOR_PATH=${VLLM_MONITOR_PATH:-/usr/local/bin/vllm-monitor}
VLLM_MONITOR_URL=${VLLM_MONITOR_URL:-https://raw.githubusercontent.com/rthomazel/interface/dev/bin/vllm-monitor}
TMUX_CONF_PATH=${TMUX_CONF_PATH:-/root/.tmux.conf}
TMUX_CONF_URL=${TMUX_CONF_URL:-https://raw.githubusercontent.com/rthomazel/interface/dev/dotfiles/.tmux.conf}

if [[ ! -x "$VLLM_MONITOR_PATH" ]]; then
  curl -fsSL "$VLLM_MONITOR_URL" -o "$VLLM_MONITOR_PATH"
  chmod +x "$VLLM_MONITOR_PATH"
fi

if [[ ! -f "$TMUX_CONF_PATH" ]]; then
  if ! curl -fsSL "$TMUX_CONF_URL" -o "$TMUX_CONF_PATH"; then
    echo "[WARN] Could not download tmux configuration from $TMUX_CONF_URL" >&2
  fi
fi

LOG_DIR=${LOG_DIR:-/workspace/logs}
LOG_FILE=${LOG_FILE:-"$LOG_DIR/vllm-$(date +%Y%m%d-%H%M%S).log"}

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

TZ=${TZ:-America/Sao_Paulo}
printf 'export TZ=%q\n' "$TZ" >/etc/profile.d/timezone.sh
export TZ

MODEL_NAME=${MODEL_NAME:-"Qwen/Qwen3.8-27B-FP8"}
GPU_MEMORY_UTILIZATION=${GPU_MEMORY_UTILIZATION:-0.9}
MAX_NUM_BATCHED_TOKENS=${MAX_NUM_BATCHED_TOKENS:-2048}
MAX_MODEL_LEN=${MAX_MODEL_LEN:-auto}
TENSOR_PARALLEL_SIZE=${TENSOR_PARALLEL_SIZE:-2}
REASONING_PARSER=${REASONING_PARSER:-"qwen3"}
TOOL_CALL_PARSER=${TOOL_CALL_PARSER:-"qwen3_coder"}
KV_CACHE_DTYPE=${KV_CACHE_DTYPE:-"fp8"}
EXTRA_ARGS=${EXTRA_ARGS:-""}

# booleans
ENABLE_PREFIX_CACHING=${ENABLE_PREFIX_CACHING:-true}
ENFORCE_EAGER=${ENFORCE_EAGER:-false}
LANGUAGE_MODEL_ONLY=${LANGUAGE_MODEL_ONLY:-true}

# speculative config
SPECULATIVE_CONFIG=${SPECULATIVE_CONFIG:-true}
SC_NUM_SPECULATIVE_TOKENS=${SC_NUM_SPECULATIVE_TOKENS:-2}
SC_METHOD=${SC_METHOD:-"qwen3_5_mtp"} # 3_5 is correct, it's the architecture

# generation config
OVERRIDE_GENERATION_CONFIG=${OVERRIDE_GENERATION_CONFIG:-true}
TEMPERATURE=${TEMPERATURE:-1.0}
TOP_P=${TOP_P:-0.95}
TOP_K=${TOP_K:-20}
MIN_P=${MIN_P:-0.0}
PRESENCE_PENALTY=${PRESENCE_PENALTY:-0.0}
REPETITION_PENALTY=${REPETITION_PENALTY:-1.0}

# chat template kwargs
DEFAULT_CHAT_TEMPLATE_KWARGS=${DEFAULT_CHAT_TEMPLATE_KWARGS:-true}
PRESERVE_THINKING=${PRESERVE_THINKING:-false}
ENABLE_THINKING=${ENABLE_THINKING:-true}

# rope parameters
HF_OVERRIDES=${HF_OVERRIDES:-false}
MROPE_INTERLEAVED=${MROPE_INTERLEAVED:-true}
MROPE_SECTION=${MROPE_SECTION:-"[11, 11, 10]"}
ROPE_TYPE=${ROPE_TYPE:-"yarn"}
ROPE_THETA=${ROPE_THETA:-10000000}
PARTIAL_ROTARY_FACTOR=${PARTIAL_ROTARY_FACTOR:-0.25}
FACTOR=${FACTOR:-4.0}
ORIGINAL_MAX_POSITION_EMBEDDINGS=${ORIGINAL_MAX_POSITION_EMBEDDINGS:-262144}

ARGS=(
  --host 0.0.0.0
  --port 8000
  --trust-remote-code
  --enable-auto-tool-choice
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION"
  --max-num-batched-tokens "$MAX_NUM_BATCHED_TOKENS"
  --max-model-len "$MAX_MODEL_LEN"
  --tensor-parallel-size "$TENSOR_PARALLEL_SIZE"
  --reasoning-parser "$REASONING_PARSER"
  --tool-call-parser "$TOOL_CALL_PARSER"
  --kv-cache-dtype "$KV_CACHE_DTYPE"
)

[[ "$ENABLE_PREFIX_CACHING" == true ]] && ARGS+=(--enable-prefix-caching)
[[ "$ENFORCE_EAGER" == true ]] && ARGS+=(--enforce-eager)
[[ "$LANGUAGE_MODEL_ONLY" == true ]] && ARGS+=(--language-model-only)

# build compound configs
if [[ "$SPECULATIVE_CONFIG" == true ]]; then
  ARGS+=(
    --speculative-config
    "{\"method\":\"$SC_METHOD\",\"num_speculative_tokens\":$SC_NUM_SPECULATIVE_TOKENS}"
  )
fi

if [[ "$OVERRIDE_GENERATION_CONFIG" == true ]]; then
  ARGS+=(
    --override-generation-config
    "{\"temperature\":$TEMPERATURE,\"top_p\":$TOP_P,\"top_k\":$TOP_K,\"min_p\":$MIN_P,\"presence_penalty\":$PRESENCE_PENALTY,\"repetition_penalty\":$REPETITION_PENALTY}"
  )
fi

if [[ "$DEFAULT_CHAT_TEMPLATE_KWARGS" == true ]]; then
  ARGS+=(
    --default-chat-template-kwargs
    "{\"preserve_thinking\":$PRESERVE_THINKING,\"enable_thinking\":$ENABLE_THINKING}"
  )
fi

if [[ "$HF_OVERRIDES" == true ]]; then
  ARGS+=(
    --hf-overrides
    "{\"text_config\":{\"rope_parameters\":{\"mrope_interleaved\":$MROPE_INTERLEAVED,\"mrope_section\":$MROPE_SECTION,\"rope_type\":\"$ROPE_TYPE\",\"rope_theta\":$ROPE_THETA,\"partial_rotary_factor\":$PARTIAL_ROTARY_FACTOR,\"factor\":$FACTOR,\"original_max_position_embeddings\":$ORIGINAL_MAX_POSITION_EMBEDDINGS}}}"
  )
fi

if [[ -n "$EXTRA_ARGS" ]]; then
  read -r -a EXTRA_ARGS_ARRAY <<<"$EXTRA_ARGS"
  ARGS+=("${EXTRA_ARGS_ARRAY[@]}")
fi

# .bashrc setup
if [[ -n "${VLLM_API_KEY:-}" ]]; then
  printf 'export VLLM_API_KEY=%q\n' "$VLLM_API_KEY" >>/root/.bashrc
fi

printf 'export VLLM_MODEL_NAME=%q\n' "$MODEL_NAME" >>/root/.bashrc

TMUX_START=${TMUX_START:-false}

if [[ "$TMUX_START" == true ]] && ! grep -Fq '# vLLM tmux startup' /root/.bashrc; then
  cat >>/root/.bashrc <<'EOF'

# vLLM tmux startup
if [[ -z "${TMUX:-}" && $- == *i* ]]; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi
EOF
fi

# start sshd and vllm server
echo [INFO] Running image version "${VERSION:-"unknown"}"

/usr/sbin/sshd

exec vllm serve "$MODEL_NAME" "${ARGS[@]}"
