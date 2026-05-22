# Project Summary: Laguardia (LGA)

**Role:** Personal AI Agent Workstation (PAW)
**Codename:** Laguardia (lga)
**Public name:** Staion (St-AI-on)

---

## 1. Vision & Core Philosophy

LGA is a decoupled AI engineering workstation built to exceed the limitations of monolithic tools like Claude Code. It treats the **Model** as a stateless engine and the environment + tools as the primary differentiator. The system is designed for a **Hybrid Workflow**: the agent writes/refactors code on a persistent VPS, while the human operator acts as a mobile reviewer/commander.

---

## 2. Technical Stack

| Component          | Tool                           | Status              |
| ------------------ | ------------------------------ | ------------------- |
| Web/mobile UI      | LibreChat (self-hosted Docker) | ✅ Running          |
| Shell MCP          | jail-mcp (no container)        | ⬜ Not deployed     |
| Local inference    | Ollama + custom modelfiles     | ✅ Running          |
| Network            | Tailscale private mesh         | ⬜ Not deployed     |
| Routing proxy      | LiteLLM                        | ⬜ Not built        |
| VPS (project host) | AWS / DO / Hetzner             | ⬜ Not provisioned  |
| Inference provider | RunPod / Lambda / vast.ai      | ⬜ Under evaluation |
| Inference fallback | Anthropic API                  | ✅ Key available    |

---

## 3. Agent Tooling (MCP Suite)

- **Shell MCP** — jail-mcp running directly on the VPS without the Docker wrapper; the container is the jail in LGA, so the wrapper is redundant; jail-mcp is already a shell MCP server, removing the container is all that is needed
- **Sequential Thinking MCP** — forced structured planning before file modification (`modelcontextprotocol/servers/tree/main/src/sequentialthinking`)
- **Memory MCP** — LibreChat native memory tested and found insufficient for now; robust vector-backed Memory MCP planned in Layer 2; For now, trying to use a skill or prompting to close the gap.
- **GitHub** ⭐ — repo management (PRs, commits, branching); high priority, needs quality setup: model doesn't see tokens, well-crafted agent system prompts, tested workflows. Giving the model a token (to do: fix it) and GH works surprisingly well. Maybe this could be some type of skill or a very minimalistic setup.

---

## 4. Roadmap

Dependencies flow top to bottom. Do not build lower layers before upper ones are validated.

### Layer 0 — Validate what exists (no new builds)

- [x] **LibreChat exploration** — agents, native memory, file uploads, RAG config; may eliminate planned build work; specifically investigate conversation/message injection API — known to expose agents via API but injection support is unclear/not present; finding determines how thin or hacky the webhook UI adapter will be, and may accelerate the decision to swap UI
- [x] **Persistence check** — validated; LibreChat architecture handles it natively
- [x] **Sequential Thinking MCP** — trigger a complex refactor, force agent to use `thought` tool to map dependencies before coding
- [-] **Hybrid Sync** — open Aider/Tmux alongside the web UI on the same directory, verify real-time file change syncing
- [x] **Artifacts** — toggle on in settings for clean diff overlays on mobile
- [-] **Prompts** — update system prompts to mandate mobile-first summaries (logic bullets + file lists)
- [*] **GitHub setup** — scoped tokens, agent system prompts for repo workflows, signed commits configurable by environment variables, end-to-end tested; foundational for everything GitHub-related downstream
- [x] **Memory** — Use skills, prompting or the shell to have some type of memory feature while keeping the Libre feature disabled in UI.

\*Github token is being injected by the entry point script into the GH config file.
The model doesn't manipulate it, but has permission to read it.
It's a security gap, marginally better than before.

### Layer 1 — LiteLLM (everything downstream depends on this)

- [x] **LGA** — Move the project from compose files to LGA. migrate databases.
- [ ] **VPS deployment** — provision persistent compute; prerequisite for running LiteLLM and 24/7 agent tasks; some experience with this using fly.io
- [ ] **LiteLLM** — deploy LiteLLM to VPS, configure Anthropic API key; point LibreChat at LiteLLM instead of direct API calls
- [ ] **GitHub webhook bridge** — two-part design to avoid UI coupling:
  - **Bridge** — receives GitHub events (PR comments, review requests, CI pass/fail), normalizes them into a generic UI-agnostic event schema; knows nothing about LibreChat
  - **UI adapter** — thin server that consumes normalized events and calls the current UI's conversation injection API; swapping UI means replacing only this adapter
  - Optional per-event opt-in and toggle per chat/PR so it does not become noisy; terminal adapter is a trivial fallback
  - Injection doesn't work or requires contributing to the current ui, we can always build an MCP server and ask the model to pull the events.
- [ ] **Hardware provider exploration** — evaluate GPU cloud providers (RunPod, Lambda, vast.ai) for running open models with custom parameters (context length, KV cache quant, llama.cpp flags); compare cost/performance; once a provider and model are validated, it becomes primary and Anthropic API is demoted to fallback
- [ ] **Spot instance routing** — cloud GPU provider (RunPod or equivalent) as primary once validated; Anthropic API always present in LiteLLM as fallback, never removed
  - Runpod serverless is more efficient than having hardware sitting idle or underused because when the endpoint is not working there's no cost
- [ ] **MCP gateway** — connect MCPs into LiteLLM, expose a single MCP endpoint to all clients
- [ ] **Local node** — connect local machine to VPS via Tailscale so the local GPU becomes an inference node; LiteLLM routes to local Ollama when online, falls back to cloud; evaluate after hardware provider is validated
- [ ] **Observability** — Grafana + Prometheus frontend

### Layer 2 — Depends on LiteLLM

- [ ] **RAG** — prompt augmentation via embeddings
  - Flow: Prompt → RAG framework (e.g. LangChain) → embedding model → similarity search in vector DB → augmented prompt
  - LibreChat configured to use LiteLLM for the embedding model
- [ ] **Memory MCP** — look into claude-mem project. robust persistent knowledge graph backed by the same vector DB and embedding model as RAG; shares infrastructure, different data (interaction history, project knowledge vs. documents/code)
- [ ] **Agno multi-agent** — connects to LiteLLM, auto-delegates to subagents based on prompt analysis; exposed as MCP for portability (avoids LibreChat UI mods)
- [ ] **Delegate MCP** — base MCP for routing a request from a local limited agent to a more powerful cloud agent
- [ ] **Code Review MCP** — specialization on top of Delegate MCP; build after LiteLLM is stable

### Layer 3 — Parallel / ongoing (no hard dependencies)

- [ ] **Repo Isolation** — dedicated LibreChat agents per Go repo with architectural system prompts
- [ ] **Reference doc uploads** — add STYLE_GUIDE.go and ARCHITECTURE.md to Agent Files for constant context
- [ ] **llama.cpp investigation** — KV cache offloading (unsupported in Ollama); test on weak hardware, compare performance

---

## 5. Local Model Strategy

### Hardware ceiling

GPU: RX 7900 XT (20GB VRAM). Tested ~10 models up to 20B params.

**Best picks (tested and validated):**

- `gptoss20b128k` — gpt-oss:20b at 128k context; top performer overall
- `deepseekr114b64k` — deepseek-r1:14b at 64k context; strong reasoning

**Hardware limit:** Gemma 4 26B stable at 96k context — the largest model the GPU can run.

KV cache quantization priority: `q16` (lossless) → `q8` (great) → `q4` (good).

See `scratchpad/modelfiles/README.md` for full model table and VRAM notes.

### Two local model roles

- **Sidekick** — fast small model (~10B GQA) for simple/cheap tasks; routed automatically by LiteLLM
- **Best available** — Gemma 4 26B as the local ceiling; primary coding assistant and general-purpose model for local work

### Hybrid compute idea

Connect local machine to VPS via Tailscale so the local GPU becomes a node in the inference network. LiteLLM routes to local Ollama when the machine is on, falls back to cloud GPU providers when not. Effectively turns local hardware into a zero-cost-when-available inference provider. Evaluate during hardware provider exploration (Layer 1).

---

## 6. Key Design Decisions

> **Word conventions:** avoid "harness" — use "environment" or "tooling layer" instead. Avoid "Bible" — use "reference docs".

- **Model is stateless; environment is the differentiator** — don't optimize the model, optimize the environment
- **UI is a skin, not the system** — LibreChat is the current interface but must remain shallow and swappable; nothing critical should be coupled to it; if a better UI emerges (or a terminal workflow is preferred), the environment stays intact and only the front end changes
- **Abstract LibreChat from the start** — do not wait until a swap is needed; every integration point (webhook injection, conversation API, agent config) should go through an abstraction layer so LibreChat can be replaced by swapping one adapter, not by refactoring the whole system
- **MCP over UI mods** — all capabilities exposed via MCP so they are client-agnostic; works with LibreChat, a terminal, or any future UI without modification
- **LiteLLM as the hub** — all routing, cost arbitrage, and embedding goes through one proxy; simplifies everything downstream
- **LibreChat native features first** — explore what's built-in before building parallel systems that duplicate it; but do not depend on LibreChat-specific internals for anything that needs to survive a UI swap
- **Terminal workflow as secondary** — MCP tools are CLI-invokable by nature so terminal access largely comes for free; not a primary investment but a natural fallback
