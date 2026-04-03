#!/bin/bash
# Permission Matcher - 权限规则匹配
# 用法: ./permission-match.sh "<command>"

COMMAND="$1"
CONFIG_FILE="$HOME/.openclaw/workspace/capabilities/permission-rules.json"

# 默认规则（内置）
DEFAULT_ALLOW=(
    "git status"
    "git log --oneline"
    "git diff"
    "git branch"
    "git show"
    "ls -la"
    "ls"
    "pwd"
    "cat"
    "head"
    "tail"
    "grep"
    "find"
    "ps aux"
    "df -h"
    "du -sh"
)

DEFAULT_CONFIRM=(
    "git push"
    "git merge"
    "git rebase"
    "git checkout"
    "npm install"
    "pip install"
    "curl"
    "wget"
    "ssh"
    "scp"
)

DEFAULT_DENY=(
    "rm -rf /"
    "rm -rf /usr"
    "rm -rf /bin"
    "dd if=*of=/dev/"
    "mkfs"
    "fdisk"
    "> /etc/"
)

# 匹配函数
match_pattern() {
    local cmd="$1"
    local pattern="$2"
    
    # 简单 glob 匹配
    local regex=$(echo "$pattern" | sed 's/\./\\./g; s/\*/.*/g; s/\?/.?/g')
    echo "$cmd" | grep -E "^${regex}$" > /dev/null 2>&1
}

# 主匹配
match_command() {
    local cmd="$1"
    
    # 检查 deny
    for pattern in "${DEFAULT_DENY[@]}"; do
        if match_pattern "$cmd" "$pattern"; then
            echo "DENY"
            echo "⚠️  危险操作被阻止：$cmd"
            return 1
        fi
    done
    
    # 检查 confirm
    for pattern in "${DEFAULT_CONFIRM[@]}"; do
        if match_pattern "$cmd" "$pattern"; then
            echo "CONFIRM"
            return 2
        fi
    done
    
    # 检查 allow
    for pattern in "${DEFAULT_ALLOW[@]}"; do
        if match_pattern "$cmd" "$pattern"; then
            echo "ALLOW"
            return 0
        fi
    done
    
    # 默认 prompt
    echo "PROMPT"
    return 3
}

# 主流程
main() {
    if [ -z "$COMMAND" ]; then
        echo "Usage: $0 \"<command>\""
        exit 1
    fi
    
    result=$(match_command "$COMMAND")
    echo "$result"
}

main
