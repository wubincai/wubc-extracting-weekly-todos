---
name: wubc-extracting-weekly-todos
description: 每周自动从飞书、IMA知识库、印象笔记、本地文件夹中提取近一周的工作记录，按规则筛选出下周待办事项并写入飞书云文档。当用户说"更新待办事项"、"下周计划"、"工作计划"、"周报"、"下周待办"、"提取待办"、"每周待办"时触发。
---

# 每周待办提取

从飞书（妙记+云文档）、IMA知识库、印象笔记、本地文件夹中按时间发现近一周有变动的工作记录，逐条分析并提取下周待办事项，汇总写入飞书云文档。所有采集步骤均按"按时间发现，不按关键词过滤"的原则执行。

## 工作流

复制此检查清单并跟踪进度：

```
提取进度：
- [ ] 步骤 1: 前置检查（工具/Skill/凭证）
- [ ] 步骤 2: 飞书采集（妙记 + 云文档）
- [ ] 步骤 3: IMA知识库采集
- [ ] 步骤 4: 印象笔记采集（GUID去重）
- [ ] 步骤 5: 本地文件夹扫描
- [ ] 步骤 6: 合并去重 → 提取待办
- [ ] 步骤 7: 写入飞书云文档
```

## 前置条件

执行前检查以下工具/Skill 是否已安装并完成授权。详细安装指引见 `references/01-prerequisites.md`。

| 工具/Skill | 用途 | 首次使用需 |
|-----------|------|-----------|
| lark-cli | 飞书 API 调用 | 安装 + 扫码授权 |
| ima-skill | IMA 知识库笔记操作 | Codex 内安装 + 配置 OpenAPI 凭证 |
| yinxiang-skill | 印象笔记操作 | Codex 内安装 + OAuth 授权 |
| textutil | 本地 .docx 转文本 | macOS 自带，无需安装 |

## 详细步骤

### 步骤 1：前置检查

读取 `references/01-prerequisites.md`，依次检查：
1. lark-cli 是否已安装、已授权
2. ima-skill 是否已安装、IMA OpenAPI 凭证是否配置
3. yinxiang-skill 是否已安装、印象笔记 Token 是否已授权
4. 本地文件夹路径 `REFERENCES_DIR` 是否已设置

缺失任意一项 → 提示用户安装并完成授权，**不得跳过**。

### 步骤 2：飞书采集

读取 `references/02-feishu-collection.md`，按子步骤执行：

**2A. 妙记采集**
1. `minutes +search --start/--end --owner-ids "me"` 搜索我拥有的妙记
2. `minutes +search --start/--end --participant-ids "me"` 搜索我参与的妙记
3. 按 `minute_token` 去重合并
4. `vc +notes --minute-tokens <token>` 读取AI总结、待办、章节

**2B. 云文档采集**
1. `drive +search --edited-since 7d` 搜索我编辑过的文档
2. `drive +search --opened-since 7d` 搜索我打开过的文档
3. 按 token 去重，跳过智能纪要文档（已在 2A 覆盖）
4. `docs +fetch` 读取正文

### 步骤 3：IMA知识库采集

读取 `references/03-ima-collection.md`：
1. `list_note` 按修改时间排序翻页
2. 本地过滤 `modify_time` 在近一周内的笔记
3. 遇到第一条 `modify_time < 一周前` 的笔记即停止翻页
4. `get_doc_content` 读取正文

### 步骤 4：印象笔记采集

读取 `references/04-evernote-collection.md`：
1. 加载 `previous_note_guids.json` 中的已处理 GUID 清单
2. `searchNotesByFilter` 获取最近 50 条笔记
3. 逐条对比 noteGuid，只处理新增笔记
4. 保存本次 GUID 清单供下次去重

### 步骤 5：本地文件夹扫描

读取 `references/05-local-files-collection.md`：
1. 从 `REFERENCES_DIR` 读取要扫描的路径
2. `find -newermt "7天前"` 发现近一周有变动的文件
3. 对 `.docx` 用 `textutil -convert txt` 转文本
4. 对 `.txt`、`.md` 直接读取

### 步骤 6：合并与提取

读取 `references/06-todo-extraction.md`：

汇总全部数据源的原始记录。按以下 7 条规则逐条判断：

| # | 规则 | 说明 |
|---|------|------|
| # | 规则 | 归类 |
|---|------|------|
| ① | 下周有明确截止 | → 🔴 硬性截止 |
| ② | 本周截止未确认完成 | → 🔴 硬性截止 |
| ③ | 提到"下周"待行动 | → 🟡 未完成/待推进 |
| ④ | 有行动项未完成 | → 🟡 未完成/待推进 |
| ⑤ | 未解决问题/异常 | → 🟡 未完成/待推进 |
| ⑥ | 分配/负责的事项 | → 🟡 未完成/待推进 |
| ⑦ | 固定频率必做 | → 🟢 周期性工作 |

## 输出格式

```
父文档：每周待办
子文档：{月份}月第{周次}周待办

子文档内容按五个分类组织：
  ## 🔴 硬性截止
  ## 🟡 未完成/待推进
  ## 🟢 周期性工作

  每个分类使用表格格式：事项 | 截止时间 | 责任人 | 来源
  来源列使用渠道名：飞书云文档、飞书妙记、本地文件夹、印象笔记、IMA知识库
```

## 注意事项

- **按时间发现，不按关键词过滤**：先列出近一周全部有更新的条目，再逐个读取内容
- **lark-cli 可能出现间歇性 DNS 失败**：失败后等待几秒重试
- **印象笔记去重**：逐 noteGuid 对比，非内容对比
- **本地文件夹路径**：由 `REFERENCES_DIR` 环境变量配置，不在代码中硬编码
- **来源列**：使用渠道名而非具体文档名
