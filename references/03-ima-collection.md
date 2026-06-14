# IMA知识库采集

## 前置条件

- ima-skill 已安装
- IMA OpenAPI 凭证已配置在 `~/.config/ima/` 中（client_id + api_key）
- IMA API 需要网络访问，沙箱中可能需要 `require_escalated`

## 搜索方法

IMA 知识库的笔记支持按修改时间排序，通过 `list_note` API 翻页发现近一周有修改的笔记。

### 1. 准备 API 参数

```bash
SKILL_DIR="$HOME/.codex/skills/ima-skill"
OPTS=$(printf '{"clientId":"%s","apiKey":"%s"}' "$(cat ~/.config/ima/client_id)" "$(cat ~/.config/ima/api_key)")
```

### 2. 列出所有笔记（按修改时间排序）

```bash
# 首次翻页
node "$SKILL_DIR/ima_api.cjs" "openapi/note/v1/list_note" \
  '{"folder_id":"","sort_type":0,"cursor":"","limit":20}' "$OPTS"

# 后续翻页（cursor 使用上一次返回的 next_cursor）
node "$SKILL_DIR/ima_api.cjs" "openapi/note/v1/list_note" \
  '{"folder_id":"","sort_type":0,"cursor":"<next_cursor>","limit":20}' "$OPTS"
```

**参数说明**：
- `folder_id`: 空字符串表示所有笔记
- `sort_type`: `0` = 按修改时间排序（最新在前）
- `cursor`: 首次传空字符串 `""`，后续传返回的 `next_cursor`
- `limit`: 每页数量，最大 20

### 3. 本地过滤

返回的每条笔记包含 `modify_time`（Unix 毫秒时间戳），本地过滤：

```python
import time
one_week_ago_ms = int((time.time() - 7 * 86400) * 1000)

for note in response.data.note_book_list:
    if note.modify_time >= one_week_ago_ms:
        # 近一周内有修改 → 读取正文
    else:
        # 笔记较旧，可以停止翻页（后面的更旧）
        break
```

### 4. 读取笔记正文

```bash
node "$SKILL_DIR/ima_api.cjs" "openapi/note/v1/get_doc_content" \
  '{"note_id":"<note_id>","target_content_format":0}' "$OPTS"
```

`target_content_format`: `0` = 纯文本

### 5. 补充搜索（可选）

如果 `list_note` 返回的结果较少，可以用关键词补充搜索：

```bash
node "$SKILL_DIR/ima_api.cjs" "openapi/note/v1/search_note" \
  '{"search_type":1,"sort_type":0,"query_info":{"title":"","content":"<月份>"},"start":0,"end":20}' "$OPTS"
```

### 6. 输出

每条笔记输出格式：
```
[标题] [修改时间] [正文摘要]
```

## 注意事项

- 翻页到遇到第一条 `modify_time < 一周前` 的笔记即可停止（后续更旧）
- IMA API 有跨域限制，确保运行环境有网络访问权限
- 近一周个人工作记录通常较少，结果为 0 条时直接跳过
- `list_note` 返回的笔记信息中包含 `create_time` 和 `modify_time`（Unix 毫秒）
