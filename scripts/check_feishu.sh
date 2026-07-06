#!/bin/bash
# 检测飞书（lark-cli）是否已安装并认证

echo "[CHECK] 检测飞书通道..."

# 检查 lark-cli 是否已安装
if ! command -v lark-cli &>/dev/null; then
    echo "[FAIL] lark-cli 未安装"
    echo "  安装方式：npm install -g lark-cli"
    echo "  安装后执行：lark auth login"
    exit 1
fi

echo "[OK] lark-cli 已安装"

# 检查认证状态
LARK_STATUS=$(lark-cli auth check 2>&1)
if echo "$LARK_STATUS" | grep -qE "(未认证|auth failed|expired|invalid)"; then
    echo "[FAIL] lark-cli 认证已过期或无效"
    echo "  请重新认证：lark auth login"
    exit 1
fi

echo "[OK] lark-cli 认证有效"

# 检查授权范围
echo "[INFO] 当前授权范围："
lark-cli auth scope 2>&1 | head -10

echo "[PASS] 飞书通道检测通过"
exit 0
