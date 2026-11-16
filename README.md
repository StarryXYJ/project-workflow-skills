# Project Workflow Skills

一套面向软件项目的 Codex skills，参考 [Gal.Net](https://github.com/StarryXYJ/Gal.Net) 的实践，提供可裁剪的工作流、文档同步、经验总结和 Git 初始化。遵循目标项目已有约定和用户指令。

## 包含的 skills

| Skill | 用途 |
| --- | --- |
| `project-workflow` | 功能开发（feature）、快速功能（quick）、缺陷修复（hotfix）、范围审查与重构（refactor） |
| `project-docs-sync` | 根据已验证的代码和测试事实同步文档 |
| `project-lessons` | 记录有证据、可复用的项目经验 |
| `project-git-init` | 初始化或完善 Git 忽略、属性与编码配置 |

feature 和 refactor 在每个实现阶段完成并验证后提交；quick 和 hotfix 在全部完成并验收后提交。feature 和 refactor 完成后可选择保留阶段提交、合并为多个提交或合并为单个提交；重写历史前需确认选择和提交范围。refactor 在修复前会请用户确认缺陷列表。实际执行还受用户指令及项目规则约束。

## 个人安装

在 Codex 中输入：

```text
使用 $skill-installer 从 GitHub 仓库 StarryXYJ/project-workflow-skills 安装 skills/project-workflow、skills/project-docs-sync、skills/project-lessons 和 skills/project-git-init。
```

安装到当前用户的 Codex skills 目录后，可在不同项目中调用；安装器遇到同名目录会停止，更新前请检查本地修改。也可以只安装需要的 skill，但单独安装 `project-workflow` 时，其余三个可选辅助 skill 不会随之自动安装。新安装的 skill 通常从下一次对话轮次开始可用。

## 项目安装

macOS 或 Linux 在目标项目根目录运行（需要 `sh`、`curl`、Git 和网络）：

```sh
curl -fsSL https://raw.githubusercontent.com/StarryXYJ/project-workflow-skills/36c0e08ed91cc5103b9c197e58f0ece10b55c0a0/scripts/install-project.sh | sh
```

Windows 可在目标项目根目录运行以下 PowerShell 7 命令（需要 `pwsh`、Git 和网络；macOS 和 Linux 装有 PowerShell 7 时也可使用）：

```powershell
pwsh -NoProfile -Command "& ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/StarryXYJ/project-workflow-skills/main/scripts/install-project.ps1')))"
```

脚本将四个 skill 安装到当前目录的 `.agents/skills/` 并显示来源提交。目标已有同名 skill 时会停止，不覆盖已有内容。请在执行前查看仓库中的安装脚本；sh 命令固定脚本版本，PowerShell 命令从 `main` 下载脚本。默认均安装 `main` 的 skill 内容。

使用 `sh` 安装后，可在项目根目录运行以下命令更新。更新前会将本地 skill 与安装时的版本逐一比较；如果有本地修改或缺失，停止更新并保留原文件。

```sh
curl -fsSL https://raw.githubusercontent.com/StarryXYJ/project-workflow-skills/36c0e08ed91cc5103b9c197e58f0ece10b55c0a0/scripts/install-project.sh | sh -s -- --update
```

`sh` 安装器会在 `.agents/skills/.project-workflow-skills-version` 记录来源 commit。早期安装或 PowerShell 安装没有这个记录时，首次更新需要加上 `--from <原安装时输出的完整commit>`；如果不知道原版本，请先备份并人工比较，不要猜测。更新中断时，脚本会提示原文件备份位置。

需要固定版本时，可下载脚本后运行：PowerShell 传入 `-Ref <tag或commit>`，sh 传入 `--ref <tag或commit>`；这些参数固定 skill 内容的版本。若也要固定脚本本身，请从相同 tag 或 commit 的 URL 下载脚本。

将 `skills/` 下需要的完整目录（包括 `SKILL.md`、`references/` 和 `agents/`，如存在）复制到目标项目的 `.agents/skills/`，按项目需要纳入 Git。不要只复制 `SKILL.md`，否则相对引用的参考文件会缺失。目标项目已有同名 skill 时先比较差异，避免覆盖项目改动。

```text
你的项目/
└── .agents/
    └── skills/
        ├── project-workflow/
        ├── project-docs-sync/
        ├── project-lessons/
        └── project-git-init/
```

为方便重现，建议记录安装时的仓库提交或发布版本；更新前比较来源和目标文件。个人安装与项目安装根据需要选择即可，避免维护多份互相冲突的副本。

## 使用示例

- `使用 $project-workflow 的 feature 流程实现……`
- `使用 $project-workflow 的 quick 流程完成……`
- `使用 $project-workflow 的 hotfix 流程修复……`
- `使用 $project-workflow 的 refactor 流程审查 src/，先列出缺陷供我确认。`
- `使用 $project-docs-sync 核对这次改动涉及的文档。`
- `使用 $project-lessons 总结这个项目中可复用的经验。`
- `使用 $project-git-init 检查项目的 Git 和文本编码配置。`

## 维护与验证

本仓库的 `skills/` 是维护源。编辑后检查 frontmatter、相对引用、流程边界及行为；安装副本不会自动随仓库更新。结构校验不能代替实际任务验证，涉及 Git 提交、用户确认和历史整理的行为应在隔离的测试仓库中验证。

尚未指定开源许可证；公开可见不代表授予再分发或修改的许可。
