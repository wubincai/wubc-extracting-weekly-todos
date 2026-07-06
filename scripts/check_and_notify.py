#!/usr/bin/env python3
"""
周待办通知脚本 - 通过钉钉私聊通知待办责任人

用法: python3 check_and_notify.py <todos_json> [output_url]

todos_json: JSON 格式的待办列表，每个条目包含：
  - content: 事项内容
  - responsible: 责任人
  - source: 来源描述
  - deadline: 截止时间
  - source_url: 来源文档链接

output_url: 输出文档链接（可选）
"""

import json
import subprocess
import sys


def notify_person(name, todos, output_url=""):
    """通过 dws 钉钉私聊发送通知给责任人。"""
    if not todos:
        print(f"[SKIP] {name} 无待办事项，跳过")
        return True

    # 构建消息内容
    lines = [f"【下周待办提醒】您好，{name}，您负责的以下事项需在下周完成："]
    lines.append("")

    for todo in todos:
        lines.append(f"事项：{todo.get('content', '未命名')}")
        lines.append(f"  来源：{todo.get('source', '未知')}")
        lines.append(f"  截止：{todo.get('deadline', '未指定')}")
        lines.append("")

    if output_url:
        lines.append(f"详情请查看：{output_url}")

    lines.append("")
    lines.append("—— 本消息由周待办提取助手自动发送")

    message = "\n".join(lines)

    # 通过 dws 发送私聊
    try:
        result = subprocess.run(
            ["dws", "chat", "send", "--private", "--name", name,
             "--text", message],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            print(f"[OK] 已通知 {name}（{len(todos)} 条待办）")
            return True
        else:
            print(f"[FAIL] 通知 {name} 失败: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print(f"[FAIL] 通知 {name} 超时")
        return False
    except FileNotFoundError:
        print("[FAIL] dws CLI 未找到，无法发送通知")
        return False


def main():
    if len(sys.argv) < 2:
        print("用法: python3 check_and_notify.py <todos_json> [output_url]")
        sys.exit(1)

    try:
        with open(sys.argv[1]) as f:
            todos = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"[FAIL] 读取待办 JSON 失败: {e}")
        sys.exit(1)

    output_url = sys.argv[2] if len(sys.argv) > 2 else ""

    # 按责任人分组
    by_person = {}
    for todo in todos:
        name = todo.get("responsible", "")
        if not name:
            continue
        if name not in by_person:
            by_person[name] = []
        by_person[name].append(todo)

    # 逐个通知
    success_count = 0
    for name, person_todos in by_person.items():
        if name == "自己":
            continue  # 自己不需要通知
        if notify_person(name, person_todos, output_url):
            success_count += 1

    total = len(by_person) - (1 if "自己" in by_person else 0)
    print(f"\n通知完成：{success_count}/{total} 人")
    sys.exit(0 if success_count == total else 1)


if __name__ == "__main__":
    main()
