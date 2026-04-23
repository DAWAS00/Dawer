# Supabase Backend — Ops Guide

End-to-end reference for running, migrating, and deploying the dwaar Supabase backend.

## Project layout

```
supabase/
├── config.toml                 # CLI config (local port numbers, auth toggles)
├── migrations/                 # Numbered SQL migrations, applied in order
├── functions/
│   └── calculate_reward/       # Edge Function (Deno/TypeScript)
└── seed.sql                    # Local-only development seed
```

All migrations are timestamped (`YYYYMMDDHHMMSS_description.sql`) and **idempotent where possible** — re-running against an existing database should no-op or skip via `ON CONFLICT DO NOTHING`.

## Environments

| Name | Project ref | URL | Purpose |
|---|---|---|---|
| dev | `[FILL: dev-ref]` | `https://[FILL].supabase.co` | Active development |
| prod | `[FILL: prod-ref]` | `https://[FILL].supabase.co` | Live app (Phase 4) |

The Flutter client picks one at build time via `.env.local` + `--dart-define-from-file=.env.local`.

## First-time setup

```bash
# install CLI
npm install -g supabase

# authenticate once
supabase login

# link the local repo to your dev project
supabase link --project-ref [FILL: dev-ref]
```

## Applying migrations

```bash
# dry run (inspect diff, no writes)
supabase db push --dry-run

# apply
supabase db push
```

Or, when using the Supabase MCP server inside Windsurf, Cascade applies them via `mcp0_apply_migration` per file.

## Running locally (optional)

```bash
supabase start            # boots Postgres + Realtime + Studio at :54323
supabase db reset         # drops + replays all migrations + runs seed.sql
supabase stop
```

## Edge Functions

```bash
# deploy
supabase functions deploy calculate_reward --project-ref [FILL: dev-ref]

# inject secrets (example — none required for calculate_reward yet)
# supabase secrets set KEY=value --project-ref [FILL: dev-ref]

# invoke from shell
curl -L -X POST 'https://[FILL].supabase.co/functions/v1/calculate_reward' \
  -H 'Authorization: Bearer [anon-key]' \
  -H 'Content-Type: application/json' \
  --data '{"waste_types":["plastic"],"estimated_weight_kg":10,"distance_km":3.5,"is_urgent":false}'
```

## Promotion (dev → prod)

1. Merge PR containing new migrations to `main`.
2. CI runs `supabase db push --dry-run` against prod — must pass.
3. On approval, run `supabase db push --project-ref [FILL: prod-ref]`.
4. Deploy updated Edge Functions to prod.
5. Update prod Flutter build flavor and release.

## Backup & restore

- Supabase runs nightly Postgres backups automatically (Pro tier and above).
- For local snapshots: `supabase db dump -f snapshot.sql`.
- Restore: `psql "$(supabase status --output env | grep DB_URL | cut -d= -f2)" < snapshot.sql`.

## Related

- [rls-matrix.md](rls-matrix.md) — who can read / write what
- [edge-functions.md](edge-functions.md) — server-side function catalogue
- [user-signup.md](user-signup.md) — sign-up flow (role + DB persistence + validation)
- `../research/real-time-rider-tracking-research.md` — future live tracking plan
