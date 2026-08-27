# setups to benchmark

| RTX card    | num | $/h       | VRAM  | MTP | tok/s | KV    | quant | status |
| ----------- | --- | --------- | ----- | --- | ----- | ----- | ----- | ------ |
| 4090 48 GB  | 1   | 0.39-0.59 | 48 GB | 3?  | 65?   | 165K? | fp8   | skip   |
| 4090 48 GB  | 1   | 0.39-0.59 | 48 GB | 3?  | 71?   | 550K? | nvfp4 | todo   |
| PRO 4000 BW | 2   | 0.49      | 48 GB | 3   | 66.2  | 165K  | fp8   | done   |
| PRO 4000 BW | 2   | 0.49      | 48 GB | 3   | 75    | 432K  | nvfp4 | done   |
| PRO 4000 BW | 3   | 0.66      | 72 GB | 3?  | 60?   | 1M?   | fp8   | skip   |
| PRO 5000 BW | 1   | 0.73      | 48 GB | 3?  | 75?   | 165K? | fp8   | skip   |
| PRO 5000 BW | 1   | 0.73      | 48 GB | 3?  | 82?   | 550K? | nvfp4 | todo   |
| 5090 BW     | 2   | 0.76      | 64 GB | 3?  | 110?  | 800K? | fp8   | todo   |

# command

ssh into instance

```
vllm bench serve \
  --base-url http://127.0.0.1:8000 \
  --model unsloth/Qwen3.8-27B-NVFP4 \
  --num-prompts 20 \
  --random-input-len 4096 \
  --random-output-len 1024 \
  --max-concurrency 1 \
  --header "Authorization=Bearer $VLLM_API_KEY" \
  --temperature 1.0 \
  --top-p 0.95 \
  --top-k 20
```

## Qwen/Qwen3.8-27B-FP8 2 RTX PRO 4000, MTP 3, 66tok/s, 165K

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

## unsloth/Qwen3.8-27B-NVFP4 2 RTX PRO 4000, MTP 3, 75tok/s, 432K

GPU utilization 92%
MTP 2: 10% slower, despite higher acceptance. same acceptance length.

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  266.90
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.07
Output token throughput (tok/s):         76.73
Peak output token throughput (tok/s):    30.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          383.66
---------------Time to First Token----------------
Mean TTFT (ms):                          1300.93
Median TTFT (ms):                        1278.11
P99 TTFT (ms):                           1560.32
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          11.77
Median TPOT (ms):                        9.54
P99 TPOT (ms):                           27.94
---------------Inter-token Latency----------------
Mean ITL (ms):                           34.32
Median ITL (ms):                         34.24
P99 ITL (ms):                            35.64
---------------Speculative Decoding---------------
Acceptance rate (%):                     63.97
Acceptance length:                       2.92
Drafts:                                  7018
Draft tokens:                            21054
Accepted tokens:                         13469
Per-position acceptance (%):
  Position 0:                            72.87
  Position 1:                            62.95
  Position 2:                            56.10
==================================================
```

## unsloth/Qwen3.8-27B-NVFP4 RTX 4090 48Gb, MTP 2, 61tok/s, 522K

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  332.58
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.06
Output token throughput (tok/s):         61.58
Peak output token throughput (tok/s):    29.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          307.89
---------------Time to First Token----------------
Mean TTFT (ms):                          1437.58
Median TTFT (ms):                        1323.61
P99 TTFT (ms):                           3214.02
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          14.85
Median TPOT (ms):                        13.45
P99 TPOT (ms):                           29.19
---------------Inter-token Latency----------------
Mean ITL (ms):                           35.92
Median ITL (ms):                         35.87
P99 ITL (ms):                            37.72
---------------Speculative Decoding---------------
Acceptance rate (%):                     71.04
Acceptance length:                       2.42
Drafts:                                  8459
Draft tokens:                            16918
Accepted tokens:                         12018
Per-position acceptance (%):
  Position 0:                            76.18
  Position 1:                            65.89
==================================================
```

## unsloth/Qwen3.8-27B-NVFP4 RTX 4090 48Gb, MTP 3, 72tok/s, 514K

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  284.33
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.07
Output token throughput (tok/s):         72.03
Peak output token throughput (tok/s):    28.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          360.14
---------------Time to First Token----------------
Mean TTFT (ms):                          1389.47
Median TTFT (ms):                        1333.93
P99 TTFT (ms):                           2278.44
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          12.54
Median TPOT (ms):                        10.85
P99 TPOT (ms):                           24.92
---------------Inter-token Latency----------------
Mean ITL (ms):                           37.35
Median ITL (ms):                         37.29
P99 ITL (ms):                            39.14
---------------Speculative Decoding---------------
Acceptance rate (%):                     66.11
Acceptance length:                       2.98
Drafts:                                  6869
Draft tokens:                            20607
Accepted tokens:                         13624
Per-position acceptance (%):
  Position 0:                            77.93
  Position 1:                            64.58
  Position 2:                            55.83
==================================================
```