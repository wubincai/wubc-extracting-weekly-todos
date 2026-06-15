# wubc-extracting-weekly-todos

每周自动从飞书、IMA知识库、印象笔记和本地文件夹中提取近一周的工作记录，按规则筛选出下周待办事项，汇总写入飞书云文档。

## 工作原理

所有采集步骤均遵循 **按时间发现，不按关键词过滤** 的原则：

1. 确定近一周的时间范围
2. 从各数据源中找出近一周内有变动的条目
3. 读取条目内容
4. 按 7 条规则提取待办事项
5. 归入 3 个分类后写入飞书云文档

## 前置条件

### 必需工具

| 工具/Skill | 用途 | 获取方式 |
|-----------|------|---------|
| [lark-cli](https://www.npmjs.com/package/@larksuiteoapp/cli) | 飞书 API 调用 | `npm install -g @larksuiteoapp/cli` |
| ima-skill | IMA 知识库笔记操作 | Codex 内安装，配置 OpenAPI 凭证 |
| yinxiang-skill | 印象笔记操作 | Codex 内安装，完成 OAuth 授权 |
| textutil | 本地 .docx 转文本 | macOS 自带，无需安装 |

### 环境变量

```bash
# 本地文件夹扫描路径，多个用冒号分隔
export REFERENCES_DIR="$HOME/Documents/work:$HOME/Desktop/projects"
```

## 配置步骤

1. 安装 lark-cli 并完成飞书扫码授权
2. 在 Codex 中安装 ima-skill，配置 IMA OpenAPI 凭证到 `~/.config/ima/`
3. 在 Codex 中安装 yinxiang-skill，通过 OAuth 获取 Token 并保存
4. 设置 `REFERENCES_DIR` 环境变量指向自己的工作文件夹

详细配置指引见 [references/01-prerequisites.md](references/01-prerequisites.md)。

## 数据源

| 数据源 | 采集方法 | 说明 |
|--------|---------|------|
| 飞书妙记 | `minutes +search` + `vc +notes` | 按时间范围搜索近一周的会议录音和智能纪要 |
| 飞书云文档 | `drive +search --edited-since 7d` | 近一周有编辑或打开的 docx 文档 |
| IMA 知识库 | `list_note` 按修改时间排序 | 翻页发现近一周有更新的笔记 |
| 印象笔记 | `searchNotesByFilter` + GUID 去重 | 取最近 50 条，只处理新增笔记 |
| 本地文件夹 | `find -newermt` | 扫描用户配置的文件夹中近一周修改过的文件 |

## 输出格式

待办事项写入飞书云文档，文章结构如下：

```
父文档：每周待办
  └── 子文档：{月份}月第{周次}周待办
```

每个子文档按三个分类组织：

| 分类 | 筛选规则 |
|------|---------|
| 🔴 **硬性截止** | 下周有明确截止时间，或本周截止但未确认完成 |
| 🟡 **未完成/待推进** | 包含行动项、未解决问题，或分配/负责的事项 |
| 🟢 **周期性工作** | 按周/月固定频率要做的常规事项 |

每条待办包含四列：**事项 | 截止时间 | 责任人 | 来源**。来源列使用渠道名（飞书云文档/飞书妙记/本地文件夹/印象笔记/IMA知识库）。

## 文件结构

```
wubc-extracting-weekly-todos/
├── SKILL.md                     # 主入口：触发词、工作流总览
├── README.md                    # 本文件
├── LICENSE                      # MIT 许可证
├── .gitignore
└── references/
    ├── 01-prerequisites.md      # 前置检查与安装引导
    ├── 02-feishu-collection.md  # 飞书妙记 + 云文档采集
    ├── 03-ima-collection.md     # IMA 知识库笔记采集
    ├── 04-evernote-collection.md# 印象笔记采集（GUID 去重）
    ├── 05-local-files-collection.md # 本地文件夹扫描
    ├── 06-todo-extraction.md    # 7 条待办提取规则
    └── 07-output-format.md      # 飞书文档输出格式
```

## 许可证

[MIT](LICENSE)
