-- ============================================================
-- Game Credits Shop (Final Exam) — 02 FUNCTIONS + TRIGGERS
-- Run after 01_schema.sql.
-- ============================================================

-- ------------------------------------------------------------
-- handle_new_user (trigger function)
-- Every new auth user gets a profile with the 'customer' role.
--
-- Same body as the instructor's setup. The only addition: Google
-- sign-ins send `full_name` instead of firstname/lastname, so the
-- name is split from it when firstname/lastname are missing.
-- SECURITY DEFINER is required because the trigger runs as Supabase's
-- auth service, which has no permission to write to public.profiles.
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_full text := trim(coalesce(new.raw_user_meta_data->>'full_name',
                               new.raw_user_meta_data->>'name', ''));
begin
  insert into public.profiles (id, email, firstname, lastname, role_id)
  values (
    new.id,
    new.email,
    coalesce(
      new.raw_user_meta_data->>'firstname',
      case when position(' ' in v_full) > 0
           then regexp_replace(v_full, '\s+\S+$', '')
           else nullif(v_full, '') end
    ),
    coalesce(
      new.raw_user_meta_data->>'lastname',
      case when position(' ' in v_full) > 0
           then substring(v_full from '(\S+)$') end
    ),
    (select id from public.roles where role = 'customer')
  );
  return new;
end;
$$;

-- Trigger: run handle_new_user after every sign-up (email or Google).
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- is_admin()
-- True when the signed-in user's profile has the 'admin' role.
-- SECURITY DEFINER so it can read profiles/roles without being
-- blocked by (or looping through) the RLS policies that call it.
-- ------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = auth.uid() and r.role = 'admin'
  );
end;
$$;

-- ------------------------------------------------------------
-- place_order(p_items)  — the checkout
--
-- p_items: [{"product_id": 1, "quantity": 2}, ...]
-- The app sends ONLY product ids and quantities. Names, prices and
-- stock are read from the database here, at checkout time.
--
-- A Postgres function runs as one transaction: if anything fails
-- (not enough stock, deleted product, bad quantity) an exception is
-- raised and NOTHING is saved — no order, no items, no stock change.
--
-- Steps:
--   1. store the order in `orders` (status 'pending')
--   2. for each product: lock the row, check stock, reduce stock,
--      save an order_items row with the name + unit price snapshot
--   3. set the order total and status = 'done'
-- ------------------------------------------------------------
create or replace function public.place_order(p_items jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_order    public.orders%rowtype;
  v_line     record;
  v_product  record;
  v_total    numeric(12, 2) := 0;
  v_price    numeric(12, 2);
begin
  if v_user is null then
    raise exception 'You must be signed in to place an order.'
      using errcode = '42501';
  end if;

  if public.is_admin() then
    raise exception 'Admin accounts cannot place orders.'
      using errcode = '42501';
  end if;

  if p_items is null
     or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) = 0 then
    raise exception 'Your cart is empty.';
  end if;

  -- 1. Store the order.
  insert into public.orders (user_id, status, total)
  values (v_user, 'pending', 0)
  returning * into v_order;

  -- 2. One line per product (duplicates merged). Ordered by id so two
  --    checkouts locking the same products can't deadlock.
  for v_line in
    select (item->>'product_id')::bigint as product_id,
           sum((item->>'quantity')::int)  as quantity
    from jsonb_array_elements(p_items) as item
    group by 1
    order by 1
  loop
    if v_line.quantity is null or v_line.quantity <= 0 then
      raise exception 'Quantities must be at least 1.';
    end if;

    -- Lock the product row until this transaction ends.
    select id, name, price, stock
      into v_product
      from public.products
     where id = v_line.product_id
       for update;

    if not found then
      raise exception 'A product in your cart is no longer available.';
    end if;

    if v_product.stock < v_line.quantity then
      raise exception 'Not enough stock for "%": only % left.',
        v_product.name, v_product.stock;
    end if;

    update public.products
       set stock = stock - v_line.quantity
     where id = v_product.id;

    v_price := round(v_product.price::numeric, 2);

    insert into public.order_items
      (order_id, product_id, product_name, unit_price, quantity)
    values
      (v_order.id, v_product.id, v_product.name, v_price, v_line.quantity);

    v_total := v_total + v_price * v_line.quantity;
  end loop;

  -- 3. Total from database prices, then mark the order done.
  update public.orders
     set total = v_total,
         status = 'done'
   where id = v_order.id
  returning * into v_order;

  return jsonb_build_object(
    'order_id',   v_order.id,
    'total',      v_order.total,
    'status',     v_order.status,
    'created_at', v_order.created_at
  );
end;
$$;

-- Only signed-in users may call the checkout.
revoke execute on function public.place_order(jsonb) from public, anon;
grant  execute on function public.place_order(jsonb) to authenticated;
