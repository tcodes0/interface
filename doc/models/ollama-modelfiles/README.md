# Ollama Custom Modelfiles

KV cache quantization and flash attention are global via systemd:

OLLAMA_FLASH_ATTENTION=1
OLLAMA_KV_CACHE_TYPE=q8_0

## Create all

```bash
cd /path/to/scratchpad/modelfiles
for f in $(ls | grep -v README); do ollama create "$f" -f "$f"; done
```

## Models

| Modelfile             | Base                | ctx  | Native | Notes                                                                                  |
| --------------------- | ------------------- | ---- | ------ | -------------------------------------------------------------------------------------- |
| granite3.1dense8b128k | granite3.1-dense:8b | 128k | 128k   | GQA 4:1 — sidekick candidate                                                           |
| llama318b128k         | llama3.1:8b         | 128k | 128k   | GQA 4:1                                                                                |
| yicoder9b128k         | yi-coder:9b         | 128k | 128k   | GQA 8:1 — most efficient KV cache                                                      |
| deepseekr114b64k      | deepseek-r1:14b     | 64k  | 128k   | capped, 8GB weights                                                                    |
| gptoss20b128k         | gpt-oss:20b         | 128k | 128k   | 12GB weights, confirmed stable at 128k                                                 |
| mistralnemo12b64k     | mistral-nemo:12b    | 64k  | 1M     | capped, 7GB weights                                                                    |
| qwen3564k             | qwen3.5:9b          | 64k  | 256k   | capped, SSM hybrid arch                                                                |
| ministral14b64k       | ministral-3:14b     | 64k  | 256k   | capped, 8GB weights                                                                    |
| rnj18b32k             | rnj-1:8b            | 32k  | 32k    | hard native cap, gemma3 arch                                                           |
| falcon310b32k         | falcon3:10b         | 32k  | 32k    | hard native cap                                                                        |
| gemma426b128k         | gemma4:26b          | 128k | 256k   | MoE 128e/8, SWA — requires Firefox GPU off + KWin software rendering + whisper stopped |
| gemma426b96k          | gemma4:26b          | 96k  | 256k   | MoE 128e/8, SWA — stable with Firefox GPU off + KWin software rendering                |
| gemma426b64k          | gemma4:26b          | 64k  | 256k   | MoE 128e/8, SWA — stable with Firefox GPU off only                                     |
| gemma426b32k          | gemma4:26b          | 32k  | 256k   | MoE 128e/8, SWA — conservative fallback                                                |

## Skipped

- **solar:10.7b** — native 4096, already at max, no modelfile needed

## VRAM notes (RX 7900 XT, 20GB)

- gemma4:26b weights consume ~16.7GB leaving ~3.3GB headroom
- KV cache scales cheaply due to SWA (most layers capped at 1024 token window):
  - 4k ctx → 0.5 GiB KV
  - 64k ctx → 1.1 GiB KV
  - 96k ctx → 1.5 GiB KV
  - 128k ctx → ~1.8 GiB KV
- Crash threshold: GPU MODE1 reset when VRAM spike during load exceeds ~20GB
- VRAM reclaim steps (each frees ~300-400MB):
  1. Firefox: disable hardware acceleration
  2. KWin: KWIN_SOFTWARERENDERING=1 via plasma-kwin_wayland.service
  3. whisper.cpp: stop service before loading 128k
