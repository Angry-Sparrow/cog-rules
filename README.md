# cog-rules

> "Cog in the machine" —— 牛马开发者的一套跨工具 AI 开发规矩。

把一套**开发工作流策略**做成**单一事实源**(`AGENTS.md`),让它在**任意 AI 编码工具 +
任意模型**下都生效。你只维护这一份内容,各工具通过软链接指过来;换工具、换模型都不用重写。

## 为什么是 AGENTS.md

`AGENTS.md` 是业界开放标准(Linux Foundation 托管),被 Codex、Cursor、Copilot、Gemini CLI、
Aider、Windsurf、Zed 等原生读取;Kiro 默认 agent 也会加载。它是纯 markdown,**工具无关、模型无关**——
这是它比某个工具私有格式(如 Kiro steering、skill)更抗造的原因:换模型不影响(读文件的是工具不是模型),
换工具也能读。

## 目录结构

```
cog-rules/
├── AGENTS.md        # 单一事实源:所有规则正文,只改这里
├── sync-rules.sh    # 幂等扇出脚本:把 AGENTS.md 软链到各工具入口
└── README.md        # 本文件
```

## 各工具入口对照

`sync-rules.sh` 会把 `AGENTS.md` 软链到下列入口(**仅当对应工具的配置目录存在时**):

| 工具 | 全局入口 | 生效范围 |
|---|---|---|
| Kiro | `~/.kiro/steering/dev-workflow.md` | 全局(默认 agent 自动加载) |
| Codex | `~/.codex/AGENTS.md` | 全局 |
| Claude Code | `~/.claude/CLAUDE.md` | 全局 |
| 只认项目根的工具(Cursor/Aider/Windsurf/Zed 等) | 项目根 `AGENTS.md` | 用 `ai-rules` 按项目软链 |

新增工具:编辑 `sync-rules.sh` 顶部的映射表,加一行即可。

## 复刻 / 在新机器上安装

```bash
git clone https://github.com/Angry-Sparrow/cog-rules.git ~/lirui/cog-rules
cd ~/lirui/cog-rules
./sync-rules.sh        # 全局工具入口就位(幂等,可反复跑)
```

脚本以**自身所在目录**为源,clone 到任何路径都能用,不写死绝对路径。

## 日常使用

- **改规则**:只编辑 `AGENTS.md`,全部入口因为是软链,自动同步。
- **装了新 AI 工具**:无需记忆——见下方"自愈式自动同步";也可手动 `synrules`。
- **进入只认项目根的工具的项目**:在项目根目录执行 `ai-rules`,把 `AGENTS.md` 软链进来。

## 自愈式自动同步(策略 C)

`~/.zshrc` 中加入了一段轻量探测:每次新开终端时检查——**某个已知工具的配置目录已存在、
但还没软链(或链断了)**,才静默跑一次 `sync-rules.sh`;否则几乎零开销。
于是"装了新工具要同步"这件事由系统自动兜底,无需你记。

涉及的 shell 配置(示例,实际以 `~/.zshrc` 为准):

```bash
# cog-rules: 单一源仓库路径
export COG_RULES_DIR="$HOME/lirui/cog-rules"

# 手动同步别名
alias synrules="$COG_RULES_DIR/sync-rules.sh"

# 项目级:在当前目录软链 AGENTS.md
ai-rules() { ln -sf "$COG_RULES_DIR/AGENTS.md" "./AGENTS.md" && echo "linked AGENTS.md -> $COG_RULES_DIR/AGENTS.md"; }

# 自愈探测:发现已装工具未链则静默补
"$COG_RULES_DIR/sync-rules.sh" --heal >/dev/null 2>&1
```

## 注意

- 公开仓库:`AGENTS.md` 内容会公开,勿写敏感信息。
- 软链均指向本仓库 `AGENTS.md`;移动/删除本仓库会导致软链失效(重新 clone 后跑 `sync-rules.sh` 即恢复)。
