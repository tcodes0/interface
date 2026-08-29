# Qwen/Qwen3.8-27B benchmarks

| n   | RTX card    | $/h  | VRAM  | MTP | tok/s | KV   | quant   | status | competitive    |
| --- | ----------- | ---- | ----- | --- | ----- | ---- | ------- | ------ | -------------- |
| 2   | PRO 4000 BW | 0.49 | 48 GB | 3   | 66    | 165K | fp8     | done   | no, slow       |
| 2   | PRO 4000 BW | 0.49 | 48 GB | 3   | 75    | 432K | nvfp4   | done   | yes, cost      |
| 1   | 4090 48 GB  | 0.59 | 48 GB | 3   | 72    | 514K | nvfp4   | done   | maybe          |
| 1   | 4090 48 GB  | 0.59 | 48 GB | 4   | 85    | 498K | awqint4 | done   | no, quality    |
| 1   | PRO 5000 BW | 0.73 | 48 GB | 5   | 83    | 417K | nvfp4   | done   | no, same price |
| 2   | 5090 BW     | 0.76 | 64 GB | 4   | 91    | 480K | fp8     | done   | yes, best ⭐    |

### todo

4090 nvfp4 mtp 4
4000 nvfp4 mtp 4
--speculative-config '{"method":"dflash","model":"incoai/Qwen3.8-27B-DFlash2","num_speculative_tokens":7}'

# command

ssh into instance

```
vllm bench serve \
  --base-url http://127.0.0.1:8000 \
  --model "$VLLM_MODEL_NAME" \
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

Output token throughput (tok/s): 61.58
Mean TTFT (ms): 1437.58
Acceptance rate (%): 71.04
Acceptance length: 2.42
Per-position acceptance (%):
Position 0: 76.18
Position 1: 65.89

## unsloth/Qwen3.8-27B-NVFP4 RTX 4090 48Gb, MTP 3, 72tok/s, 514K

Output token throughput (tok/s): 72.03
Mean TTFT (ms): 1389.47
Acceptance rate (%): 66.11
Acceptance length: 2.98
Per-position acceptance (%):
Position 0: 77.93
Position 1: 64.58
Position 2: 55.83

## cyankiwi/Qwen3.6-27B-AWQ-INT4 RTX 4090 48Gb, MTP 3, 82tok/s, 511K

Output token throughput (tok/s): 82.01
Mean TTFT (ms): 1564.14
Acceptance rate (%): 73.40
Acceptance length: 3.20
Per-position acceptance (%):
Position 0: 84.44
Position 1: 72.58
Position 2: 63.18

## cyankiwi/Qwen3.6-27B-AWQ-INT4 RTX 4090 48Gb, MTP 4, 85tok/s, 498K

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  241.50
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.08
Output token throughput (tok/s):         84.80
Peak output token throughput (tok/s):    28.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          424.01
---------------Time to First Token----------------
Mean TTFT (ms):                          1598.19
Median TTFT (ms):                        1528.49
P99 TTFT (ms):                           2725.34
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          10.24
Median TPOT (ms):                        10.63
P99 TPOT (ms):                           13.04
---------------Inter-token Latency----------------
Mean ITL (ms):                           36.75
Median ITL (ms):                         36.60
P99 ITL (ms):                            38.77
---------------Speculative Decoding---------------
Acceptance rate (%):                     64.85
Acceptance length:                       3.59
Drafts:                                  5701
Draft tokens:                            22804
Accepted tokens:                         14789
Per-position acceptance (%):
  Position 0:                            86.35
  Position 1:                            69.53
  Position 2:                            58.60
  Position 3:                            44.92
==================================================
```

## unsloth/Qwen3.8-27B-NVFP4 RTX 5000 48Gb, MTP 3, 78tok/s, 433K

Output token throughput (tok/s): 78.09
Mean TTFT (ms): 820.51
Acceptance length: 3.16
Acceptance rate (%): 71.86
Per-position acceptance (%):
Position 0: 79.46
Position 1: 71.14
Position 2: 64.98

## unsloth/Qwen3.8-27B-NVFP4 RTX 5000 48Gb, MTP 5, 83tok/s, 417K

```
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  245.96
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.08
Output token throughput (tok/s):         83.27
Peak output token throughput (tok/s):    26.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          416.33
---------------Time to First Token---------------
Mean TTFT (ms):                          786.59
Median TTFT (ms):                        673.76
P99 TTFT (ms):                           2505.38
-----Time per Output Token (excl. 1st token)-----
Mean TPOT (ms):                          11.25
Median TPOT (ms):                        10.33
P99 TPOT (ms):                           18.53
---------------Inter-token Latency---------------
Mean ITL (ms):                           40.80
Median ITL (ms):                         40.78
P99 ITL (ms):                            43.49
---------------Speculative Decoding--------------
Acceptance rate (%):                     52.68
Acceptance length:                       3.63
Drafts:                                  5643
Draft tokens:                            28215
Accepted tokens:                         14864
Per-position acceptance (%):
  Position 0:                            73.12
  Position 1:                            59.33
  Position 2:                            49.28
  Position 3:                            42.94
  Position 4:                            38.74
```

## Qwen/Qwen3.8-27B-FP8 2 RTX 5090, MTP 3, 72tok/s, 550K

Output token throughput (tok/s): 72.10
Mean TTFT (ms): 2168.54
Mean TPOT (ms): 11.76
Mean ITL (ms): 36.00
Acceptance rate (%): 68.81
Acceptance length: 3.06
Per-position acceptance (%):
Position 0: 76.56
Position 1: 68.76
Position 2: 61.10

## Qwen/Qwen3.8-27B-FP8 2 RTX 5090, MTP 5, 90tok/s, 492K

Output token throughput (tok/s): 90.29
Mean TTFT (ms): 1342.35
Mean TPOT (ms): 9.77
Mean ITL (ms): 32.36
Acceptance rate (%): 46.35
Acceptance length: 3.32
Per-position acceptance (%):
Position 0: 59.76
Position 1: 51.28
Position 2: 44.69
Position 3: 39.32
Position 4: 36.70

## Qwen/Qwen3.8-27B-FP8 2 RTX 5090, MTP 4, 91tok/s, 480K

```
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  225.30
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.09
Output token throughput (tok/s):         90.90
Peak output token throughput (tok/s):    33.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          454.50
---------------Time to First Token----------------
Mean TTFT (ms):                          2505.14
Median TTFT (ms):                        2455.52
P99 TTFT (ms):                           3440.77
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          8.56
Median TPOT (ms):                        7.80
P99 TPOT (ms):                           11.87
---------------Inter-token Latency----------------
Mean ITL (ms):                           32.06
Median ITL (ms):                         31.57
P99 ITL (ms):                            35.69
---------------Speculative Decoding---------------
Acceptance rate (%):                     68.80
Acceptance length:                       3.75
Drafts:                                  5464
Draft tokens:                            21856
Accepted tokens:                         15037
Per-position acceptance (%):
  Position 0:                            84.35
  Position 1:                            74.34
  Position 2:                            62.76
  Position 3:                            53.75
==================================================
```
