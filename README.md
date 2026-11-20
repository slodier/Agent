# Agent

## Agent使用方法
```bash
curl -fsSL https://raw.githubusercontent.com/slodier/Agent/main/install.sh | bash
```

安装选项:

1. 后端: 后端 AGENTS.md + CLAUDE.md.
2. 前端: 前端 AGENTS.md + CLAUDE.md + REVIEW.md + REVIEW_PROMPT.md.
3. 独立验收清单: 仅 REVIEW.md.
4. 开发自检提示词: 仅 REVIEW_PROMPT.md.
5. 前后端综合: 合并前后端规则, 公共 Skills 与工作流保留一份, 同时安装两份审核文档与 CLAUDE.md.

脚本安装到当前目录, 不修改 `~/.codex/AGENTS.md`, 不安装 Skills. 请在目标目录的交互终端运行. 所选文件全部下载并检查成功后才写入, 已有文件保留为 `文件名.backup.随机后缀`. 下载失败不改动目标文件; 写入阶段若因磁盘等原因中断, 按输出中的备份路径恢复. 更新源为仓库 main 分支, 本地修改需推送后才会被远程安装使用.

## H5初始化
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/slodier/Agent/main/vite-h5-full-final.sh)
```
