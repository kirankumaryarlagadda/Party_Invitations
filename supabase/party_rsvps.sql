-- Party Invitations: one RSVP table shared by every invite folder.
-- Lives in its own Supabase project (separate from FIFA/IPL Picks).
-- Run once in the Supabase SQL editor. Safe to re-run.

CREATE TABLE IF NOT EXISTS party_rsvps (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  party_slug  TEXT NOT NULL CHECK (party_slug ~ '^[a-z0-9-]{1,60}$'),
  name        TEXT NOT NULL CHECK (char_length(trim(name)) BETWEEN 1 AND 80),
  contact     TEXT CHECK (contact IS NULL OR char_length(contact) <= 120),
  attending   TEXT NOT NULL CHECK (attending IN ('yes', 'no', 'maybe')),
  adults      INT  NOT NULL DEFAULT 0 CHECK (adults BETWEEN 0 AND 20),
  kids        INT  NOT NULL DEFAULT 0 CHECK (kids BETWEEN 0 AND 20),
  note        TEXT CHECK (note IS NULL OR char_length(note) <= 500),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS party_rsvps_slug_created_idx ON party_rsvps (party_slug, created_at DESC);

-- Who may read RSVPs on the host pages. Add a co-host by inserting their email
-- and creating them a user under Authentication → Users.
CREATE TABLE IF NOT EXISTS party_admins (
  email TEXT PRIMARY KEY CHECK (email = lower(email))
);
INSERT INTO party_admins (email) VALUES ('kiran.yarlagadda123@gmail.com') ON CONFLICT DO NOTHING;

ALTER TABLE party_rsvps  ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_admins ENABLE ROW LEVEL SECURITY;  -- no policies: invisible to the API

CREATE OR REPLACE FUNCTION public.is_party_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM party_admins WHERE email = lower(auth.jwt() ->> 'email'));
$$;

-- Guests (no login) can submit, but can never read anyone's reply.
DROP POLICY IF EXISTS "party_rsvps_insert_anyone" ON party_rsvps;
CREATE POLICY "party_rsvps_insert_anyone"
  ON party_rsvps FOR INSERT TO anon, authenticated
  WITH CHECK (true);

-- Only listed admins can read / clean up.
DROP POLICY IF EXISTS "party_rsvps_select_admin" ON party_rsvps;
CREATE POLICY "party_rsvps_select_admin"
  ON party_rsvps FOR SELECT TO authenticated
  USING (public.is_party_admin());

DROP POLICY IF EXISTS "party_rsvps_delete_admin" ON party_rsvps;
CREATE POLICY "party_rsvps_delete_admin"
  ON party_rsvps FOR DELETE TO authenticated
  USING (public.is_party_admin());
