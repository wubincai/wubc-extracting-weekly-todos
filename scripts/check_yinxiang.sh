#!/bin/bash
# 检测印象笔记通道是否已配置

echo "[CHECK] 检测印象笔记通道..."

ENV_FILE="$HOME/.codex/skills/yinxiang-skill/.env"

# 检查 .env 文件是否存在
if [ ! -f "$ENV_FILE" ]; then
    echo "[FAIL] 印象笔记凭证文件未找到"
    echo "  请创建 $ENV_FILE 文件"
    echo "  配置方式："
    echo "    YINXIANG_TOKEN={{YOUR_TOKEN}}"
    echo "    YINXIANG_NOTE_STORE_URL={{YOUR_NOTE_STORE_URL}}"
    exit 1
fi

# 检查 YINXIANG_TOKEN
if ! grep -q "YINXIANG_TOKEN" "$ENV_FILE" 2>/dev/null; then
    echo "[FAIL] 印象笔记 Token 未配置"
    exit 1
fi

TOKEN=$(grep "YINXIANG_TOKEN" "$ENV_FILE" | cut -d= -f2 2>/dev/null)
if [ -z "$TOKEN" ] || [ "$TOKEN" = "{{YOUR_TOKEN}}" ]; then
    echo "[FAIL] 印象笔记 Token 无效"
    exit 1
fi
echo "[OK] 印象笔记 Token 已配置"

echo "[PASS] 印象笔记通道检测通过"
exit 0
