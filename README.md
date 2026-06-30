# CodeX

这个仓库用于整理和保存 CodeX/Codex 相关工具模块，重点放在 Windows 环境、自动化脚本和本地故障修复流程。

## 模块目录

| 模块 | 用途 | 入口 |
| --- | --- | --- |
| 修复CodeX模块异常 | 修复 Windows 环境下 sandbox、代理环境变量和 `apply_patch` 相关异常 | [查看模块](./修复CodeX模块异常/README.md) |
| CodeX查询重置到期时间 | 查询 ChatGPT/Codex reset credits 的到期时间 | [查看模块](./CodeX查询重置到期时间/README.md) |

## 目录结构

```text
CodeX/
├─ 修复CodeX模块异常/
│  ├─ README.md
│  ├─ docs/
│  └─ scripts/
└─ CodeX查询重置到期时间/
   ├─ README.md
   ├─ docs/
   └─ scripts/
```

## 使用建议

每个模块都保持独立目录：

- `README.md` 说明用途和使用方式
- `docs/` 保存详细流程
- `scripts/` 保存可执行脚本

运行脚本前请先阅读对应模块的 README。涉及凭证、令牌或本机配置的文件不要提交到 GitHub。

## 安全说明

不要提交以下内容：

- `.env`
- `auth.json`
- `access_token` / `refresh_token`
- cookie
- 私钥或密码
- 含账号凭证的截图或日志

## License

MIT
