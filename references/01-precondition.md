# 前置条件确认流程

## 目录
- 渠道选择交互方式
- 接入检测速查表
- 各渠道配置引导
- 多组织配置
- 输出位置引导
- 通知确认

## 渠道选择交互

向用户展示：

```
请选择需要提取工作信息的渠道（可多选，输入编号，用逗号分隔）：

1. 钉钉
   1.1 钉钉群聊
   1.2 钉钉单聊
2. 飞书
   2.1 飞书云文档
   2.2 飞书妙记录音
   2.3 飞书单聊
   2.4 飞书群聊
3. IMA
   3.1 IMA 知识库
   3.2 IMA 笔记
4. 印象笔记
   4.1 印象笔记笔记
```

用户至少选一个渠道。如未选择，提示"请至少选择一个渠道"。

## 接入检测速查表

| 渠道 | 检测方式 | 判断条件 |
|------|---------|---------|
| 钉钉 | 运行 `dws auth status`，或检测 `~/.dws/` 下配置文件 | 有有效 token 且未过期 |
| 飞书 | 运行 `lark-cli auth check`，或检测 `~/.lark-cli/config.json` | 文件存在且 keychain 中有凭证 |
| IMA | 检测 `~/.config/ima/client_id` 和 `~/.config/ima/api_key` | 两个文件都存在且非空 |
| 印象笔记 | 检测 `~/.codex/skills/yinxiang-skill/.env` 中的 YINXIANG_TOKEN | token 文件存在且非空 |

## 各渠道配置引导

对每个未接入的渠道执行以下引导：

### 钉钉

```
1. 全局安装：npm install -g dws-cli
2. 认证登录：dws auth login
3. 验证状态：dws auth status
```

多组织：见下方单独章节。

### 飞书

```
1. 全局安装：npm install -g lark-cli
2. 认证登录：lark auth login
3. 授权范围：lark auth scope search:message docx:read
```

### IMA

```
1. 从 IMA 开放平台获取 client_id 和 api_key
2. 写入配置文件：
   mkdir -p ~/.config/ima
   echo "client_id={{YOUR_CLIENT_ID}}" > ~/.config/ima/client_id
   echo "api_key={{YOUR_API_KEY}}" > ~/.config/ima/api_key
3. 验证：读取两个文件确认非空
```

### 印象笔记

```
1. 登录印象笔记开发者平台获取 Developer Token
2. 配置 .env 文件：
   YINXIANG_TOKEN={{YOUR_TOKEN}}
   YINXIANG_NOTE_STORE_URL={{YOUR_NOTE_STORE_URL}}
3. 将 .env 放入  ~/.codex/skills/yinxiang-skill/ 目录
```

## 多组织配置（钉钉）

询问："您在钉钉上是否有多个组织（如主公司+子公司）？"

- **是**：
  1. 让用户提供各组织的 corp_id 和认证信息
  2. 每个组织单独保存 token 和切换脚本
  3. 后续搜索时按组织循环执行，每个组织独立做完整性检查
  4. 建议方案：`dws auth switch` 或组织切换脚本（如 `~/.dws-switch.sh`）
- **否**：跳过，默认当前组织

## 输出位置引导

```
请选择周待办事项的保存位置：

1. 飞书云文档（推荐）- 需要 lark-cli 和 docx:write 权限
2. 钉钉文档 - 需要 dws drive 权限
3. IMA 笔记 - 需要 IMA API write 权限
```

用户不选时默认推荐飞书云文档。

## 通知确认

询问："是否要将提取的周待办事项通过钉钉私聊分别发送给各责任人？"

- 是：后续对"团队完成"类事项，通过钉钉发送私聊通知
- 否：跳过

## 配置持久化

配置持久化的核心原则：**用户一经明确，除非用户主动提出修改，否则不再重复询问。**

### 保存内容

保存到 `~/.config/wubc-extracting-weekly-todos/config.json`：

```json
{
  "version": 1,
  "updated_at": "2026-07-06T18:00:00+08:00",
  "dingtalk": {
    "multi_org": true,
    "orgs": [
      {"name": "org1", "corp_id": "dingxxxxxxxxxxxxxxxxxxxxxx"},
      {"name": "org2", "corp_id": "dingyyyyyyyyyyyyyyyyyyyyyy"}
    ]
  },
  "output": {
    "location": "feishu_doc",
    "notify_responsible": true
  },

  "search": {
    "contacts": ["张三", "李四"],
    "groups": ["团队群", "项目群"]
  }
}
```

### 运行时行为

- **配置文件存在** → 静默加载，跳过 1.3~1.5，不向用户确认
- **配置文件不存在** → 走完整 1.1~1.5 流程，完成后保存
- **用户主动说要改**（如"改到飞书文档"）→ 更新对应项后重新保存

### 清除配置

```bash
rm -f ~/.config/wubc-extracting-weekly-todos/config.json
```
