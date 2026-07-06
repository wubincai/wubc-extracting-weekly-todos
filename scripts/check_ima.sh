#!/bin/bash
# 检测 IMA 通道是否已配置凭证

echo "[CHECK] 检测 IMA 通道..."

CLIENT_ID_FILE="$HOME/.config/ima/client_id"
API_KEY_FILE="$HOME/.config/ima/api_key"

# 检查 client_id
if [ ! -f "$CLIENT_ID_FILE" ]; then
    echo "[FAIL] IMA client_id 未配置"
    echo "  请创建 $CLIENT_ID_FILE 文件"
    echo "  内容格式：{{YOUR_CLIENT_ID}}"
    exit 1
fi

CLIENT_ID=$(cat "$CLIENT_ID_FILE" 2>/dev/null)
if [ -z "$CLIENT_ID" ] || [ "$CLIENT_ID" = "{{YOUR_CLIENT_ID}}" ]; then
    echo "[FAIL] IMA client_id 无效或未配置"
    exit 1
fi
echo "[OK] IMA client_id 已配置"

# 检查 api_key
if [ ! -f "$API_KEY_FILE" ]; then
    echo "[FAIL] IMA api_key 未配置"
    echo "  请创建 $API_KEY_FILE 文件"
    exit 1
fi

API_KEY=$(cat "$API_KEY_FILE" 2>/dev/null)
if [ -z "$API_KEY" ] || [ "$API_KEY" = "{{YOUR_API_KEY}}" ]; then
    echo "[FAIL] IMA api_key 无效或未配置"
    exit 1
fi
echo "[OK] IMA api_key 已配置"

echo "[PASS] IMA 通道检测通过"
exit 0
