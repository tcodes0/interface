This plan outlines the migration from a local, quantized **Whisper** setup to a high-precision, cloud-based **STT + LLM Refiner** pipeline. It leverages **Groq’s LPU** (Language Processing Unit) hardware and **Cloudflare’s Edge** to maximize accuracy while maintaining a sub-500ms latency target.

---

## 1. System Architecture

The core design philosophy is to minimize the latency penalty of the Brazil-to-US network hop by chaining logic at the "Edge."

- **Frontend (Local):** A `systemd` oneshot service triggered by a keyboard shortcut. It captures audio (PCM/WAV) and makes a single `POST` request to the Edge Proxy.
- **Edge Proxy (Cloudflare Workers):** Acts as the orchestrator. It receives the audio, executes the Groq chain, and returns the final polished text. This prevents "Double RTT" from the local machine.
- **Inference Layer (Groq):**
- **Pass 1 (STT):** `whisper-large-v3-turbo` (FP16 precision).
- **Pass 2 (Correction):** `llama-3.3-70b-versatile` or `llama-4-scout` (for semantic cleanup).

## 2. Technical Nuances & Implementation

### Semantic Refinement Logic

Unlike a raw STT, the second pass uses a **System Prompt** injected with a "Technical Dictionary." This dictionary is stored in **Cloudflare KV** and contains domain-specific mappings (e.g., `white plus` → `Vite+`, `go routine` → `goroutine`).

> **Prompt Strategy:**
> "You are a technical editor for a Go/Vite developer. Correct the following transcript for technical accuracy and punctuation. Return ONLY the text. Context: [KV_DICTIONARY_JSON]"

### Performance Estimates (Brazil Context)

| Phase                        | Duration   | Protocol             |
| ---------------------------- | ---------- | -------------------- |
| **Upload (FLN → US-East)**   | ~160ms     | HTTPS (Streamed)     |
| **Groq Whisper Inference**   | ~50ms      | Internal US Backbone |
| **Groq Llama Inference**     | ~100ms     | Internal US Backbone |
| **Download (US-East → FLN)** | ~150ms     | JSON                 |
| **Total Pipeline**           | **~460ms** | **Target**           |

## 3. Trade-offs & Constraints

### The Accuracy/Latency Pivot

- **The Win:** Moving from local 4-bit quantization to cloud FP16 precision drastically reduces word error rates (WER), especially for tech-heavy jargon.
- **The Cost:** You lose the ~200ms "instant" feel of local hardware. 460ms is perceptible but falls within the "reactive" threshold for a voice-to-clipboard workflow.
- **Privacy:** Data leaves the local machine. While Groq (2026) offers zero-retention policies on their free tier, this remains a trade-off vs. 100% air-gapped local inference.

### Rate Limits (2026 Free Tier)

- **Cloudflare Workers:** 100,000 requests/day (Exceeds requirement).
- **Groq Whisper:** 2,000 requests/day (Exceeds requirement).
- **Groq LLM:** 1,000 requests/day (Exceeds requirement).

## 4. Optionality & Extensibility

1. **Self-Correction Loop:** Implement a secondary shortcut that "flags" the last transcription. This triggers a worker task to update the KV dictionary with the correction, creating a self-improving system.
2. **Multimodal Expansion:** Since Groq's LPU is extremely fast, a third pass for "Action Extraction" could be added (e.g., detecting "Set a reminder" and routing to a Calendar API) with only ~50ms of added latency.
3. **Local Fallback:** The local Go server can remain as a heartbeat fallback. If the Cloudflare Worker returns a 5xx error (e.g., internet outage), the shortcut falls back to the local `whisper.cpp` binary.

## 5. Design Summary for Implementation

- **Language:** TypeScript (Worker) / Bash or Go (Local Client).
- **Storage:** Cloudflare KV for the persistent dictionary.
- **Security:** API Keys stored as `wrangler secrets`.
- **Trigger:** `arecord` | `curl` (Client-side) → `Promise.all` or sequential chaining (Worker-side).

This design provides an "Enterprise Grade" STT experience using only free-tier resources, specifically optimized for the high-latency challenges of South American developers.

# Rook's Review

---

**Scope**: High-level migration plan for local Whisper to Cloudflare Worker + Groq STT/LLM refinement pipeline

**Findings**:
[critical] **Latency architecture / “single POST” assumption** — The plan claims the Edge Worker “prevents Double RTT” and keeps total latency under ~460ms, but the proposed chain still requires: local upload to Cloudflare, Cloudflare-to-Groq STT request, then Cloudflare-to-Groq LLM request, then response back to local. The Brazil→US hop is only one part of end-to-end latency; the Worker does not eliminate the upstream service round trips, it only avoids making the client perform them directly. At this level of budget, the plan is understating orchestration overhead, request setup, buffering, and queueing risk. The sub-500ms target is therefore not well justified by the architecture as written.

[critical] **Cloudflare Workers request-body handling** — The plan assumes streamed audio upload through the Worker into Groq STT, but does not address a major implementation constraint: many Worker-based proxy designs cannot simply forward arbitrary large multipart/audio bodies without buffering, size limits, or compatibility issues with the upstream API’s expected upload format. Since the whole design depends on low-latency pass-through of recorded audio, this omission is architectural, not incidental. If the Worker must buffer or repackage the upload, the latency and memory model changes materially.

[warning] **Use of KV as live prompt dictionary** — Cloudflare KV is presented as the store for a “Technical Dictionary” used on every request, but KV is eventually consistent and not ideal for correctness-sensitive, immediately-visible updates like the proposed self-correction loop. If a user corrects a term and expects the next transcription to honor it, KV may serve stale values across regions. That may be acceptable, but the plan treats KV like strongly consistent configuration storage.

[warning] **Prompt-injection / output corruption risk from dictionary strategy** — Injecting raw dictionary JSON into a system prompt is fragile. If any entry contains quotes, formatting artifacts, or unintended instructions, it can degrade output quality or alter model behavior. Even absent malicious input, a growing dictionary will bloat prompt tokens and directly add latency/cost to the second pass. The plan needs a bounded, structured normalization strategy rather than “dump KV JSON into the system prompt.”

[warning] **Free-tier viability is overstated** — The summary frames this as “Enterprise Grade” on free-tier resources, but the design has two external paid-grade inference calls per user action and depends on specific rate limits and retention guarantees that may change. Even if the quoted limits are accurate at one point in time, the plan has no backpressure, quota exhaustion, or graceful degradation strategy beyond falling back on 5xx. Hitting 429/rate caps is a normal-mode condition for free tiers and should be designed for.

[warning] **Fallback conditions are incomplete** — The fallback path only mentions Cloudflare Worker 5xx errors, but the real failure surface includes Groq timeouts, Groq 4xx/429s, Worker runtime limits, oversized payload rejection, client upload interruption, and partial success where STT succeeds but refinement fails. A robust plan should define whether the system returns raw STT on second-pass failure, retries selectively, or falls back locally under broader classes of errors.

[warning] **Security/privacy treatment is too shallow** — “API keys stored as wrangler secrets” is fine for secret storage, but the plan omits client authentication to the Worker entirely. As written, a public endpoint that proxies expensive inference calls is vulnerable to abuse and quota drain. Even for a personal tool, the plan should specify at least a shared secret, signed request, Cloudflare Access, mTLS, or IP/device restriction.

[note] **Sequential vs `Promise.all`** — The implementation summary says `Promise.all` or sequential chaining on the Worker side, but the two Groq passes are causally dependent. They are not parallelizable in the stated design. Keeping `Promise.all` in the plan is misleading and suggests uncertainty about the execution model.

[note] **Model choice rationale is underspecified** — The plan names `llama-3.3-70b-versatile` or `llama-4-scout` for cleanup, but does not define acceptance criteria for when the second pass helps more than it harms. Semantic cleanup can introduce hallucinated “corrections,” especially for code symbols, CLI flags, package names, and mixed Portuguese/English jargon. A narrower constrained post-processor or deterministic replacement pass may be safer for some domains.

[note] **Missing operational constraints** — The plan does not specify expected audio duration, encoding, max request size, concurrency, or whether the client records full utterances before upload versus true streaming. Those details strongly affect whether the latency target is plausible and whether the Worker is even the right choke point.

## **Verdict**: Needs changes

---
