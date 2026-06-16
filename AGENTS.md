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

## 前端项目初始化
- 识别到前端项目（存在 package.json）时，开始开发前默认执行：
  ```bash
  nvm use      # 按 .nvmrc 切换 Node 版本；无 .nvmrc 则提示
  npm i        # 安装依赖（若项目用 yarn/pnpm 则改用对应命令）
  ```
- 按 lockfile 自动判断包管理器：`package-lock.json`→npm，`yarn.lock`→yarn，`pnpm-lock.yaml`→pnpm。

## 开发完成后返回自测链接
- 前端功能开发完成后，启动本地开发服务并返回自测链接，同时给出两种：
  - 本机访问：`http://localhost:<端口>`
  - 局域网 IP 访问（方便手机/其他设备测试）：`http://<本机IP>:<端口>`
- 获取本机局域网 IP（macOS）：
  ```bash
  ipconfig getifaddr en0 || ipconfig getifaddr en1
  ```
- 端口以实际 dev server 输出为准（Vite 默认 5173，CRA/Next 默认 3000 等）。
- 若需要局域网设备访问，启动命令带上 host 暴露参数（如 Vite 的 `--host`）。
