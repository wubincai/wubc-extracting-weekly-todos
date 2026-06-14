# 飞书采集（妙记 + 云文档）

## 目录
- 前置条件
- 时间范围计算
- 妙记采集（搜索 + 内容读取）
- 云文档采集（搜索 + 内容读取）
- 注意事项

## 前置条件
- lark-cli 已安装并授权
- 已授权 scope: `minutes:minutes.search:read`、`minutes:minutes:readonly`、`minutes:minutes.artifacts:read`

## 时间范围计算

```python
from datetime import datetime, timezone, timedelta
tz = timezone(timedelta(hours=8))
now = datetime.now(tz)
one_week_ago = now - timedelta(days=7)
start_date = one_week_ago.strftime("%Y-%m-%d")
end_date = now.strftime("%Y-%m-%d")
```

## 妙记（录音/会议）采集

### 1. 搜索妙记

按时间范围搜索近一周的妙记，分两次查询后合并：

```bash
# 我拥有的妙记
lark-cli minutes +search --owner-ids "me" --start <start_date> --end <end_date> --page-size 30 --format json

# 我参与的妙记（补充，可能与上述重叠）
lark-cli minutes +search --participant-ids "me" --start <start_date> --end <end_date> --page-size 30 --format json
```

**去重合并**：两次结果按 `token` 字段去重，两个 ID 都传 `me` 表示当前用户。

### 2. 读取妙记内容

对每个不重复的 `minute_token`，批量调用获取 AI 产物：

```bash
lark-cli vc +notes --minute-tokens <token1>,<token2>,<token3> --format json
```

返回结构包含：
- `artifacts.summary` — AI 总结
- `artifacts.chapters` — 章节（含每段摘要）
- `artifacts.todos` — AI 提取的待办项（含 `content`、`is_done`）
- `title` — 妙记标题
- `create_time` — 创建时间

**注意**：`vc +notes` 需要额外的 scope 授权（见前置条件）。若授权缺失，运行 `lark-cli auth login --scope "minutes:minutes:readonly minutes:minutes.artifacts:read"` 引导用户扫码授权。

## 云文档采集

### 1. 搜索文档

使用 `drive +search` 按时间发现，**不按关键词**：

```bash
# 近一周我编辑过的文档
lark-cli drive +search --query "" --edited-since 7d --format json

# 近一周我打开过的文档（补充覆盖）
lark-cli drive +search --query "" --opened-since 7d --format json
```

参数说明：
- `--edited-since 7d` — 近 7 天我编辑过的
- `--opened-since 7d` — 近 7 天我打开过的
- `--query ""` — 空关键词，只靠时间条件过滤

### 2. 筛选有效文档

从返回结果中筛选需要读取的文档：

```
跳过：
- 文档类型为 BITABLE / SHEET（非文本内容）
- 标题以"智能纪要："开头（已在妙记步骤覆盖）
- 标题包含"Api key""_合集"等明确非工作类文档

保留：
- DOCX 类型的工作文档
- 标题含工作计划、方案、总结、项目等关键词
- 创建/编辑时间在近一周内
```

### 3. 读取文档内容

```bash
lark-cli docs +fetch --api-version v2 --doc <token> --doc-format markdown --format json
```

`--api-version v2` 为必选参数，否则使用已关闭的 v1 接口。

## 注意事项

- 妙记搜索需要 `minutes:minutes.search:read` 权限
- 妙记内容读取需要 `minutes:minutes:readonly` 和 `minutes:minutes.artifacts:read`
- 先搜索妙记，搜索文档时跳过智能纪要文档（避免重复读取同一内容）
- lark-cli 部分接口可能出现间歇性 DNS 失败，失败后等待数秒重试
