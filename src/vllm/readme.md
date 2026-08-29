# VLLM debug tricks

### logs

use a global redirect on entrypoint

exec > >(tee -a "$LOG_FILE") 2>&1

then tail newest log file

tail -f $(find /workspace/logs | sort -r | head -1)

use bin/vllm-monitor once openai server is running.

### live nvidia usage

nvidia-smi dmon -s pucm -d 1

helps on bugs and other issues where things seem stuck and you're wondering if the GPU is being used.

### view Machine resource usage and process information like CPU usage

top

htop

### watch model download

watch -n 1 du -sh /workspace/.huggingface

### watch compilation cache

watch -n 1 du -sh /workspace/.cache

### inspect cache for size

du -h --max-depth=2 /workspace/.cache | sort -h

### zip cache for download

tar -cf /workspace/cache.tar -C /workspace/.cache triton vllm/torch_compile_cache

### rsync to host machine

rsync -ah --info=progress2 -e "ssh -p <port>" root@<ip>:/workspace/cache.tar ./src/vllm/qwen35/.cache
