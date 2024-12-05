#!/bin/bash 
cd /Users/sagiring/tools/log_hunter
# 启动虚拟环境
source /Users/sagiring/tools/log_hunter/.venv/bin/activate
# 启动脚本
exec /Users/sagiring/tools/log_hunter/.venv/bin/python3 /Users/sagiring/tools/log_hunter/script.py "$@"