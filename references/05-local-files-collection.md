# 本地文件夹扫描

## 前置条件

- 用户在环境变量 `REFERENCES_DIR` 中已配置要扫描的文件夹路径
- macOS 系统自带 `textutil` 用于转换 `.docx` 文件

## 配置方式

用户在 shell 配置文件中设置：

```bash
# ~/.zshrc 或 ~/.bashrc
export REFERENCES_DIR="$HOME/Documents/work:$HOME/Desktop/projects"
```

多个路径用冒号 `:` 分隔。

## 扫描方法

### 1. 读取配置路径

```bash
# 从环境变量获取路径列表
IFS=':' read -r -a dirs <<< "${REFERENCES_DIR}"

# 检查路径是否存在
for dir in "${dirs[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "WARNING: 路径不存在: $dir"
  fi
done
```

### 2. 按时间发现文件

对每个配置的路径，用 `find` 查找近一周有修改的文件：

```bash
# 查找近 7 天内修改过的文件（排除隐藏文件和临时文件）
find "$dir" -newermt "$(date -v-7d '+%Y-%m-%d')" -type f \
  ! -name ".DS_Store" ! -name "~$*" ! -path "*/.*" 2>/dev/null
```

### 3. 筛选可读的文件类型

| 文件类型 | 读取方法 |
|---------|---------|
| `.txt` | 直接 `cat` |
| `.md` | 直接 `cat` |
| `.docx` | `textutil -convert txt -stdout` |
| `.doc` | `textutil -convert txt -stdout` |
| `.xlsx`/`.xls` | 跳过（数据报表，不提取文本待办） |
| `.pptx`/`.ppt` | 跳过（演示文稿） |
| `.pdf` | 跳过（PDF 文件） |
| 图片/视频 | 跳过 |

### 4. 读取支持的文档

```bash
# .docx 转文本
textutil -convert txt -stdout "path/to/file.docx" 2>/dev/null

# .txt / .md 直接读取
cat "path/to/file.txt"
```

### 5. 输出

每条文件输出格式：
```
[文件名] [修改时间] [文件路径] [正文前200字]
```

## 注意事项

- `REFERENCES_DIR` 必须由用户自行配置，Skill 中不硬编码任何路径
- 如果用户未配置，提示："请先设置 REFERENCES_DIR 环境变量，例如：export REFERENCES_DIR=\"\$HOME/Documents/work\""
- `find -newermt` 的参数使用当前日期的 7 天前
- 只读取文本类文件（txt/md/docx），Excel、PPT、PDF 等跳过
- macOS 的 `textutil` 可以转换 docx 为纯文本，Linux 用户可能需要 `pandoc` 或 `libreoffice --headless`
- 文件内容过长时，取前 200 字作为摘要，判断是否需要读取全文
