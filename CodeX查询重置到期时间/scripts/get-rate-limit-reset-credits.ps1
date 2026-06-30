$ErrorActionPreference = 'Stop'

$authPath = Join-Path $HOME '.codex/auth.json'

if (-not (Test-Path -LiteralPath $authPath)) {
    throw 'auth.json not found at ~/.codex/auth.json'
}

$auth = Get-Content -LiteralPath $authPath -Raw | ConvertFrom-Json
$token = $auth.tokens.access_token

if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'tokens.access_token not found in ~/.codex/auth.json'
}

$headers = @{
    Authorization = "Bearer $token"
}

function Convert-ToLocalTimeString {
    param (
        [Parameter(Mandatory = $false)]
        [string] $Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return ([DateTimeOffset]::Parse($Value)).ToLocalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
}

try {
    $response = Invoke-WebRequest `
        -Uri 'https://chatgpt.com/backend-api/wham/rate-limit-reset-credits' `
        -Headers $headers `
        -Method GET `
        -UseBasicParsing

    $body = $response.Content | ConvertFrom-Json
    $credits = @()

    foreach ($credit in @($body.credits)) {
        $credits += [PSCustomObject]@{
            status           = $credit.status
            title            = $credit.title
            granted_at_local = Convert-ToLocalTimeString -Value $credit.granted_at
            expires_at_local = Convert-ToLocalTimeString -Value $credit.expires_at
        }
    }

    [PSCustomObject]@{
        status_code     = [int] $response.StatusCode
        available_count = $body.available_count
        credits         = $credits
    } | ConvertTo-Json -Depth 8
}
catch {
    $statusCode = $null

    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
        $statusCode = [int] $_.Exception.Response.StatusCode
    }

    if ($statusCode -eq 401) {
        [PSCustomObject]@{
            status_code = 401
            message     = '凭证失效，或请求没有携带 Authorization header。'
        } | ConvertTo-Json -Depth 4
    }
    else {
        [PSCustomObject]@{
            status_code = $statusCode
            message     = $_.Exception.Message
        } | ConvertTo-Json -Depth 4
    }
}
finally {
    Remove-Variable token -ErrorAction SilentlyContinue
}
