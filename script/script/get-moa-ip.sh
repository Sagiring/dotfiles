#!/bin/bash 
cd /Users/sagiring/tools/moa-invoker
# 启动虚拟环境
source /Users/sagiring/tools/moa-invoker/.venv/bin/activate
# 启动脚本
exec /Users/sagiring/tools/moa-invoker/.venv/bin/python3 /Users/sagiring/tools/moa-invoker/moa_ip_script.py $@
