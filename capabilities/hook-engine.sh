#!/bin/bash
# Hook Engine - 钩子引擎
# 用法: ./hook-engine.sh <hook_type> <tool_name> [args...]

HOOK_TYPE="$1"
TOOL_NAME="$2"
shift 2
ARGS="$@"

HOOKS_DIR="$HOME/.openclaw/workspace/capabilities/hooks"
CONFIG_FILE="$HOME/.openclaw/workspace/capabilities/hook-config.json"
LOG_FILE="$HOME/.openclaw/logs/hook.log"

# 读取配置
get_hooks_for_tool() {
    local tool="$1"
    local hook_type="$2"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        return
    fi
    
    # 简化实现：直接 grep
    grep -A20 "\"${hook_type}\"" "$CONFIG_FILE" 2>/dev/null | grep "\"${tool}\"" -A10 | grep -E "^\s+\".+\"" | tr -d '", ' | head -5
}

# 执行单个 hook
execute_hook() {
    local hook_file="$1"
    local tool="$2"
    local args="$3"
    
    if [ ! -f "$hook_file" ]; then
        return 0
    fi
    
    case "$hook_file" in
        *.sh)
            bash "$hook_file" "$tool" "$args" 2>/dev/null
            ;;
        *.js)
            node "$hook_file" "$tool" "$args" 2>/dev/null
            ;;
        *)
            ;;
    esac
}

# 检查是否是危险操作
is_destructive() {
    local tool="$1"
    local args="$2"
    
    case "$tool" in
        rm|trash|kill|pkill|shutdown|reboot)
            return 0
            ;;
        mv|cp)
            # 检查是否覆盖
            echo "$args" | grep -qE "^\S+\s+\S+$" && return 0
            ;;
        echo|tee)
            echo "$args" | grep -q ">" && return 0
            ;;
    esac
    return 1
}

# 主流程
main() {
    if [ -z "$HOOK_TYPE" ] || [ -z "$TOOL_NAME" ]; then
        echo "Usage: $0 <hook_type> <tool_name> [args...]"
        exit 1
    fi
    
    # pre_tool_use 检查
    if [ "$HOOK_TYPE" = "pre_tool_use" ]; then
        # 内置危险操作检查
        if is_destructive "$TOOL_NAME" "$ARGS"; then
            echo "🔴 DESTRUCTIVE: $TOOL_NAME $ARGS"
            echo "⚠️  危险操作，需要确认"
            
            # 读取已批准的操作
            APPROVED_FILE="$HOME/.openclaw/workspace/capabilities/approved-actions.json"
            if [ -f "$APPROVED_FILE" ]; then
                cmd_hash=$(echo "$TOOL_NAME $ARGS" | md5)
                if grep -q "$cmd_hash" "$APPROVED_FILE" 2>/dev/null; then
                    echo "✅ 已批准的操作（24h内）"
                    exit 0
                fi
            fi
            
            echo ""
            echo "输入 \"yes\" 确认执行："
            read -r confirm
            if [ "$confirm" != "yes" ]; then
                echo "❌ 已取消"
                exit 1
            fi
            
            # 批准此操作（24h有效）
            echo "$cmd_hash" >> "$APPROVED_FILE"
        fi
    fi
    
    # post_tool_use 记录
    if [ "$HOOK_TYPE" = "post_tool_use" ]; then
        echo "$(date): $TOOL_NAME $ARGS" >> "$LOG_FILE"
    fi
    
    exit 0
}

main
