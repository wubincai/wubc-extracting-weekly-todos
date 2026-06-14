# 印象笔记采集（GUID 去重）

## 目录
- 前置条件与验证
- 去重机制
- 执行步骤
- 补充搜索
- 注意事项

## 前置条件与验证

- yinxiang-skill 已安装
- Token 已配置在 `~/.codex/skills/yinxiang-skill/.env`

```bash
# 验证 Token 是否有效
TOKEN=$(cat ~/.codex/skills/yinxiang-skill/.env | cut -d= -f2-)

# 列出笔记本测试
curl -s -X POST "https://app.yinxiang.com/third/ai-chat-note/grpc-api/search/listNoteBooks" \
  -H "Content-Type: application/json" \
  -H "auth: $TOKEN" -d '{}'
```

## 去重机制

印象笔记 API 没有按时间范围搜索的参数。采用以下策略：

1. 取最近 50 条笔记
2. 与上次运行时保存的 noteGuid 清单对比
3. 只处理新出现的笔记（新增或内容更新）
4. 保存本次的 GUID 清单供下次去重

## 执行步骤

### 1. 加载上次 GUID 清单

```bash
DEDUP_FILE="$HOME/.codex/skills/yinxiang-skill/previous_note_guids.json"

if [ -f "$DEDUP_FILE" ]; then
  PREVIOUS_GUIDS=$(python3 -c "
import json
with open('$DEDUP_FILE') as f:
    d = json.load(f)
for g in d.get('guids', []):
    print(g)
")
fi
```

首次运行时文件不存在 → 全部笔记都处理，无去重。

### 2. 获取最近 50 条笔记

```bash
TOKEN=$(cat ~/.codex/skills/yinxiang-skill/.env | cut -d= -f2-)

curl -s -X POST \
  "https://app.yinxiang.com/third/ai-chat-note/grpc-api/search/searchNotesByFilter" \
  -H "Content-Type: application/json" \
  -H "auth: $TOKEN" \
  -d '{"resultSpec":{"includeContent":true,"includeResources":false,"includeTags":true,"includeResourceContent":false}}'
```

返回结构：
```json
{
  "status": {"code": 8200},
  "data": {
    "noteDetailList": [
      {
        "noteGuid": "xxx",
        "noteTitle": "标题",
        "content": "笔记正文",
        "tagList": [{"tagName": "标签名"}],
        "notebookName": "笔记本名"
      }
    ]
  }
}
```

### 3. GUID 去重

```python
for note in response["data"]["noteDetailList"][:50]:
    if note["noteGuid"] not in previous_guids:
        # 新增笔记 → 纳入工作记录
        process(note)
    else:
        # 已处理过 → 跳过
        continue
```

### 4. 保存本次 GUID 清单

```bash
cat > "$DEDUP_FILE" << 'GUIDEOF'
{
  "guids": ["guid1", "guid2", "..."],
  "updated_at": "2026-06-14T16:59:00+08:00"
}
GUIDEOF
```

从本次返回的笔记中提取所有 `noteGuid`，无论是否已处理，全部保存到文件。

## 补充搜索

为提升覆盖率，额外用宽泛关键词搜索（返回结果同样做 GUID 去重）：

```bash
TOKEN=$(cat ~/.codex/skills/yinxiang-skill/.env | cut -d= -f2-)

curl -s -X POST \
  "https://app.yinxiang.com/third/ai-chat-note/grpc-api/search/searchNotesByFilter" \
  -H "Content-Type: application/json" \
  -H "auth: $TOKEN" \
  -d '{"keyword":"<月份>月","resultSpec":{"includeContent":true}}'
```

## 笔记详情读取（按需）

```bash
curl -s -X POST \
  "https://app.yinxiang.com/third/ai-chat-note/grpc-api/search/getNoteDetail" \
  -H "Content-Type: application/json" \
  -H "auth: $TOKEN" \
  -d '{"guid":"<noteGuid>","resultSpec":{"includeContent":true}}'
```

## 注意事项

- Token 格式以 `S=s` 开头
- 首次运行创建 `previous_note_guids.json` 后，后续运行才具备去重能力
- 返回数量可能少于 50 条（API 限制）
- 近一周工作记录通常较少，结果为 0 时直接跳过
- 印象笔记 API 间歇性 DNS 失败，可重试
