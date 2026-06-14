# 飞书云文档输出

## 文档结构
- 父文档: 每周待办
- 子文档: {月份}月第{周次}周待办（每次运行新建一个）

## 计算周次
```python
from datetime import datetime, timezone, timedelta
tz = timezone(timedelta(hours=8))
now = datetime.now(tz)
month = now.month
next_monday = now + timedelta(days=(7 - now.weekday()))
next_week_num = (next_monday.day - 1) // 7 + 1
doc_title = f"{month}月第{next_week_num}周待办"
```

## 文档创建流程

### 1. 检查/创建父文档
```bash
lark-cli docs +search --query "每周待办" --page-size 10 --format json
```
如果不存在则创建：
```bash
lark-cli docs +create --api-version v2 --doc-format markdown --content '<title>每周待办</title><p>周待办清单汇总</p>' --format json
```

### 2. 创建子文档
```bash
lark-cli docs +create --api-version v2 --doc-format markdown --content @<content_file> --format json
```

### 3. 写入内容
```bash
lark-cli docs +update --api-version v2 --doc <doc_token> --command overwrite --doc-format markdown --content @<content_file> --format json
```

## 表格规范
| 渠道名 | 对应数据源 |
|--------|-----------|
| 飞书云文档 | 飞书上的 docx 文档 |
| 飞书妙记 | 飞书妙记/录音/会议纪要 |
| 本地文件夹 | 用户配置的本地工作文件夹 |
| 印象笔记 | 印象笔记中的笔记 |
| IMA知识库 | IMA 知识库中的笔记 |

- 固定 4 列：事项 | 截止时间 | 责任人 | 来源
- 来源列使用渠道名
- 多个来源用 " + " 连接

## 注意事项
- --title 参数已废弃，标题放在 <title> 标签中
- --content 支持 @filepath 从文件读取（路径须为当前目录的相对路径）
- Markdown 表格中的 | 不需要转义
