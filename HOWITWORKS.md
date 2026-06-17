# cog-rules 工作机制备忘

> 给未来的自己：万一对话又丢了，看这一篇就够。
> 最后核对时间：2026-06-17。源仓库：https://github.com/Angry-Sparrow/cog-rules
> 约定：下文 `$COG_RULES_DIR` = 本仓库 clone 到的路径（值见 `~/.zshrc`）。

## 一句话

把一套**跨 AI 工具的开发工作流规则**做成**单一事实源**：只维护一份 `AGENTS.md`，
用软链接扇出到各 AI 编码工具的配置入口。换工具、换模型都不用重写规则。

## 仓库结构

```
$COG_RULES_DIR/
├── AGENTS.md        # 规则正文（单一事实源），只改这一份
├── sync-rules.sh    # 幂等同步脚本：把 AGENTS.md 软链到各工具入口
├── README.md        # 设计说明
└── HOWITWORKS.md    # 本文件
```

## 怎么生效（已于 2026-06-17 验证）

### 1. 三处软链，全部指向同一个源文件

| 工具 | 入口（软链） | 指向 |
|---|---|---|
| Kiro | `~/.kiro/steering/dev-workflow.md` | `$COG_RULES_DIR/AGENTS.md` |
| Codex | `~/.codex/AGENTS.md` | `$COG_RULES_DIR/AGENTS.md` |
| Claude Code | `~/.claude/CLAUDE.md` | `$COG_RULES_DIR/AGENTS.md` |

各工具启动时自动读自己的入口文件，规则即生效。
（验证：本次 Kiro 对话顶部加载的「开发工作流默认策略」context，就是经
`~/.kiro/steering/dev-workflow.md` 这条软链读进来的。）

### 2. `~/.zshrc` 里的自愈逻辑（约 22–36 行）

```bash
export COG_RULES_DIR="$HOME/<你的clone路径>/cog-rules"   # 实际值见 ~/.zshrc
alias synrules="$COG_RULES_DIR/sync-rules.sh"            # 手动同步
ai-rules() {                                             # 在当前项目根软链 AGENTS.md
  ln -sf "$COG_RULES_DIR/AGENTS.md" "./AGENTS.md" \
    && echo "linked ./AGENTS.md -> $COG_RULES_DIR/AGENTS.md"
}
# 自愈：每开新终端，发现已装工具未链/链断则静默补
[ -x "$COG_RULES_DIR/sync-rules.sh" ] && "$COG_RULES_DIR/sync-rules.sh" --heal >/dev/null 2>&1
```

最后那行 `--heal` 是关键：每开一个终端静默检查——已装工具的入口没软链或链断了就自动补，
都正常就几乎零开销。所以「装了新工具要同步」由系统自动兜底，不用记。

## 日常只需记三件事

1. **改规则**：只编辑 `$COG_RULES_DIR/AGENTS.md`，所有工具因软链自动同步。
2. **手动同步**：终端敲 `synrules`（装了新工具想立刻生效时用）。
3. **进只认项目根的工具**（Cursor / Aider / Windsurf / Zed）：在项目根目录敲 `ai-rules`，
   把 `AGENTS.md` 软链进当前项目。

## 新增一个工具怎么扩展

编辑 `sync-rules.sh` 顶部的 `TOOLS` 映射表，按格式加一行：

```
"工具名|配置目录(存在才处理)|入口软链路径"
```

然后 `synrules` 一下即可。

## 排障速查

- **规则好像没生效**：跑 `synrules` 看输出；或检查软链
  `ls -l ~/.kiro/steering/dev-workflow.md`（应指向本仓库 AGENTS.md）。
- **软链失效**：通常是本仓库被移动/删除。重新 `git clone` 回原路径再跑
  `./sync-rules.sh` 即恢复（路径以 `~/.zshrc` 的 `COG_RULES_DIR` 为准）。
- **在新机器上复刻**：
  ```bash
  git clone https://github.com/Angry-Sparrow/cog-rules.git "$COG_RULES_DIR"
  cd "$COG_RULES_DIR" && ./sync-rules.sh
  # 再把上面那段 zshrc 配置粘进 ~/.zshrc
  ```

## 注意

- 远程是**公开仓库**，`AGENTS.md` 内容会公开，**勿写敏感信息**。
- 所有软链都指向本仓库的 `AGENTS.md`，移动/删除本仓库会导致软链失效。
