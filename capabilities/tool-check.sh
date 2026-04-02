#!/bin/bash
# Tool Safety Checker - 工具安全检查脚本
# 用法: ./tool-check.sh "<command>"

COMMAND="$1"
APPROVED_FILE="$HOME/.openclaw/workspace/capabilities/approved-actions.json"

# DESTRUCTIVE 操作模式
DESTRUCTIVE_PATTERNS=(
    "rm\s+-rf"
    "rm\s+-r\s"
    "rm\s+-f"
    "mv\s+.*\s+.*"     # 覆盖已有文件
    ">\s*\S+"          # 重定向覆盖
    "dd\s+"
    "mkfs"
    "fdisk"
    "diskutil\s+erase"
    "pkill\s+-9"
    "kill\s+-9"
    "shutdown"
    "reboot"
    "init\s+0"
    "init\s+6"
    "drop\s+table"
    "drop\s+database"
    "truncate\s+"
)

# WRITE 操作模式
WRITE_PATTERNS=(
    "git\s+push"
    "git\s+force-push"
    "curl\s+.*-X\s+POST"
    "curl\s+.*-X\s+PUT"
    "curl\s+.*-X\s+DELETE"
    "wget\s+.*-O"
    "ssh\s+"
    "scp\s+"
    "rsync\s+.*--delete"
    "echo\s+.*>"
    "tee\s+"
    "chmod\s+"
    "chown\s+"
)

# 检查是否匹配 DESTRUCTIVE
check_destructive() {
    for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -E "$pattern" > /dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# 检查是否匹配 WRITE
check_write() {
    for pattern in "${WRITE_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -E "$pattern" > /dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# 检查是否已批准
check_approved() {
    if [ -f "$APPROVED_FILE" ]; then
        # 简化检查：直接用 grep
        if grep -q "\"$(echo $COMMAND | md5)\"" "$APPROVED_FILE" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# 主逻辑
main() {
    if [ -z "$COMMAND" ]; then
        echo "用法: $0 \"<command>\""
        exit 1
    fi
    
    # 检查 DESTRUCTIVE
    if check_destructive; then
        echo "🔴 DESTRUCTIVE"
        echo "⚠️  危险操作：$COMMAND"
        echo ""
        echo "这是不可逆的操作，需要二次确认。"
        echo "输入 \"yes, do it\" 确认执行："
        exit 2
    fi
    
    # 检查 WRITE
    if check_write; then
        echo "🟡 WRITE"
        echo "📝 操作：$COMMAND"
        echo ""
        echo "建议确认后执行。"
        exit 3
    fi
    
    # 默认 READ
    echo "🟢 READ"
    echo "✅ 安全操作，直接执行"
    exit 0
}

main
