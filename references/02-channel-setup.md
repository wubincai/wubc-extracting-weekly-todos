# 各渠道接入检测 & 配置引导

## 目录
- 钉钉接入检测
- 飞书接入检测
- IMA 接入检测
- 印象笔记接入检测
- 多组织钉钉配置详解

## 钉钉接入检测

检测命令：
```bash
dws auth status
```

检测文件和目录：
- `~/.dws/` 目录是否存在
- `~/.dws-switch.sh` 是否存在（多组织）

判断条件：`dws auth status` 返回成功且有有效 token。

如果失败，检查：
1. dws 是否已全局安装：`which dws`
2. 是否已认证：`dws auth login`
3. token 是否过期：查看 refresh_token 有效期

配置引导：
```
npm install -g dws-cli
dws auth login
```

## 飞书接入检测

检测命令：
```bash
lark-cli auth check
```

检测文件和目录：
- `~/.lark-cli/config.json` 是否存在
- macOS Keychain 中是否有飞书凭证

判断条件：检测命令返回成功且 token 未过期。

如果失败，检查：
1. lark-cli 是否已全局安装：`which lark-cli`
2. 是否已认证：`lark auth login`
3. 授权范围是否足够

配置引导：
```
npm install -g lark-cli
lark auth login
lark auth scope search:message docx:read minutes:read
```

## IMA 接入检测

检测文件：
- `~/.config/ima/client_id`
- `~/.config/ima/api_key`

检测命令（验证凭证是否有效）：
```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "X-Client-Id: $(cat ~/.config/ima/client_id)" \
  -H "X-Api-Key: $(cat ~/.config/ima/api_key)" \
  "https://ima-api.example.com/notes?limit=1"
```

判断条件：HTTP 200。

如果失败，引导用户：
1. 前往 IMA 开放平台获取 client_id 和 api_key
2. 创建配置目录和文件

配置引导：
```bash
mkdir -p ~/.config/ima
echo "{{YOUR_CLIENT_ID}}" > ~/.config/ima/client_id
echo "{{YOUR_API_KEY}}" > ~/.config/ima/api_key
```

## 印象笔记接入检测

检测文件：
- `~/.codex/skills/yinxiang-skill/.env`

检测命令：
```bash
grep -q "YINXIANG_TOKEN" ~/.codex/skills/yinxiang-skill/.env 2>/dev/null && echo "OK" || echo "MISSING"
```

判断条件：.env 文件存在且包含 YINXIANG_TOKEN。

如果失败，引导用户：
1. 登录印象笔记开发者平台 https://dev.yinxiang.com/
2. 获取 Developer Token
3. 获取 Note Store URL
4. 写入 .env 文件

配置引导：
```bash
mkdir -p ~/.codex/skills/yinxiang-skill
cat > ~/.codex/skills/yinxiang-skill/.env << ENVEOF
YINXIANG_TOKEN={{YOUR_TOKEN}}
YINXIANG_NOTE_STORE_URL={{YOUR_NOTE_STORE_URL}}
ENVEOF
```

## 多组织钉钉配置详解

多组织场景需要为每个组织单独保存认证信息。

### 切换方案

推荐使用组织切换脚本，如：
```bash
# ~/.dws-switch.sh
# usage: ~/.dws-switch.sh <org-alias>

case "$1" in
  org1)
    cp ~/.dws.backup.org1/* ~/.dws/
    ;;
  org2)
    cp ~/.dws.backup.org2/* ~/.dws/
    ;;
  status)
    dws auth status
    ;;
esac
```

### 切换后等待

切换组织后等待约 1 秒让缓存清理完成，再执行后续命令。

### corp_id 信息

用户需要提供每个组织的 corp_id，格式示例：
```
org1: dingxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
org2: dingyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

保存到 `~/.dws/orgs.json` 或类似配置文件中。
