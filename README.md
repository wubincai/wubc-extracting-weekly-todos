# wubc-extracting-weekly-todos - 周待办提取

从钉钉、飞书、IMA、印象笔记等多个协作渠道提取近7天工作记录，按统一标准筛选并输出下周待办事项，可写入指定位置并通知相关责任人。

## 概述

周待办提取 Skill 是一个交互式工作流型工具，适合每周日/一让 AI 帮你提取下周待办的工作场景。它通过对话引导完成配置，然后自动从多个渠道检索工作记录，判断哪些需要列为下周待办，最终输出结构化结果。

核心能力：
- 动态选择信息渠道（钉钉/飞书/IMA/印象笔记）
- 自动检测各渠道接入状态并引导配置
- 6 条明确标准判定待办事项
- 完整性检查确保不遗漏数据
- 支持输出到飞书/钉钉/IMA 并通知责任人

## 前置依赖

| 依赖工具 | 用途 | 安装方式 |
|---------|------|---------|
| dws-cli | 钉钉消息/文档/通知 | `npm install -g dws-cli` |
| lark-cli | 飞书文档/消息/妙记 | `npm install -g lark-cli` |
| IMA API | IMA 知识库和笔记 | 配置 client_id + api_key |
| 印象笔记 CLI | 印象笔记 | 配置 Developer Token |

## 安装与配置

### 1. 安装 Skill

```bash
git clone https://github.com/wubincai/wubc-extracting-weekly-todos.git
cd wubc-extracting-weekly-todos
codex skill install .
```

### 2. 配置各渠道

见各渠道的配置引导（运行 Skill 时会自动检测和引导）。

## 使用示例

## 配置持久化

首次使用时，您在阶段一中填写的偏好配置（多组织 corp_id、输出位置、是否通知责任人）会自动保存到 `~/.config/wubc-extracting-weekly-todos/config.json`。

后续使用时，Skill 会自动检测已保存的配置并询问是否直接使用，无需重复填写。可选操作：
- **使用配置** → 跳过偏好设置，直接进入信息检索
- **更新配置** → 修改部分设置后保存
- **重新配置** → 全部重新设置，覆盖旧配置

如需清除所有配置，运行：
```bash
rm -f ~/.config/wubc-extracting-weekly-todos/config.json
```

### 示例 1：正常周待办提取
```
帮我提取下周待办事项
```

### 示例 2：指定渠道和联系人
```
提取下周待办，只看钉钉群聊和飞书云文档，单聊看张三
```

### 示例 3：生成周报素材
```
帮我把近一周的工作记录整理成下周工作计划
```

## 项目结构

```
wubc-extracting-weekly-todos/
├── SKILL.md                    # 主工作流
├── README.md                   # 本文件
├── LICENSE.txt                 # Apache 2.0
├── .gitignore                  # Git 忽略规则
├── references/
│   ├── 01-precondition.md      # 前置条件确认流程
│   ├── 02-channel-setup.md     # 各渠道接入检测和配置引导
│   ├── 03-search-methods.md    # 各渠道信息检索方法 + 完整性检查
│   ├── 04-todo-criteria.md     # 待办判定标准（6条 + 排除清单）
│   ├── 05-output-format.md     # 输出格式规范和通知模板
│   └── 06-duplicate-prevention.md  # 去重与避免循环提取
├── scripts/
│   ├── check_dingtalk.sh       # 检测钉钉通道是否可用
│   ├── check_feishu.sh         # 检测飞书通道是否可用
│   ├── check_ima.sh            # 检测 IMA 凭证是否有效
│   ├── check_yinxiang.sh       # 检测印象笔记是否已授权
│   ├── check_and_notify.py     # 通过钉钉私聊通知责任人
│   └── setup_dingtalk_multi_org.sh  # 引导配置多组织
└── assets/
    └── template_output.md      # 输出模板示例
```

## 工作流说明

Skill 执行 5 个阶段：

1. **前置确认**：选择渠道 → 接入检测 → 配置引导 → 多组织确认 → 输出位置 → 通知
2. **设定范围**：时间默认近7天，单聊联系人必填，群聊可选
3. **信息检索**：逐个渠道执行检索，排除待办记录文档，合并去重
4. **完整性检查**：检查群覆盖、分页、时间范围、关键词、跨渠道一致性
5. **待办提取**：6 条标准筛选 → 2 类分类 → 4 字段格式化
6. **写入和发送**：写入指定位置 + 可选通知责任人

## 待办判定标准（6条）

一条记录必须同时满足：来源合规 → 未完成 → 具体工作 → 责任明确 → 含动作 → 下周完成。

排除：已完成、咨询/询问、非我安排的团队工作、信息同步、待办记录文档。

## 许可证

Apache 2.0. 详见 LICENSE.txt。
