#!/bin/bash
# Skill 上下文感知建议脚本
# 根据当前工作区文件自动建议相关技能

WORKSPACE="${1:-$HOME/.openclaw/workspace}"
CAPABILITIES_DIR="$WORKSPACE/capabilities"

echo "🔍 分析工作区: $WORKSPACE"
echo ""

# 扫描代码文件
CODE_FILES=$(find "$WORKSPACE" -maxdepth 4 -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.java" \) 2>/dev/null | head -20)

# 扫描配置文件
CONFIG_FILES=$(find "$WORKSPACE" -maxdepth 3 -type f \( -name ".gitignore" -o -name ".gitlab-ci.yml" -o -name "prometheus.yml" -o -name "grafana.yaml" \) 2>/dev/null | head -10)

# 扫描文档
DOC_FILES=$(find "$WORKSPACE" -maxdepth 3 -type f \( -name "*.md" -o -name "README*" \) 2>/dev/null | head -10)

# 合并所有文件
ALL_FILES="$CODE_FILES
$CONFIG_FILES
$DOC_FILES"

FILE_COUNT=$(echo "$ALL_FILES" | grep -v "^$" | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -eq 0 ] || [ "$FILE_COUNT" = "0" ]; then
    echo "📁 未检测到任何匹配的文件"
    echo ""
    echo "💡 建议激活：context-aware（上下文感知）"
    exit 0
fi

echo "📊 检测到 $FILE_COUNT 个相关文件"
echo ""

# 计算匹配的技能
echo "🤖 技能建议："
echo "----------------"

# 代码审查
CODE_REVIEW_SCORE=$(echo "$ALL_FILES" | grep -cE "\.(py|js|ts|go|java|cpp|c|rs)$" 2>/dev/null || echo "0")
if [ "$CODE_REVIEW_SCORE" -gt 0 ]; then
    echo "   code-review-assistant       ${CODE_REVIEW_SCORE}0%"
fi

# GitHub
GITHUB_SCORE=$(echo "$ALL_FILES" | grep -cE "\.git|github|\.gitignore" 2>/dev/null || echo "0")
if [ "$GITHUB_SCORE" -gt 0 ]; then
    echo "   github                      ${GITHUB_SCORE}0%"
fi

# GitLab
GITLAB_SCORE=$(echo "$ALL_FILES" | grep -cE "\.gitlab-ci|gitlab" 2>/dev/null || echo "0")
if [ "$GITLAB_SCORE" -gt 0 ]; then
    echo "   gitlab-code-review          ${GITLAB_SCORE}0%"
fi

# 监控
MONITORING_SCORE=$(echo "$ALL_FILES" | grep -cE "prometheus|grafana|监控|alertmanager" 2>/dev/null || echo "0")
if [ "$MONITORING_SCORE" -gt 0 ]; then
    echo "   monitoring                  ${MONITORING_SCORE}0%"
fi

# 文档
DOC_SCORE=$(echo "$ALL_FILES" | grep -cE "\.md|README" 2>/dev/null || echo "0")
if [ "$DOC_SCORE" -gt 0 ]; then
    echo "   notion-skill               ${DOC_SCORE}0%"
fi

# 图表
DIAGRAM_SCORE=$(echo "$ALL_FILES" | grep -cE "\.mmd|\.puml|plantuml" 2>/dev/null || echo "0")
if [ "$DIAGRAM_SCORE" -gt 0 ]; then
    echo "   mermaid-diagram             ${DIAGRAM_SCORE}0%"
fi

echo ""
echo "💡 使用 /skill activate <name> 激活技能"
