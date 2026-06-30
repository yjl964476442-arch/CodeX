# CodeX查询重置到期时间

This package documents a safe local flow for querying ChatGPT/Codex rate-limit reset credits with the existing Codex authentication file on your machine.

## What It Does

- Reads `~/.codex/auth.json`.
- Uses `tokens.access_token` only in the `Authorization: Bearer ...` request header.
- Calls:

```text
https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

- Prints only:
  - `available_count`
  - each credit's `status`
  - each credit's `title`
  - each credit's `granted_at`
  - each credit's `expires_at`
- Converts `granted_at` and `expires_at` from UTC to local machine time.
- Does not print access tokens, refresh tokens, cookies, or full unique IDs.

## Usage

Run from PowerShell:

```powershell
.\scripts\get-rate-limit-reset-credits.ps1
```

Or from another directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\get-rate-limit-reset-credits.ps1
```

## 401 Handling

If the API returns `401`, the script reports:

```text
凭证失效，或请求没有携带 Authorization header。
```

That usually means the local Codex credential has expired or the request did not include the expected `Authorization` header.

## Security Notes

- Do not commit `~/.codex/auth.json`.
- Do not paste `access_token`, `refresh_token`, cookies, or complete unique IDs into issues, commits, logs, or chat.
- The script removes the local token variable after the request finishes.

## Example Output Shape

```json
{
  "status_code": 200,
  "available_count": 3,
  "credits": [
    {
      "status": "available",
      "title": "Full reset (Weekly + 5 hr)",
      "granted_at_local": "2026-06-12 11:59:30 +08:00",
      "expires_at_local": "2026-07-12 11:59:30 +08:00"
    }
  ]
}
```