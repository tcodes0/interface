---
name: runpod
description: Use when working with RunPod — deploying serverless vLLM endpoints, checking GPU catalog/pricing, managing templates, pods, or network volumes via the RunPod API.
---

# RunPod

## MCP Tools

Two tools, one underlying API key, different surfaces:

| Tool             | Base URL                        | Use for                                                           |
| ---------------- | ------------------------------- | ----------------------------------------------------------------- |
| `runpod_rest`    | `https://rest.runpod.io/v1`     | CRUD on pods, templates, endpoints, network volumes, billing      |
| `runpod_graphql` | `https://api.runpod.io/graphql` | Things REST doesn't cover, notably `gpuTypes` (catalog + pricing) |

Both use Authorization: Bearer <API_KEY> injected server-side.

Sanity check either surface:

```
GET /openapi.json            (runpod_rest)   -> full OpenAPI 3.0 schema, useful for exact field names
POST { "query": "query { myself { id } }" }  (runpod_graphql) -> confirms auth works
```

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

| GPU                                                 | VRAM  | Secure $/hr | Notes                                               |
| --------------------------------------------------- | ----- | ----------- | --------------------------------------------------- |
| `NVIDIA A40`                                        | 48GB  | 0.44        | Ampere, cheapest 48GB option                        |
| `NVIDIA RTX A6000`                                  | 48GB  | 0.49        | Ampere, slightly pricier than A40                   |
| `NVIDIA RTX 6000 Ada Generation`                    | 48GB  | 0.77        | Ada, not Ampere — faster, pricier                   |
| `NVIDIA L40S`                                       | 48GB  | 0.99        | Ada                                                 |
| `NVIDIA A100-SXM4-80GB`                             | 80GB  | 1.49        |                                                     |
| `NVIDIA H100 80GB HBM3`                             | 80GB  | 2.99        |                                                     |
| `NVIDIA H200`                                       | 141GB | 4.39        | Hopper, fallback if Blackwell context math is tight |
| `NVIDIA RTX PRO 6000 Blackwell Workstation Edition` | 96GB  | 1.89        | Blackwell, our target 96GB tier                     |
| `NVIDIA RTX PRO 6000 Blackwell Server Edition`      | 96GB  | 1.99        | Same VRAM, server-rated variant                     |
| `NVIDIA B200`                                       | 180GB | 5.89        | Full Blackwell datacenter card                      |

Gotcha: some `id`s have a `securePrice` of `0` in the catalog response (e.g. `A100-SXM4-40GB`, several older cards) — that means no secure-cloud stock, not that it's free. Check `communityPrice` and both spot fields too before assuming availability.

## Serverless vLLM Deployment (worker-vllm)

RunPod's official pre-built image for OpenAI-compatible LLM serving: `runpod/worker-v1-vllm:<version>` (from [runpod-workers/worker-vllm](https://github.com/runpod-workers/worker-vllm), MIT licensed). No custom Dockerfile needed for standard HF models — configure entirely via env vars on the template.

**Our fork** (needed to run vLLM 0.25.0, since upstream caps at 0.23.0): `ghcr.io/rthomazel/worker-vllm:latest`, built from `git@github.com:rthomazel/worker-vllm.git`. Build/push via `compose-files/runpod/bin/build`; deploy an endpoint from it via `compose-files/runpod/bin/deploy` (see below). Two upstream-vs-0.25.0 breaking changes fixed on the `feat/vllm-0.25.0` branch, in case future vLLM bumps hit the same class of issue again:

- Module moved: `vllm.entrypoints.serve.render.serving` → `vllm.entrypoints.scale_out.render.serving`.
- Class split: `OpenAIServingRender` → `OnlineRenderer` (`vllm.renderers.online_renderer`), constructor dropped the `model_registry` kwarg. `OpenAIServingChat`/`Completion`/`Responses`/`AnthropicServingMessages` all renamed their `openai_serving_render=` kwarg to `online_renderer=`.

**GHCR package visibility gotcha:** a freshly pushed GHCR container package defaults to **private**, independent of the source repo's visibility — making the GitHub repo public does _not_ flip the package. RunPod's serverless pull fails with `IMAGE_AUTH_ERROR: ... unauthorized` if the package is still private. Fix via GitHub UI: package page → Package settings → Change visibility → Public (the REST API's `PATCH /user/packages/container/{name}` visibility endpoint 404s even with a `write:packages`-scoped token — visibility changes need broader package-admin perms than that token can grant, so this has to be done by hand in the UI, not automated).

There is **no official TensorRT-LLM worker**. If NVFP4/MXFP4 is the goal, vLLM (which worker-vllm runs) already has native support for both — no need to reach for TensorRT-LLM:

- `mxfp4` — native, `Mxfp4Config`, what gpt-oss ships with.
- `modelopt_fp4` (NVFP4), `modelopt_mxfp8` — via NVIDIA ModelOpt integration, same format TensorRT-LLM uses. Full hardware acceleration is Blackwell-only; on Hopper/Ampere these still run correctly via emulation (memory savings, not full speed win).

### Key env vars (worker-vllm auto-discovers any valid vLLM `AsyncEngineArgs` field, UPPERCASED)

```
MODEL_NAME=<hf repo>
QUANTIZATION=awq|modelopt_fp4|mxfp4|...
MAX_MODEL_LEN=<int>
MAX_NUM_BATCHED_TOKENS=<int>
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

### Gotchas confirmed against the live schema (2026-07-13)

- **`flashboot` is not on `EndpointCreateInput`** — only on `EndpointUpdateInPlaceInput`/`EndpointUpdateInput`. Create the endpoint first, then `PATCH /v1/endpoints/{id}` with `{"flashboot": true}` if wanted. Setting it in the create body is silently ignored.
- `EndpointCreateInput` only strictly requires `templateId` — everything else has defaults (`idleTimeout` default 5s, range 1-3600; `scalerType` default `QUEUE_DELAY` with `scalerValue` default 4; `dataCenterIds` defaults to all ~27 regions if omitted).
- Use `networkVolumeIds` (plural, current — supports multi-region). `networkVolumeId` (singular) still exists but is the legacy field.
- Billing paths are `/v1/billing/pods` and `/v1/billing/endpoints` (not `/v1/billing`).
- Container registry auth path is singular: `/v1/containerregistryauth` (not `...auths`), only needed for private images.
- Account state (pods/templates/endpoints/network volumes) changes constantly — always check live via the REST list endpoints rather than trusting notes here.

Model choices, benchmarks, and specific deployment configs for any given endpoint are project-specific — tracked in the relevant project (e.g. `compose-files`), not here.

## Deploying (use the REST calls directly, or the RunPod dashboard UI)

List templates first, operator keeps those up to date, if none fits you may create.
Full field-level schema (all required/optional fields, enums for `gpuTypeIds`, `allowedCudaVersions`, `dataCenterIds`, etc.) is always available live via `GET /openapi.json` on `runpod_rest` — pull it fresh rather than trusting a stale copy here, RunPod adds GPU types and fields over time. GraphQL introspection (`__schema`/`__type`) is disabled in production — REST's `/openapi.json` is the reliable schema source, not GraphQL.

`workersMin: 0` scales to zero between requests (cheapest, cold-start latency on next call). `workersMin: 1`+ keeps a worker always warm (charged continuously at the lower "warm" rate, no cold start).

```
POST /v1/templates
{
  "name": "worker-vllm-qwen3-35b-a3b-awq",
  "imageName": "ghcr.io/rthomazel/worker-vllm:latest",
  "isServerless": true,
  "containerDiskInGb": 80,
  "env": {
    "MODEL_NAME": "cyankiwi/Qwen3.6-35B-A3B-AWQ-4bit",
    "QUANTIZATION": "awq",
    "MAX_MODEL_LEN": "262144",
    "MAX_NUM_BATCHED_TOKENS": "8192",
    "GPU_MEMORY_UTILIZATION": "0.95",
    "TOOL_CALL_PARSER": "qwen3_xml",
    "REASONING_PARSER": "qwen3",
    "ENABLE_AUTO_TOOL_CHOICE": "true",
    "LOG_ERROR_STACK": "true"
  }
}

POST /v1/endpoints
{
  "name": "worker-vllm-qwen3-35b-a3b-awq",
  "templateId": "<id from above>",
  "gpuTypeIds": ["NVIDIA A40", "NVIDIA RTX A6000"],
  "gpuCount": 1,
  "workersMin": 0,
  "workersMax": 1,
  "idleTimeout": 300
}
```

Then warm it up with a `runsync` (see "OpenAI-compatible endpoint shape" above for the URL) — a `{model, messages: [...], max_tokens: 8}` chat completion is enough to trigger a cold pull + model load and confirm health before real traffic. Drop `idleTimeout` to 15-30s while iterating on configs (see billing section below) and raise it back once stable.

## Debugging serverless vLLM crashes/OOMs

**No log access via API.** Confirmed dead ends (2026-07-14): REST has no `podLogs`-equivalent endpoint; GraphQL's `Pod`/`PodRuntime` types have no `logs` field; GraphQL introspection is disabled in prod so you can't even enumerate what _might_ be there. **The only way to see a real traceback is the RunPod web dashboard's log viewer**

**Context-length OOM at engine init is usually `MAX_NUM_BATCHED_TOKENS`, not KV cache.**

```
KV bytes/token = 2(K+V) × num_key_value_heads × head_dim × dtype_bytes × num_full_attention_layers
```

**Changing a template on a live endpoint doesn't affect already-running/resumed workers.** `PATCH /v1/endpoints/{id}` with a new `templateId` only takes effect on a _fresh_ worker start.

**`runsync` jobs can get orphaned in the queue during config churn.** After swapping templates/pods a few times in a row, you may see a `runsync` request's own status endpoint (`GET /v2/{endpointId}/status/{jobId}`) stay stuck at `{"status":"IN_QUEUE"}` indefinitely even though `GET /v2/{endpointId}/health` shows a `ready`/`idle` worker available. Don't keep polling the stuck job — just fire a fresh `runsync` request.

## Billing behavior confirmed via `/v1/billing/endpoints` (2026-07-14)

- **Idle time between requests is billed**, not free. `idleTimeout` (seconds a worker stays warm after its last job) is billed at the normal running rate — it's a deliberate cold-start-vs-cost trade, not a grace period.
- **`workersMin: 0` genuinely scales to zero**
- A cheap way to sanity-check total spend on one endpoint: `GET /v1/billing/endpoints?endpointId=<id>` returns `{"amount": <$>, "timeBilledMs": <ms>, "diskSpaceBilledGB": <gb>}` for the day — check this instead of guessing from wall-clock time spent testing.
