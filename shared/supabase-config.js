// Public Supabase settings shared by every invitation (dedicated "party-invitations" project).
// The anon key is safe to ship to browsers — RLS on party_rsvps lets guests insert only;
// reading replies requires a login listed in party_admins. NEVER put the service_role key here.
window.PARTY_SUPABASE = {
  url: 'https://fcehawklcgfeulblirbn.supabase.co',     // Settings → API → Project URL
  anonKey: 'sb_publishable_6qRbcNYawyPV2L8Fy85Iow_2DaY0n2L'             // Settings → API → anon public
};
