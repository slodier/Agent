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

read -r -p "请输入 1、2、3、4 或 5: " choice < /dev/tty || { echo "无法读取选择, 请在交互终端运行"; exit 1; }

case "$choice" in
    1|2|3|4|5) ;;
    *) echo "无效选择"; exit 1 ;;
esac

TMP_DIR=$(mktemp -d) || { echo "创建临时目录失败"; exit 1; }
trap 'rm -rf "$TMP_DIR"' EXIT

fetch() {
    echo "正在拉取 $2..."
    curl -fsSL "$1" -o "$TMP_DIR/$2" || { echo "拉取失败, 未写入目标文件"; exit 1; }
    [ -s "$TMP_DIR/$2" ] || { echo "下载文件为空, 未写入目标文件"; exit 1; }
}

case "$choice" in
    1) fetch "$BACKEND_URL" AGENTS.md ;;
    2) fetch "$FRONTEND_URL" AGENTS.md ;;
    5)
        fetch "$BACKEND_URL" backend.md
        fetch "$FRONTEND_URL" frontend.md
        # 公共 Skills 与工作流保留后端版本, 前端技术规则从 Vue3 起合并.
        grep -q '^# Vue3$' "$TMP_DIR/frontend.md" || { echo "前端规则缺少 Vue3 标题, 无法合并"; exit 1; }
        { cat "$TMP_DIR/backend.md"; printf '\n---\n\n'; sed -n '/^# Vue3$/,$p' "$TMP_DIR/frontend.md"; } > "$TMP_DIR/AGENTS.md" || exit 1
        ;;
esac

case "$choice" in
    2|3|5) fetch "$REVIEW_URL" REVIEW.md ;;
esac
case "$choice" in
    2|4|5) fetch "$REVIEW_PROMPT_URL" REVIEW_PROMPT.md ;;
esac
case "$choice" in
    1|2|5) printf '@AGENTS.md\n' > "$TMP_DIR/CLAUDE.md" || exit 1 ;;
esac

# 写入前检查全部目标, 拒绝目录和符号链接, 避免覆盖其他位置.
[ -w . ] || { echo "当前目录不可写"; exit 1; }
for file in AGENTS.md CLAUDE.md REVIEW.md REVIEW_PROMPT.md; do
    [ -f "$TMP_DIR/$file" ] || continue
    if [ -L "$file" ] || { [ -e "$file" ] && { [ ! -f "$file" ] || [ ! -w "$file" ]; }; }; then
        echo "目标 $file 不是可写普通文件, 未写入目标文件"
        exit 1
    fi
done

# 全部下载和检查成功后, 先备份所有已有文件再写入.
for file in AGENTS.md CLAUDE.md REVIEW.md REVIEW_PROMPT.md; do
    [ -f "$TMP_DIR/$file" ] || continue
    if [ -e "$file" ]; then
        backup=$(mktemp "./${file}.backup.XXXXXX") || exit 1
        cp -p "$file" "$backup" || exit 1
        echo "已备份: $backup"
    fi
done

for file in AGENTS.md CLAUDE.md REVIEW.md REVIEW_PROMPT.md; do
    [ -f "$TMP_DIR/$file" ] || continue
    cp "$TMP_DIR/$file" "$file" || { echo "写入 $file 失败, 请使用上述备份恢复已更新文件"; exit 1; }
    echo "已生成: $file"
done
echo "完成"
