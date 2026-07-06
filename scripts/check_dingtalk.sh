#!/bin/bash
# 检测钉钉（dws CLI）是否已安装并认证

echo "[CHECK] 检测钉钉通道..."

# 检查 dws 是否已安装
if ! command -v dws &>/dev/null; then
    echo "[FAIL] dws CLI 未安装"
    echo "  安装方式：npm install -g dws-cli"
    echo "  安装后执行：dws auth login"
    exit 1
fi

echo "[OK] dws CLI 已安装"

# 检查认证状态
DWS_STATUS=$(dws auth status 2>&1)
if echo "$DWS_STATUS" | grep -qE "(未认证|auth failed|expired|invalid)"; then
    echo "[FAIL] dws 认证已过期或无效"
    echo "  请重新认证：dws auth login"
    exit 1
fi

echo "[OK] dws 认证有效"

# 检查多组织支持
if [ -f "$HOME/.dws-switch.sh" ]; then
    echo "[INFO] 检测到多组织切换脚本：$HOME/.dws-switch.sh"
    echo "  可用组织：$($HOME/.dws-switch.sh status 2>&1 | head -3)"
fi

echo "[PASS] 钉钉通道检测通过"
exit 0
