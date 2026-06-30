# 修复CodeX模块异常

这个模块用于修复 Windows 环境下 CodeX/Codex 在 sandbox、代理环境变量和 `apply_patch` 流程中出现的异常。

## 文件说明

| 文件 | 用途 |
| --- | --- |
| [docs/windows-sandbox-proxy-fix.md](./docs/windows-sandbox-proxy-fix.md) | 修复原因、步骤和验证方式 |
| [scripts/fix-codex-windows-sandbox-proxy.ps1](./scripts/fix-codex-windows-sandbox-proxy.ps1) | 一键修复脚本 |

## 使用方式

在 PowerShell 中进入本目录后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\fix-codex-windows-sandbox-proxy.ps1
```

运行后关闭所有 CodeX / VS Code / launcher 相关窗口，再重新打开 CodeX。
