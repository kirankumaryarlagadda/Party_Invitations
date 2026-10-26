# Party Invitations

Static invitation pages, one folder per party, deployed by Vercel from `main`. No build step.

```
<party-slug>/index.html        the invite guests open      → https://<vercel-domain>/<party-slug>/
<party-slug>/host/index.html   RSVP dashboard (admin login) → https://<vercel-domain>/<party-slug>/host/
shared/supabase-config.js      Supabase URL + public anon key, used by every invite
supabase/party_rsvps.sql       the one RSVP table for all parties (keyed by party_slug)
```

## RSVPs

- Stored in Supabase table `party_rsvps` in a dedicated Supabase project (separate from FIFA/IPL Picks).
- Guests can only **insert** (RLS). Reading or deleting needs a login whose email is in `party_admins`.
- Host login = a user you create under Supabase **Authentication → Users** (turn off public sign-ups).

### One-time Supabase setup

1. Create a new Supabase project (e.g. `party-invitations`).
2. SQL editor → run `supabase/party_rsvps.sql`.
3. Authentication → Users → **Add user** with your admin email + password (auto-confirm).
4. Authentication → Sign In / Providers → turn **off** "Allow new users to sign up".
5. Settings → API → copy Project URL + `anon` public key into `shared/supabase-config.js`.

Free-tier projects pause after ~7 days with no traffic; RSVP activity keeps it awake, and a paused project can be restored from the dashboard.

## New party

1. Copy an existing folder to a new slug (lowercase, digits, dashes), e.g. `cp -r akhira-5th-birthday riya-3rd-birthday`.
2. In both `index.html` and `host/index.html`, change `PARTY_SLUG` to the new folder name.
3. Edit the invite content, push to `main`.

## Local preview

```bash
python3 -m http.server 8080
```

Then open http://localhost:8080/akhira-5th-birthday/ (absolute `/shared/...` paths need the server at the repo root).
