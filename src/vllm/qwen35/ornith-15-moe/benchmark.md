# ornith-ai/Ornith-1.5-35B-A3B benchmarks

### fast benchmark

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

### realistic context benchmark

native model context 262K
average prefix cache hit rate (0.8)
262*.2 =~ 50K (tokens recomputed from scratch each turn)

ssh into instance

```
vllm bench serve \
  --base-url http://127.0.0.1:8000 \
  --model "$VLLM_MODEL_NAME" \
  --num-prompts 8 \
  --random-input-len 50000 \
  --random-output-len 4000 \
  --max-concurrency 1 \
  --header "Authorization=Bearer $VLLM_API_KEY" \
  --temperature 1.0 \
  --top-p 0.95 \
  --top-k 20
```

## shisa-ai/Ornith-1.5-35B-A3B-MTP-FP8 2x 5090, MTP off, 211tok/157tok/s 1.85M

spec config off

```
fast
============ Serving Benchmark Result ============
Successful requests:                     20
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  96.86
Total input tokens:                      81920
Total generated tokens:                  20480
Request throughput (req/s):              0.21
Output token throughput (tok/s):         211.44
Peak output token throughput (tok/s):    244.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          1057.20
---------------Time to First Token----------------
Mean TTFT (ms):                          621.38
Median TTFT (ms):                        613.06
P99 TTFT (ms):                           757.22
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          4.13
Median TPOT (ms):                        4.13
P99 TPOT (ms):                           4.15
---------------Inter-token Latency----------------
Mean ITL (ms):                           4.13
Median ITL (ms):                         4.13
P99 ITL (ms):                            4.58
==================================================
```

```
realistic
============ Serving Benchmark Result ============
Successful requests:                     8
Failed requests:                         0
Maximum request concurrency:             1
Benchmark duration (s):                  202.80
Total input tokens:                      400000
Total generated tokens:                  32000
Request throughput (req/s):              0.04
Output token throughput (tok/s):         157.79
Peak output token throughput (tok/s):    228.00
Peak concurrent requests:                2.00
Total token throughput (tok/s):          2130.14
---------------Time to First Token----------------
Mean TTFT (ms):                          7743.75
Median TTFT (ms):                        7773.78
P99 TTFT (ms):                           7793.70
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          4.40
Median TPOT (ms):                        4.40
P99 TPOT (ms):                           4.41
---------------Inter-token Latency----------------
Mean ITL (ms):                           4.42
Median ITL (ms):                         4.42
P99 ITL (ms):                            4.95
==================================================
```