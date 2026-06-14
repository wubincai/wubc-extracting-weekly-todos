# 前置条件检查与安装引导

首次使用本 Skill 时，先执行前置检查。缺失的工具必须安装并完成授权后才能继续。

## 检查清单

```bash
# 1. 检查 lark-cli
which lark-cli && lark-cli auth status --format json

# 2. 检查 ima-skill（在 Codex 中）
ls ~/.codex/skills/ima-skill/SKILL.md 2>/dev/null
cat ~/.config/ima/client_id ~/.config/ima/api_key 2>/dev/null

# 3. 检查 yinxiang-skill（在 Codex 中）
ls ~/.codex/skills/yinxiang-skill/SKILL.md 2>/dev/null
cat ~/.codex/skills/yinxiang-skill/.env 2>/dev/null

# 4. 检查本地文件夹配置
echo ${REFERENCES_DIR:-"未配置"}
```

## 安装引导

### 1. lark-cli

```bash
# 安装
npm install -g @larksuiteoapp/cli

# 授权（需要飞书账号扫码）
lark-cli auth login

# 添加必要权限
lark-cli auth login --scope "search:message contact:user.basic_profile:readonly minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read"
```

> 授权时会输出一个验证 URL，需要在浏览器中打开完成授权。若使用 headless 环境，使用 `lark-cli auth login --no-wait --json` 获取 device_code 和验证 URL，展示给用户扫码。

### 2. ima-skill

在 Codex 中安装 ima-skill，并按 ima-skill 的配置文档完成 IMA OpenAPI 凭证设置：

```bash
# 安装
# 通过 Codex 技能安装渠道安装 ima-skill

# 配置 IMA OpenAPI 凭证
mkdir -p ~/.config/ima
echo "<your_ima_client_id>" > ~/.config/ima/client_id
echo "<your_ima_api_key>" > ~/.config/ima/api_key
```

### 3. yinxiang-skill（印象笔记）

在 Codex 中安装 yinxiang-skill，然后完成 OAuth 授权：

1. 访问 https://app.yinxiang.com/third/skills-oauth/ 完成授权
2. 将获取到的 Token 保存到技能目录：

```bash
mkdir -p ~/.codex/skills/yinxiang-skill
cat > ~/.codex/skills/yinxiang-skill/.env << CONFIGEOF
YX_AUTH_TOKEN=<你的Token>
CONFIGEOF
```

### 4. 本地文件夹路径配置

在 shell 配置文件（如 `~/.zshrc` 或 `~/.bashrc`）中设置：

```bash
# 设置要扫描的本地文件夹路径，多个路径用冒号分隔
export REFERENCES_DIR="$HOME/Documents/work:$HOME/Desktop/projects"
```

## 授权检查结果

| 项目 | 检查命令 | 预期结果 |
|------|---------|---------|
| lark-cli 已安装 | `which lark-cli` | 显示路径 |
| lark-cli 已授权 | `lark-cli auth status` | 显示用户信息 |
| ima-skill 已安装 | `ls ~/.codex/skills/ima-skill/` | 目录存在 |
| IMA 凭证已配置 | `cat ~/.config/ima/client_id` | 有内容 |
| yinxiang-skill 已安装 | `ls ~/.codex/skills/yinxiang-skill/` | 目录存在 |
| 印象笔记 Token 已配置 | `cat ~/.codex/skills/yinxiang-skill/.env` | 包含 YX_AUTH_TOKEN |
| 本地文件夹已配置 | `echo $REFERENCES_DIR` | 非空 |

## 注意事项

- 首次使用必须**逐项检查**，缺失一项都不应跳过
- 授权后记得重启 Codex 使新 Skills 生效
- 各 CLI/Skill 的详细安装文档请参考对应项目的官方说明
