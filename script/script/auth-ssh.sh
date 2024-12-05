#!/bin/bash 
cd /Users/sagiring/tools/auth-ssh
# 启动虚拟环境
source /Users/sagiring/tools/auth-ssh/.venv/bin/activate
# 启动脚本
exec /Users/sagiring/tools/auth-ssh/.venv/bin/python3 /Users/sagiring/tools/auth-ssh/auth_ssh.py "$@" 