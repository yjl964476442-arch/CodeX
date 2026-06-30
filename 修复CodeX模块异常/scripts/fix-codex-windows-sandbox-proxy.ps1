$ErrorActionPreference = "Stop"

$configPath = Join-Path $env:USERPROFILE ".codex\config.toml"
$markerPath = Join-Path $env:USERPROFILE ".codex.sandbox\setup_marker.json"

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Codex config not found: $configPath"
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$configPath.bak-$timestamp"
Copy-Item -LiteralPath $configPath -Destination $backupPath -Force

$text = Get-Content -Raw -LiteralPath $configPath

if ($text -match '(?m)^\[features\]$') {
    if ($text -match '(?m)^network_proxy\s*=') {
        $text = [regex]::Replace($text, '(?m)^network_proxy\s*=.*$', 'network_proxy = true')
    } else {
        $text = [regex]::Replace($text, '(?m)^\[features\]\r?\n', "[features]`r`nnetwork_proxy = true`r`n")
    }
} else {
    $text = $text.TrimEnd() + "`r`n`r`n[features]`r`nnetwork_proxy = true`r`n"
}

$policyBlock = @'
[shell_environment_policy]
inherit = "all"
exclude = ["HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"]
'@

if ($text -match '(?ms)^\[shell_environment_policy\]\s*.*?(?=^\[|\z)') {
    $text = [regex]::Replace(
        $text,
        '(?ms)^\[shell_environment_policy\]\s*.*?(?=^\[|\z)',
        $policyBlock.TrimEnd() + "`r`n`r`n"
    )
} else {
    $text = $text.TrimEnd() + "`r`n`r`n" + $policyBlock.TrimEnd() + "`r`n"
}

Set-Content -LiteralPath $configPath -Value $text -Encoding UTF8

if (Test-Path -LiteralPath $markerPath) {
    $marker = Get-Content -Raw -LiteralPath $markerPath | ConvertFrom-Json
    $marker.proxy_ports = @()
    $marker | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $markerPath -Encoding UTF8
    $markerStatus = "cleared"
} else {
    $markerStatus = "missing"
}

Write-Output "Updated: $configPath"
Write-Output "Backup:  $backupPath"
Write-Output "Marker:  $markerStatus"
Write-Output ""
Write-Output "Now close all Codex / VS Code / launcher processes and start Codex again."
Write-Output "After restart, verify that proxy env vars are empty in tool shells and apply_patch add/delete succeeds."
