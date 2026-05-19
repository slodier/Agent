#!/bin/bash

BACKEND_URL="https://raw.githubusercontent.com/slodier/Agent/main/backend/AGENTS.md"
FRONTEND_URL="https://raw.githubusercontent.com/slodier/Agent/main/frontend/AGENTS.md"

echo "请选择类型:"
echo "1. 后端"
echo "2. 前端"

read -p "请输入 1 或 2: " choice

if [ "$choice" = "1" ]; then
    URL="$BACKEND_URL"
    TYPE="后端"
elif [ "$choice" = "2" ]; then
    URL="$FRONTEND_URL"
    TYPE="前端"
else
    echo "无效选择"
    exit 1
fi

echo "正在拉取 $TYPE AGENTS.md..."

curl -fsSL "$URL" -o AGENTS.md

if [ $? -ne 0 ]; then
    echo "拉取失败"
    exit 1
fi

cp AGENTS.md CLAUDE.md

echo "完成"
echo "已生成:"
echo "- AGENTS.md"
echo "- CLAUDE.md"
