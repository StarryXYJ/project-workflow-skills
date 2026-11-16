# Git 基础配置参考

以下是新项目的起点，不是所有项目必须复制的模板。保留已有仓库的配置、文件编码、换行策略和团队约定；涉及批量归一化或已跟踪内容时先评估 diff 和工具兼容性。

## 通用 .gitignore

按实际需要添加以下规则；项目可能有同名的合法输入文件，应先检查。Git 只对未跟踪文件生效，忽略规则不追溯移除索引中的文件。

```gitignore
# 操作系统和编辑器本地状态
.DS_Store
Thumbs.db
.vs/
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/launch.json
!.vscode/tasks.json

# 本地环境和临时文件
.env
.env.*
!.env.example
*.tmp
*.swp
```

`.vscode` 文件是否共享取决于项目，例外仅是建议，不包含敏感信息。`.env.example` 应只含无秘密的示例值；如果有其他明确需要共享的环境模板，按需添加例外。勿忽略整个配置目录或所有日志、测试数据、文档及二进制资产而未经检查。

按检测到的工具链从项目文档或官方模板选取必要规则，例如 Node.js 的 `node_modules/`、Python 的 `__pycache__/` 和 `.venv/`、.NET 的 `bin/` 与 `obj/`。检查匹配范围和嵌套目录是否包含手写或必须版本控制的文件。保留实际使用的锁文件及可复现构建必需文件；忽略其他生成目录前先确认其用途。

## 文本编码与编辑器设置

新建普通源码和文档推荐 UTF-8 无 BOM；Markdown、JSON、YAML 等优先 UTF-8。使用 LF 作为新项目的通用换行默认值，末尾保留换行。遵循特定工具格式要求（例如必须使用 CRLF 或其他编码的文件）；已有文件和既有编码约定不批量转换。缩进、行尾空格等沿用现有风格，勿设置对整个项目有副作用的默认格式。

无现有 `.editorconfig` 时，可按需要使用以下最小配置，并根据项目实际情况调整；它依赖编辑器支持，不能作为编码检查的唯一证据：

```editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true

[*.{bat,cmd}]
end_of_line = crlf
```

若 Windows 脚本、旧工具或特殊文本格式有不同编码/换行要求，增加有针对性的例外；已有项目仅对适合统一的文件设置规则。不要无差别设置 `trim_trailing_whitespace`，某些格式（如 Markdown）可能有语义差异。

## Git 属性

新项目可从以下最小 `.gitattributes` 开始，让 Git 识别文本并做自动换行处理：

```gitattributes
* text=auto
```

如项目明确需要一致的检出换行，可对确定的文本类型增加 `text eol=lf` 或 `text eol=crlf`；仅对确定的二进制类型设置 `-text`。属性影响 Git 索引与检出行为，不能替代 `.editorconfig` 或自动把既有工作树转换成 UTF-8。先用 `git ls-files --eol` 和 diff 评估，**不要自动重新归一化**。对 Git LFS、工具生成文件或特殊编码沿用项目既定设置。

## 初始化与验证

先用 `git rev-parse --show-toplevel` 确认是否已有父仓库；只有用户要求在确认的目标目录初始化且没有现有工作树时运行 `git init`。不自动设置全局 Git 用户信息、默认分支或远程地址，不添加未经确认的 hooks。检查 `git status --short`、配置文件 diff、代表路径的 `git check-ignore -v -- <path>`；对本应保留的路径确认不被忽略，涉及被跟踪文件时注意 `git check-ignore` 默认不报告它们。不要输出秘密内容。
