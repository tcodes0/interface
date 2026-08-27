# VLLM debug tricks

### logs

use a global redirect on entrypoint

> exec > >(tee -a "$LOG_FILE") 2>&1

then tail log file

> tail -f log_file

use bin/vllm-monitor once openai server is running.

### live nvidia usage

> nvidia-smi dmon -s pucm -d 1

helps on bugs and other issues where things seem stuck and you're wondering if the GPU is being used. 

### view Machine resource usage and process information like CPU usage

> top

> htop

### watch model download

> watch du -sh /workspace/.huggingface

### watch compilation cache

> watch du -sh /workspace/.cache