# setups to benchmark

| RTX card    | num | $/h       | VRAM  | MTP | tok/s | KV    | quant |
| ----------- | --- | --------- | ----- | --- | ----- | ----- | ----- |
| 4090 48 GB  | 1   | 0.39-0.59 | 48 GB | 3?  | 65?   | 165K? | fp8   |
| 4090 48 GB  | 1   | 0.39-0.59 | 48 GB | 3?  | 71?   | 550K? | nvfp4 |
| PRO 4000 BW | 2   | 0.49      | 48 GB | 3   | 66.2  | 165K  | fp8   |
| PRO 4000 BW | 2   | 0.49      | 48 GB | 3   | 73?   | 550K? | nvfp4 |
| PRO 5000 BW | 1   | 0.73      | 48 GB | 3?  | 75?   | 165K? | fp8   |
| PRO 5000 BW | 1   | 0.73      | 48 GB | 3?  | 82?   | 550K? | nvfp4 |
| PRO 4000 BW | 3   | 0.66      | 72 GB | 3?  | 60?   | 1M?   | fp8   |
| 5090 BW     | 2   | 0.76      | 64 GB | 3?  | 110?  | 800K? | fp8   |

# command

ssh into instance

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

## 2 RTX PRO 4000, MTP 3, 66tok/s

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
