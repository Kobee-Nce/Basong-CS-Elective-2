-- ============================================================
-- Game Credits Shop (Final Exam) — 03 ROW LEVEL SECURITY
-- Run after 02_functions_triggers.sql.
--
-- RLS is ON for every table. Every policy targets `authenticated`,
-- so signed-out requests (the `anon` role) get NO access anywhere.
-- With RLS on, anything that has no policy is denied.
--
-- Why hiding a button is not security: the anon key and the REST API
-- are public. Anyone can skip the app and call the API directly, so the
-- database itself has to refuse what a role may not do.
-- ============================================================

alter table public.profiles    enable row level security;
alter table public.roles       enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

-- ------------------------------------------------------------
-- profiles
--   Customer: read + update own row only, never the role
--   Admin:    read all profiles
-- ------------------------------------------------------------
create policy "profiles read own"
  on public.profiles for select
  to authenticated
  using ( id = (select auth.uid()) );

create policy "admin read all profiles"
  on public.profiles for select
  to authenticated
  using ( (select public.is_admin() as is_admin) );

create policy "customer update own profile"
  on public.profiles for update
  to authenticated
  using ( id = (select auth.uid()) and not (select public.is_admin()) )
  with check ( id = (select auth.uid()) );

-- "Never the role": the policy above picks the row, these grants pick
-- the columns. Signed-in users may only change their names, so an
-- update that touches role_id (or id/email) is rejected.
revoke update on public.profiles from anon, authenticated;
grant  update (firstname, lastname) on public.profiles to authenticated;

-- ------------------------------------------------------------
-- roles
--   Customer: read      Admin: read
-- ------------------------------------------------------------
create policy "roles read"
  on public.roles for select
  to authenticated
  using ( true );

-- ------------------------------------------------------------
-- categories
--   Customer: read      Admin: read, add, edit, delete
-- ------------------------------------------------------------
create policy "categories read"
  on public.categories for select
  to authenticated
  using ( true );

create policy "create category"
  on public.categories for insert
  to authenticated
  with check ( (select public.is_admin() as is_admin) );

create policy "update category"
  on public.categories for update
  to authenticated
  using ( (select public.is_admin() as is_admin) )
  with check ( (select public.is_admin() as is_admin) );

create policy "delete category"
  on public.categories for delete
  to authenticated
  using ( (select public.is_admin() as is_admin) );

-- ------------------------------------------------------------
-- products
--   Customer: read      Admin: read, add, edit, delete
-- ------------------------------------------------------------
create policy "products read"
  on public.products for select
  to authenticated
  using ( true );

create policy "create product"
  on public.products for insert
  to authenticated
  with check ( (select public.is_admin() as is_admin) );

create policy "update product"
  on public.products for update
  to authenticated
  using ( (select public.is_admin() as is_admin) )
  with check ( (select public.is_admin() as is_admin) );

create policy "delete product"
  on public.products for delete
  to authenticated
  using ( (select public.is_admin() as is_admin) );

-- ------------------------------------------------------------
-- orders
--   Customer: read own orders only
--   Admin:    read all, update status
-- Customers never insert here directly: checkout goes through
-- place_order(), which checks stock and prices inside the database.
-- ------------------------------------------------------------
create policy "orders read own"
  on public.orders for select
  to authenticated
  using ( user_id = (select auth.uid()) );

create policy "admin read all orders"
  on public.orders for select
  to authenticated
  using ( (select public.is_admin() as is_admin) );

create policy "admin update order status"
  on public.orders for update
  to authenticated
  using ( (select public.is_admin() as is_admin) )
  with check ( (select public.is_admin() as is_admin) );

-- Admins may change the status column only (not total or owner).
revoke update on public.orders from anon, authenticated;
grant  update (status) on public.orders to authenticated;

-- ------------------------------------------------------------
-- order_items
--   Customer: read items of own orders only
--   Admin:    read all
-- ------------------------------------------------------------
create policy "order items read own"
  on public.order_items for select
  to authenticated
  using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and o.user_id = (select auth.uid())
    )
  );

create policy "admin read all order items"
  on public.order_items for select
  to authenticated
  using ( (select public.is_admin() as is_admin) );
