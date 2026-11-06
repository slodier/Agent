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
echo "5. 前后端综合（在后端目录下同时开发后台/小程序）"

read -p "请输入 1、2、3、4 或 5: " choice < /dev/tty

if [ "$choice" = "1" ]; then
    echo "正在拉取后端 AGENTS.md..."
    curl -fsSL "$BACKEND_URL" -o AGENTS.md || { echo "拉取失败"; exit 1; }
    printf '@AGENTS.md\n' > CLAUDE.md
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- AGENTS.md"
    echo "- CLAUDE.md"
elif [ "$choice" = "2" ]; then
    echo "正在拉取前端 AGENTS.md..."
    curl -fsSL "$FRONTEND_URL" -o AGENTS.md || { echo "拉取失败"; exit 1; }
    printf '@AGENTS.md\n' > CLAUDE.md
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
elif [ "$choice" = "5" ]; then
    TMP_DIR=$(mktemp -d) || { echo "创建临时目录失败"; exit 1; }
    trap 'rm -rf "$TMP_DIR"' EXIT
    echo "正在拉取后端 AGENTS.md..."
    curl -fsSL "$BACKEND_URL" -o "$TMP_DIR/backend.md" || { echo "拉取失败"; exit 1; }
    echo "正在拉取前端 AGENTS.md..."
    curl -fsSL "$FRONTEND_URL" -o "$TMP_DIR/frontend.md" || { echo "拉取失败"; exit 1; }
    # 后端全文（含工作流）+ 前端从 "# Vue3" 起的技术规则，工作流只保留一份
    grep -q '^# Vue3$' "$TMP_DIR/frontend.md" || { echo "前端 AGENTS.md 缺少 '# Vue3' 标题，无法合并"; exit 1; }
    { cat "$TMP_DIR/backend.md"; printf '\n---\n\n'; sed -n '/^# Vue3$/,$p' "$TMP_DIR/frontend.md"; } > AGENTS.md
    printf '@AGENTS.md\n' > CLAUDE.md
    echo "正在拉取 REVIEW.md..."
    curl -fsSL "$REVIEW_URL" -o REVIEW.md || { echo "拉取失败"; exit 1; }
    echo "正在拉取 REVIEW_PROMPT.md..."
    curl -fsSL "$REVIEW_PROMPT_URL" -o REVIEW_PROMPT.md || { echo "拉取失败"; exit 1; }
    echo ""
    echo "完成"
    echo "已生成:"
    echo "- AGENTS.md（后端 + 前端规则）"
    echo "- CLAUDE.md"
    echo "- REVIEW.md"
    echo "- REVIEW_PROMPT.md"
else
    echo "无效选择"
    exit 1
fi
