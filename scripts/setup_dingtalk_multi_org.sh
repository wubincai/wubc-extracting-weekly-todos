#!/bin/bash
# 引导用户配置钉钉多组织
# 用法: setup_dingtalk_multi_org.sh <org1_name> <org1_corp_id> [org2_name] [org2_corp_id] ...

echo "=== 钉钉多组织配置 ==="
echo ""

# 检查 dws 是否已安装
if ! command -v dws &>/dev/null; then
    echo "[ERROR] 请先安装 dws CLI：npm install -g dws-cli"
    exit 1
fi

# 检查参数
if [ $# -lt 2 ] || [ $(($# % 2)) -ne 0 ]; then
    echo "用法: $0 <org1_name> <org1_corp_id> [org2_name] [org2_corp_id] ..."
    echo "示例: $0 nonoil dingxxxxxxx trade dingyyyyyyy"
    exit 1
fi

ORG_DIR="$HOME/.dws"
mkdir -p "$ORG_DIR"

# 逐对处理组织
i=1
while [ $i -lt $# ]; do
    ORG_NAME="${!i}"
    i=$((i + 1))
    CORP_ID="${!i}"
    i=$((i + 1))

    echo ""
    echo "--- 配置组织: $ORG_NAME ---"
    echo "corp_id: $CORP_ID"

    # 提示用户为每个组织单独认证
    echo ""
    echo "请确保当前已登录到 $ORG_NAME 组织。"
    echo "如果未登录，请运行: dws auth login"
    echo "按回车键继续..."
    read -r

    # 保存该组织的 token 备份
    BACKUP_DIR="$ORG_DIR/backup.$ORG_NAME"
    mkdir -p "$BACKUP_DIR"
    cp "$ORG_DIR"/*.token* "$BACKUP_DIR/" 2>/dev/null || true
    cp "$ORG_DIR"/*.json "$BACKUP_DIR/" 2>/dev/null || true

    echo "组织 $ORG_NAME 的 Token 已备份到 $BACKUP_DIR"
    echo "corp_id=$CORP_ID" > "$BACKUP_DIR/org.conf"

    echo "完成: $ORG_NAME"
done

echo ""
echo "=== 多组织配置完成 ==="
echo "组织总数: $((($#) / 2))"
echo ""
echo "建议创建切换脚本，例如 ~/.dws-switch.sh"
