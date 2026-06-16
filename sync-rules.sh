#!/usr/bin/env bash
#
# cog-rules / sync-rules.sh
# 把单一源 AGENTS.md 幂等地软链到各 AI 编码工具的入口。
#
#   用法:
#     ./sync-rules.sh          # 正常模式:打印 已链/跳过/新增/修正 清单
#     ./sync-rules.sh --heal   # 自愈静默模式:仅在需要时改动,无输出(供 ~/.zshrc 调用)
#
# 设计要点:
#   - 源路径 = 脚本自身所在目录下的 AGENTS.md,绝不写死绝对路径,clone 到任意路径都能用。
#   - 幂等:链已正确→跳过;缺失→创建;指错/断链→纠正;被真实文件占用→备份后替换。
#   - 仅当工具的配置目录存在时才处理(没装的工具自动跳过)。
#   - 新增工具:在下方 TOOLS 映射表加一行即可。
#
set -euo pipefail

# ---- 源:脚本自身目录(不写死) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SRC="$SCRIPT_DIR/AGENTS.md"

# ---- 工具映射表:"工具名|配置目录(存在才处理)|入口软链路径" ----
# 新增工具只需在此加一行。
TOOLS=(
  "Kiro|$HOME/.kiro/steering|$HOME/.kiro/steering/dev-workflow.md"
  "Codex|$HOME/.codex|$HOME/.codex/AGENTS.md"
  "ClaudeCode|$HOME/.claude|$HOME/.claude/CLAUDE.md"
)

# ---- 模式 ----
HEAL=0
[ "${1:-}" = "--heal" ] && HEAL=1
log() { [ "$HEAL" -eq 1 ] || printf '%s\n' "$*"; }

# ---- 前置校验 ----
if [ ! -f "$SRC" ]; then
  echo "ERROR: 源文件不存在: $SRC" >&2
  exit 1
fi

# ---- 主循环 ----
for entry in "${TOOLS[@]}"; do
  IFS='|' read -r name cfgdir link <<< "$entry"

  # 工具未安装(配置目录不存在)→ 跳过
  if [ ! -d "$cfgdir" ]; then
    log "skip    $name (未安装: $cfgdir)"
    continue
  fi

  if [ -L "$link" ]; then
    target="$(readlink "$link")"
    if [ "$target" = "$SRC" ] && [ -e "$link" ]; then
      log "ok      $name ($link)"
    else
      ln -sf "$SRC" "$link"
      log "fix     $name (指向已纠正/断链已修复 -> $SRC)"
    fi
  elif [ -e "$link" ]; then
    # 入口被真实文件占用 → 备份后替换为软链
    bak="$link.bak.$(date +%Y%m%d%H%M%S)"
    mv "$link" "$bak"
    ln -s "$SRC" "$link"
    log "replace $name (原文件备份为 $bak -> $SRC)"
  else
    # 缺失 → 创建(父目录已确认存在)
    ln -s "$SRC" "$link"
    log "link    $name ($link -> $SRC)"
  fi
done

log ""
log "源: $SRC"
exit 0
