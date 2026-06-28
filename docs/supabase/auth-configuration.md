# Supabase auth configuration — live project checklist

Steps that must be done **in the Supabase dashboard** because they can't be
applied via migrations or MCP tooling. Cross-referenced from
`docs/auth/login-signup-design.md` and `plan/feature-supabase-auth-integration-1.md`.

**Project:** `bbpleeddaquwwvexzmdc` (Dawer) · `ap-southeast-1`

---

## State verified on 2026-04-22

| Setting | Value | OK? |
|---|---|---|
| `external.email` | `true` | ✅ |
| `external.phone` | `false` | ⛔ deferred |
| `sms_provider` | `twilio` | partial — credentials not verified |
| `disable_signup` | `false` | ✅ |
| `mailer_autoconfirm` | `false` | ✅ (OTP flow requires confirmation) |
| `phone_autoconfirm` | `false` | ✅ |

Re-verify any time with:

```powershell
$key = (Get-Content .env.local | Select-String 'SUPABASE_ANON_KEY=(.+)').Matches.Groups[1].Value
Invoke-RestMethod `
  -Uri 'https://bbpleeddaquwwvexzmdc.supabase.co/auth/v1/settings' `
  -Headers @{apikey=$key} | ConvertTo-Json -Depth 4
```

---

## 1. Email OTP — required for MVP (✅ already enabled)

No action required. The live project is serving email OTP today. Two
dashboard checks worth doing before launch:

1. **Authentication › Providers › Email** — confirm "Confirm email" is **on**. This matches `mailer_autoconfirm=false` and guarantees every new email goes through OTP verification before a session is minted.
2. **Authentication › Email Templates › Magic Link** — Supabase's default template only renders a link via `{{ .ConfirmationURL }}` which redirects to `site_url` (localhost by default). For our mobile OTP flow we must replace it with a template that prominently displays `{{ .Token }}` (the 6-digit code) and omits the link entirely. Canonical body is in `docs/supabase/email-templates/ar-magic-link.html`. Subject: `رمز التحقق لدوّر: {{ .Token }}`.

### Deliverability smoke test

Run from the repo root — replace `you@example.com` with an inbox you control:

```powershell
$key = (Get-Content .env.local | Select-String 'SUPABASE_ANON_KEY=(.+)').Matches.Groups[1].Value
Invoke-RestMethod `
  -Method Post `
  -Uri 'https://bbpleeddaquwwvexzmdc.supabase.co/auth/v1/otp' `
  -Headers @{apikey=$key; 'Content-Type'='application/json'} `
  -Body '{"email":"you@example.com","create_user":false}'
```

Expected:
- HTTP 200 with empty body.
- Email lands in ≤ 60 s with a 6-digit code + a magic link.

Failure modes:
- `{"msg":"Signups not allowed for otp"}` → set `Authentication › Providers › Email › Confirm email = on`.
- Email never arrives → check `Authentication › Logs` in the dashboard for `send_sms_provider_error` / `send_email_error`.

---

## 2. Phone OTP — deferred

Current state shows `sms_provider=twilio` but `external.phone=false`, which
means the SMS provider field was filled but the channel itself is off.
To flip this on:

1. **Get Twilio credentials** — Account SID, Auth Token, Messaging Service SID (or a verified sender phone number).
2. **Authentication › Providers › Phone** in the dashboard:
   - Toggle **Enable Phone Provider** → on.
   - Paste Twilio Account SID, Auth Token, Messaging Service SID.
   - Save.
3. **Authentication › Rate Limits** — set:
   - **OTPs per phone per hour:** 3
   - **OTPs per IP per hour:** 10
   - **Messages per minute (global):** 10
4. **Authentication › SMS Templates › OTP** — replace the body with:
   ```
   رمز التحقق لتطبيق دوّر: {{ .Code }}
   لا تشاركه مع أي شخص.
   ```
5. **Smoke test** with your own phone (replace `+962791234567`):
   ```powershell
   Invoke-RestMethod `
     -Method Post `
     -Uri 'https://bbpleeddaquwwvexzmdc.supabase.co/auth/v1/otp' `
     -Headers @{apikey=$key; 'Content-Type'='application/json'} `
     -Body '{"phone":"+962791234567","create_user":true}'
   ```
6. **Update `supabase/config.toml`** — flip `[auth.sms] enable_signup = true` + `enable_confirmations = true` for local/dev parity. Commit.
7. **Update `docs/auth/login-signup-design.md` §2** — mark phone as primary, email as fallback.

Keep spend observable: Supabase dashboard → **Reports › Auth** shows SMS
cost per day.

---

## 3. Rate-limit defaults (both channels)

Regardless of which channel is live, apply these in **Authentication › Rate Limits**:

| Limit | Value | Why |
|---|---|---|
| Email OTPs per hour per IP | 30 | Stops mass OTP-floods without blocking shared NATs. |
| Email OTPs per hour per email | 5 | Real users rarely resend more than 2–3 times. |
| `/verify` attempts per hour per identifier | 10 | Brute-force protection — 10⁶ codes × 0.00001 success rate. |
| Token-refresh requests per minute per IP | 150 | Generous; typical app refreshes every 50 min. |

---

## 4. Service-role key handling

The service-role key (`SUPABASE_SERVICE_ROLE_KEY`) bypasses RLS and must
**never** ship in the Flutter app. Only edge functions and server-side
tooling should hold it.

- **Edge functions** — Supabase injects it automatically as `SUPABASE_SERVICE_ROLE_KEY` env var. No extra config.
- **Local dev scripts** — store in `.env.local` alongside the anon key; our `.gitignore` already blocks `.env.local`.
- **CI** — use repo secrets, never commit.

---

## 5. Log checkpoints

Use these dashboard tabs to debug auth incidents:

| Tab | When |
|---|---|
| **Authentication › Users** | Confirm new `auth.users` row after sign-up |
| **Authentication › Logs** | OTP send/verify failures |
| **Database › Logs** | RLS denials (`42501`), constraint violations (`23505`) |
| **Project Settings › Billing › Auth** | SMS cost tracking |

---

## Change history

- 2026-04-22 — Initial version. Email OTP live, phone deferred.
