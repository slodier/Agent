#!/bin/bash

BACKEND_URL="https://raw.githubusercontent.com/slodier/Agent/main/backend/AGENTS.md"
FRONTEND_URL="https://raw.githubusercontent.com/slodier/Agent/main/frontend/AGENTS.md"
REVIEW_URL="https://raw.githubusercontent.com/slodier/Agent/main/REVIEW.md"
REVIEW_PROMPT_URL="https://raw.githubusercontent.com/slodier/Agent/main/REVIEW_PROMPT.md"

echo "请选择类型:"
echo "1. 后端"
echo "2. 前端"
echo "3. 上线前检查清单 (REVIEW.md)"
echo "4. AI Review Prompt 模板 (REVIEW_PROMPT.md)"

read -p "请输入 1、2、3 或 4: " choice < /dev/tty

if [ "$choice" = "1" ]; then
    echo "正在拉取后端 AGENTS.md..."
    curl -fsSL "$BACKEND_URL" -o AGENTS.md || { echo "拉取失败"; exit 1; }
    cp AGENTS.md CLAUDE.md
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- AGENTS.md"
    echo "- CLAUDE.md"
elif [ "$choice" = "2" ]; then
    echo "正在拉取前端 AGENTS.md..."
    curl -fsSL "$FRONTEND_URL" -o AGENTS.md || { echo "拉取失败"; exit 1; }
    cp AGENTS.md CLAUDE.md
    echo "正在拉取 REVIEW.md..."
    curl -fsSL "$REVIEW_URL" -o REVIEW.md || { echo "拉取失败"; exit 1; }
    echo "正在拉取 REVIEW_PROMPT.md..."
    curl -fsSL "$REVIEW_PROMPT_URL" -o REVIEW_PROMPT.md || { echo "拉取失败"; exit 1; }
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- AGENTS.md"
    echo "- CLAUDE.md"
    echo "- REVIEW.md"
    echo "- REVIEW_PROMPT.md"
elif [ "$choice" = "3" ]; then
    echo "正在拉取 REVIEW.md..."
    curl -fsSL "$REVIEW_URL" -o REVIEW.md || { echo "拉取失败"; exit 1; }
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- REVIEW.md"
elif [ "$choice" = "4" ]; then
    echo "正在拉取 REVIEW_PROMPT.md..."
    curl -fsSL "$REVIEW_PROMPT_URL" -o REVIEW_PROMPT.md || { echo "拉取失败"; exit 1; }
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- REVIEW_PROMPT.md"
else
    echo "无效选择"
    exit 1
fi
