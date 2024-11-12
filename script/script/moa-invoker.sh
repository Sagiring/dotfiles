#!/bin/bash 
cd /Users/sagiring/tools/moa-invoker
# 启动虚拟环境
source /Users/sagiring/tools/moa-invoker/.venv/bin/activate
# 启动脚本
output=$(exec /Users/sagiring/tools/moa-invoker/.venv/bin/python3 /Users/sagiring/tools/moa-invoker/script.py "$@")
echo "$output" | head -n3 
echo "$output" | tail -n +4 | highlight -O xterm256 --syntax json --style catppuccin-Macchiato