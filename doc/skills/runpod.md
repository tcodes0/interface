---
name: runpod
description: Use when working with RunPod — deploying serverless vLLM endpoints, checking GPU catalog/pricing, managing templates, pods, or network volumes via the RunPod API.
---

# RunPod

## MCP Tools

Two tools, one underlying API key, different surfaces:

| Tool                 | Base URL                        | Use for                                                          |
| --------------------- | -------------------------------- | ----------------------------------------------------------------- |
| `runpod_rest`         | `https://rest.runpod.io/v1`      | CRUD on pods, templates, endpoints, network volumes, billing      |
| `runpod_graphql`      | `https://api.runpod.io/graphql`  | Things REST doesn't cover, notably `gpuTypes` (catalog + pricing) |

Both use `Authorization: Bearer <RUNPOD_API_KEY>` injected server-side by the `keys` MCP server — never ask for or paste the raw key into a request body.

Sanity check either surface:

```
GET /openapi.json            (runpod_rest)   -> full OpenAPI 3.0 schema, useful for exact field names
POST { "query": "query { myself { id } }" }  (runpod_graphql) -> confirms auth works
```

## Adding/Fixing the MCP Wiring

Lives in the `lga` repo (Docker Compose stack), not here. Two independent places must agree:

1. `compose.yml` — Docker Compose's own `secrets:` (file -> secret name), wired for `mcpkeys` service.
2. `services/mcpkeys/keys.yaml` — the `keys` app's **own internal** `secrets:` registry (secret name -> `docker_secret` reference) **and** the `mcp_tools:` entries that reference those secret names under `inject`.

These are two separate registries. Compose can be fully correct while `keys.yaml`'s internal list is still missing the name — symptom is `secret "X" not found in secrets` at container startup, even though the file is mounted fine. Check both whenever a new key/tool is added, and restart `mcpkeys` (`docker compose up -d --force-recreate mcpkeys`) after editing `keys.yaml`.

After restarting `mcpkeys`, LibreChat itself must also restart to pick up the new tools — the MCP client connection doesn't hot-reload the tool list.

## GPU Catalog & Pricing

Query via GraphQL — REST has no equivalent list endpoint, only enum values buried in `/openapi.json`:

```graphql
query {
  gpuTypes(input: {}) {
    id
    displayName
    memoryInGb
    securePrice
    communityPrice
    secureSpotPrice
    communitySpotPrice
  }
}
```

`id` is the exact string to use in `gpuTypeIds` when creating endpoints/pods/templates via REST — it must match verbatim (e.g. `"NVIDIA A40"`, not `"A40"`).

### Snapshot (2026-07-13, secure cloud on-demand price/hr — reconfirm before committing spend, this drifts)

| GPU                                              | VRAM  | Secure $/hr | Notes                          |
| ------------------------------------------------- | ----- | ----------- | ------------------------------- |
| `NVIDIA A40`                                       | 48GB  | 0.44        | Ampere, cheapest 48GB option     |
| `NVIDIA RTX A6000`                                  | 48GB  | 0.49        | Ampere, slightly pricier than A40 |
| `NVIDIA RTX 6000 Ada Generation`                    | 48GB  | 0.77        | Ada, not Ampere — faster, pricier |
| `NVIDIA L40S`                                       | 48GB  | 0.99        | Ada                              |
| `NVIDIA A100-SXM4-80GB`                             | 80GB  | 1.49        |                                  |
| `NVIDIA H100 80GB HBM3`                             | 80GB  | 2.99        |                                  |
| `NVIDIA H200`                                       | 141GB | 4.39        | Hopper, fallback if Blackwell context math is tight |
| `NVIDIA RTX PRO 6000 Blackwell Workstation Edition` | 96GB  | 1.89        | Blackwell, our target 96GB tier  |
| `NVIDIA RTX PRO 6000 Blackwell Server Edition`      | 96GB  | 1.99        | Same VRAM, server-rated variant  |
| `NVIDIA B200`                                       | 180GB | 5.89        | Full Blackwell datacenter card   |

Gotcha: some `id`s have a `securePrice` of `0` in the catalog response (e.g. `A100-SXM4-40GB`, several older cards) — that means no secure-cloud stock, not that it's free. Check `communityPrice` and both spot fields too before assuming availability.

## Serverless vLLM Deployment (worker-vllm)

RunPod's official pre-built image for OpenAI-compatible LLM serving: `runpod/worker-v1-vllm:<version>` (from [runpod-workers/worker-vllm](https://github.com/runpod-workers/worker-vllm), MIT licensed). No custom Dockerfile needed for standard HF models — configure entirely via env vars on the template.

There is **no official TensorRT-LLM worker**. If NVFP4/MXFP4 is the goal, vLLM (which worker-vllm runs) already has native support for both — no need to reach for TensorRT-LLM:

- `mxfp4` — native, `Mxfp4Config`, what gpt-oss ships with.
- `modelopt_fp4` (NVFP4), `modelopt_mxfp8` — via NVIDIA ModelOpt integration, same format TensorRT-LLM uses. Full hardware acceleration is Blackwell-only; on Hopper/Ampere these still run correctly via emulation (memory savings, not full speed win).

### Key env vars (worker-vllm auto-discovers any valid vLLM `AsyncEngineArgs` field, UPPERCASED)

```
MODEL_NAME=<hf repo>
QUANTIZATION=awq|modelopt_fp4|mxfp4|...
MAX_MODEL_LEN=<int>
KV_CACHE_DTYPE=fp8
GPU_MEMORY_UTILIZATION=0.9-0.95
TENSOR_PARALLEL_SIZE=<gpu count>
ENABLE_AUTO_TOOL_CHOICE=true
TOOL_CALL_PARSER=hermes|mistral|llama3_json|...
REASONING_PARSER=qwen3|deepseek_r1|...
ROPE_SCALING={"rope_type":"yarn","factor":...,"original_max_position_embeddings":...}
```

OpenAI-compatible endpoint shape once deployed: `https://api.runpod.ai/v2/<ENDPOINT_ID>/openai/v1` — drop-in `base_url` for any OpenAI client.

See `compose-files/vllm/bin/vllm-helper` for the model-name -> tool-parser / reasoning-parser mapping we maintain locally (ROCm-focused, but the mapping logic transfers directly to these env vars).

## Creating Resources via REST

Flow: create a **template** first (image + env + disk sizing), then create an **endpoint** referencing `templateId`.

```
POST /v1/templates
{
  "name": "...",
  "imageName": "runpod/worker-v1-vllm:<version>",
  "isServerless": true,
  "env": { "MODEL_NAME": "...", ... },
  "containerDiskInGb": 50
}

POST /v1/endpoints
{
  "templateId": "<id from above>",
  "gpuTypeIds": ["NVIDIA RTX PRO 6000 Blackwell Workstation Edition"],
  "gpuCount": 1,
  "workersMin": 0,
  "workersMax": 1,
  "idleTimeout": 5,
  "flashboot": true,
  "networkVolumeIds": ["<optional, for HF cache persistence>"]
}
```

Full field-level schema (all required/optional fields, enums for `gpuTypeIds`, `allowedCudaVersions`, `dataCenterIds`, etc.) is always available live via `GET /openapi.json` on `runpod_rest` — pull it fresh rather than trusting a stale copy here, RunPod adds GPU types and fields over time. GraphQL introspection (`__schema`/`__type`) is disabled in production — REST's `/openapi.json` is the reliable schema source, not GraphQL.

`workersMin: 0` scales to zero between requests (cheapest, cold-start latency on next call). `workersMin: 1`+ keeps a worker always warm (charged continuously at the lower "warm" rate, no cold start).

### Gotchas confirmed against the live schema (2026-07-13)

- **`flashboot` is not on `EndpointCreateInput`** — only on `EndpointUpdateInPlaceInput`/`EndpointUpdateInput`. Create the endpoint first, then `PATCH /v1/endpoints/{id}` with `{"flashboot": true}` if wanted. Setting it in the create body is silently ignored.
- `EndpointCreateInput` only strictly requires `templateId` — everything else has defaults (`idleTimeout` default 5s, range 1-3600; `scalerType` default `QUEUE_DELAY` with `scalerValue` default 4; `dataCenterIds` defaults to all ~27 regions if omitted).
- Use `networkVolumeIds` (plural, current — supports multi-region). `networkVolumeId` (singular) still exists but is the legacy field.
- Billing paths are `/v1/billing/pods` and `/v1/billing/endpoints` (not `/v1/billing`).
- Container registry auth path is singular: `/v1/containerregistryauth` (not `...auths`), only needed for private images.
- Account snapshot as of 2026-07-13: zero pods, templates, endpoints, or network volumes — clean slate.

## Open / In-Progress Model Choices (as of 2026-07-13)

Two-endpoint plan, alternate between them by hand:

- **Ampere 48GB** (`NVIDIA A40` or `NVIDIA RTX A6000`): coding-capable instruct model, 100K+ context, 40+ tok/s target. **Primary pick:** `cyankiwi/Qwen3.6-35B-A3B-AWQ-4bit` (MoE, 35B total/~3B active, AWQ 4-bit, ~25GB on disk — leaves ~23GB free for KV cache on a 48GB card). Newer than the Qwen3-Coder-30B-A3B line, scores ~72 on SWE-bench vs ~55 for the older model (operator-supplied benchmark comparison) and natively supports **262144 (256K) context** — no YaRN extension needed, comfortably clears the 100K+ target. Quantizer (`cyankiwi`) previously vetted by operator via prior use, no trust caveat needed. Repo's own suggested launch command (sglang, `--tp-size 8` for a cluster — use `--tensor-parallel-size 1` for our single-GPU target instead) specifies `--reasoning-parser qwen3 --tool-call-parser qwen3_coder`, directly reusable as `REASONING_PARSER`/`TOOL_CALL_PARSER` in worker-vllm.

  ```
  MODEL_NAME=cyankiwi/Qwen3.6-35B-A3B-AWQ-4bit
  QUANTIZATION=awq
  MAX_MODEL_LEN=262144   # native, trim if KV cache doesn't fit at full length
  KV_CACHE_DTYPE=fp8
  GPU_MEMORY_UTILIZATION=0.92
  TENSOR_PARALLEL_SIZE=1
  ENABLE_AUTO_TOOL_CHOICE=true
  TOOL_CALL_PARSER=qwen3_coder
  REASONING_PARSER=qwen3
  ```

  Fallback: `QuantTrio/Qwen3-Coder-30B-A3B-Instruct-GPTQ-Int8` (older model, int8, 32K native context needing YaRN to reach 100K) if the newer pick doesn't pan out empirically. `Qwen/Qwen3-32B-AWQ` (dense) is the last-resort fallback. `QuantTrio/Qwen3-Coder-30B-A3B-Instruct-AWQ` (4-bit) stays ruled out — its own model card warns of significant quality loss at 4-bit, and the newer/bigger-context cyankiwi pick makes it moot anyway.
- **Blackwell 96GB** (`NVIDIA RTX PRO 6000 Blackwell Workstation Edition`): FP4-quantized model, 200K-300K context target. Candidates: `Firworks/GLM-4.5-Air-nvfp4` (NVFP4, unverified quantizer reputation — check HF likes/downloads before trusting), or `openai/gpt-oss-120b` (native MXFP4, zero third-party-quant trust needed) as the safe fallback. Also check whether a GLM-5-Air-class model with an FP4 checkpoint exists now, given GLM-5/5.2 have since shipped.

Both picks are provisional — verify exact HF repo names, context-length ceilings, and KV-cache fit empirically once a template/endpoint is stood up. Don't trust context-length numbers above without checking the actual model's `config.json`.
