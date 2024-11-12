#!/bin/bash 
cd /Users/sagiring/tools/hot-fix-helper 
# 启动虚拟环境
source /Users/sagiring/tools/hot-fix-helper/.venv/bin/activate
# 启动脚本
exec /Users/sagiring/tools/hot-fix-helper/.venv/bin/python3 /Users/sagiring/tools/hot-fix-helper/script.py "$@"