# Execution Flow

## Goal

Query local Codex rate-limit reset credits safely without exposing credentials.

## Steps

1. Read the local Codex auth file:

```text
~/.codex/auth.json
```

2. Extract only:

```text
tokens.access_token
```

3. Send a GET request to:

```text
https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

with:

```text
Authorization: Bearer <access_token>
```

4. Parse the JSON response.

5. Return only the allowed fields:

```text
available_count
credits[].status
credits[].title
credits[].granted_at
credits[].expires_at
```

6. Convert `granted_at` and `expires_at` from UTC to local time.

7. If the HTTP status code is `401`, report that the credential is expired or the Authorization header was missing.

## Redaction Rules

Never print or commit:

- `access_token`
- `refresh_token`
- cookies
- full unique IDs
- the complete `auth.json` content

## Local Verification

The script can be verified by running:

```powershell
.\scripts\get-rate-limit-reset-credits.ps1
```

Expected output is a compact JSON object containing `status_code`, `available_count`, and sanitized credit summaries.
