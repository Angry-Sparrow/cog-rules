---
inclusion: always
---

# 开发工作流默认策略

> 单一事实源(single source of truth)。各 AI 编码工具(Kiro / Codex / Claude Code / Cursor / …)
> 通过软链接指向本文件,改这一份即全工具生效。详见同目录 README.md。

## 分支策略（所有写代码相关任务）
- 开始写代码前，默认先从最新的 master 拉取并切出新分支，不要直接在当前分支上改：
  ```bash
  git fetch origin
  git checkout master
  git pull origin master
  git checkout -b <语义化的新分支名>
  ```
- 分支命名用语义化前缀：`feat/`、`fix/`、`chore/`、`refactor/` 等。
- 若仓库主分支不是 master（如 main），自动改用实际主分支。
- 切分支前若有未提交改动，先提示我，不要擅自丢弃。

## 前端项目初始化（存在 package.json）
按"Node 版本 → 装依赖 → 启动"的顺序处理，全程容错、不要因为环境缺失而中断：

- **Node 版本（容错）**：
  - 有 `.nvmrc` 且装了 nvm → `nvm use`；
  - 有 `.nvmrc` 但未装 nvm → 提示我（说明当前 node 版本与 `.nvmrc` 期望版本的差异），用当前 node 继续，不强行中断；
  - 无 `.nvmrc` → 跳过版本切换，直接用当前环境的 node，不报错、不打断。
- **包管理器（按 lockfile 自动判断；装依赖与启动都用对应命令）**：
  - `pnpm-lock.yaml` → pnpm：装 `pnpm install`，启动 `pnpm dev`
  - `yarn.lock` → yarn：装 `yarn`，启动 `yarn dev`
  - `package-lock.json` 或无 lockfile → npm：装 `npm i`，启动 `npm run dev`
  - 对应包管理器未安装时 → 提示我安装（如 `corepack enable`、`npm i -g pnpm/yarn`），**不要擅自换用别的包管理器**，以免改写 lockfile。
  - 启动脚本名以 `package.json` 的 `scripts` 实际为准（可能是 `dev`/`start`/`serve` 等）。

## 后端 Go 项目初始化（存在 go.mod）
- 开发前默认：
  - 检查本机 Go 版本是否满足 `go.mod` 的 `go` 指令要求；不满足则提示我，**不擅自升级/降级工具链**。
  - 拉依赖：`go mod download`；若改动了依赖，运行 `go mod tidy`。
- 提交前自测：
  - 编译：`go build ./...`
  - 测试：`go test ./...`（涉及并发时可加 `go test -race ./...`）
  - 若项目使用 `golangci-lint`（存在 `.golangci.yml` 或 CI 中配置）→ 跑 `golangci-lint run`；未安装则提示我，不阻断。
- 运行本地服务：按项目实际入口（如 `go run ./cmd/<svc>`、或 `Makefile` 的 `make run`）。

## 开发完成后返回自测链接（前端 dev server / 后端 HTTP 服务通用）
- 启动了本地可访问的服务（前端 dev server、后端 HTTP 服务等）后，返回自测链接，同时给出两种：
  - 本机访问：`http://localhost:<端口>`
  - 局域网 IP 访问（方便手机/其他设备测试）：`http://<本机IP>:<端口>`
- 获取本机局域网 IP（macOS）：
  ```bash
  ipconfig getifaddr en0 || ipconfig getifaddr en1
  ```
- 端口以服务实际监听/输出为准（Vite 默认 5173，CRA/Next 默认 3000，Go 服务按代码配置等）。
- 若需要局域网设备访问，启动命令带上对外暴露参数（如 Vite 的 `--host`；Go 服务监听 `0.0.0.0`）。
