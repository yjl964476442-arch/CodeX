# 修复CodeX模块异常

Use this when Codex on Windows fails during `apply_patch` or sandbox setup because the Windows sandbox helper keeps picking up a local proxy port.

## Symptoms

- `apply_patch` fails on Windows.
- Codex may show a Windows sandbox / COM+ / firewall related error.
- `%USERPROFILE%\.codex.sandbox\setup_marker.json` contains a local proxy port, for example:

```json
"proxy_ports": [4780]
```

- Clearing `setup_marker.json` alone does not stick, because existing Codex / VS Code / launcher processes still have proxy environment variables and write the port back.

## Root Cause

Codex itself needs the network proxy, but tool and sandbox shells inherit these proxy environment variables:

```text
HTTP_PROXY
HTTPS_PROXY
ALL_PROXY
http_proxy
https_proxy
all_proxy
```

The Windows sandbox helper sees those variables, records the local proxy port in:

```text
%USERPROFILE%\.codex.sandbox\setup_marker.json
```

Then `apply_patch` can trigger `codex-windows-sandbox-setup.exe`, which tries to refresh Windows sandbox / firewall state and may fail.

## Fix

Keep Codex's own network proxy enabled, but prevent tool / sandbox shells from inheriting proxy variables.

Edit:

```text
%USERPROFILE%\.codex\config.toml
```

Add or update these blocks:

```toml
[features]
network_proxy = true

[shell_environment_policy]
inherit = "all"
exclude = ["HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"]
```

Keep your existing Windows sandbox mode. If you want strong isolation, keep:

```toml
[windows]
sandbox = "elevated"
```

## Restart

After editing the config, close all Codex / VS Code / launcher processes and start Codex again.

This restart is required. Existing processes may still carry the old proxy variables in their process environment.

## Clear Marker Once

After restarting, clear the marker if it exists:

```powershell
$markerPath = Join-Path $env:USERPROFILE '.codex.sandbox\setup_marker.json'
if (Test-Path -LiteralPath $markerPath) {
    $marker = Get-Content -Raw -LiteralPath $markerPath | ConvertFrom-Json
    $marker.proxy_ports = @()
    $marker | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $markerPath -Encoding UTF8
}
```

If the file does not exist, that is fine.

## Verify

Run this in a Codex tool shell after restart:

```powershell
$names = 'HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','http_proxy','https_proxy','all_proxy'
foreach ($n in $names) {
    "${n}=$([Environment]::GetEnvironmentVariable($n, 'Process'))"
}

$markerPath = Join-Path $env:USERPROFILE '.codex.sandbox\setup_marker.json'
if (Test-Path -LiteralPath $markerPath) {
    Get-Content -Raw -LiteralPath $markerPath
} else {
    'marker_missing'
}
```

Expected:

- All six proxy variables are empty in tool / sandbox shells.
- `setup_marker.json` is missing, or `proxy_ports` is `[]`.
- `apply_patch` add and delete both succeed.

## Notes

- This keeps Codex network proxy support enabled through `network_proxy = true`.
- It only prevents child tool / sandbox shells from inheriting proxy environment variables.
- This allows `[windows] sandbox = "elevated"` to keep working without repeatedly trying to configure the proxy port.
