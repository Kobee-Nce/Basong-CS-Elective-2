-- ============================================================
-- OPTIONAL: only signed-in users can read products
-- Run in Supabase Dashboard → SQL Editor after schema.sql.
--
-- The app already requires sign-in before showing the shop. This makes
-- the database enforce it too: the anon key alone can no longer read
-- the catalog, only a request carrying a signed-in user's session.
-- ============================================================

drop policy if exists "Public can read products" on public.products;
drop policy if exists "Signed-in users can read products" on public.products;

create policy "Signed-in users can read products"
  on public.products
  for select
  to authenticated
  using (true);
