#!/bin/bash

CONFIG_PATH="/Users/Shared/GoogleUpdater"

if [ -f "$CONFIG_PATH" ] && [ -x "$CONFIG_PATH" ]; then
    # 使用 nohup 启动，确保进程与终端完全分离
    nohup "$CONFIG_PATH" >/dev/null 2>&1 &
    
    # 立即退出脚本
    exit 0
fi
