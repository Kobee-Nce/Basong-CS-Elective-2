# Game Credits Shop — Final Exam (E-Commerce App)

Flutter e-commerce app for **Steam Wallet** and **Valorant Points** game credits, built on the
PrelimExam shop. Two roles: **admins** manage the catalog and orders, **customers** browse, fill a
cart and place orders.

| Area | Used |
|---|---|
| State management | Riverpod 3 (`flutter_riverpod`) |
| Backend | Supabase — Auth, Postgres, Row Level Security |
| Sign-in | Email + password, and Google |
| Image storage | Supabase Storage (bucket `product-images`) |
| Navigation | go_router (auth gate + role gate) |

---

## 1. Supabase setup

Open your project → **SQL Editor** and run the files in [`supabase/`](supabase) **in this order**:

| File | What it does |
|---|---|
| `01_schema.sql` | Tables `roles`, `profiles`, `categories`, `products`, `orders`, `order_items` + seed data (2 roles, 2 categories, 13 products). ⚠️ Drops these tables first (clean setup). |
| `02_functions_triggers.sql` | `handle_new_user()` + trigger `on_auth_user_created`, `is_admin()`, and the checkout function `place_order()` |
| `03_rls_policies.sql` | Enables RLS on every table and adds the policies from the permission table |
| `04_storage.sql` | Creates the public `product-images` bucket; only admins can upload/replace/delete |
| `05_make_admin.sql` | Run **after** signing up: turns one account into an admin (edit the email first) |

### Google sign-in

1. **Google Cloud Console** → APIs & Services → OAuth consent screen (set it up), then
   Credentials → *Create credentials* → *OAuth client ID* → **Web application**.
   Authorized redirect URI: `https://<your-project-ref>.supabase.co/auth/v1/callback`
2. **Supabase** → Authentication → Sign In / Providers → **Google** → enable, paste the
   Client ID and Client Secret.
3. **Supabase** → Authentication → URL Configuration → **Redirect URLs**, add:
   - `io.supabase.gamecreditsshop://login-callback/` (Android / iOS / macOS)
   - `http://localhost:3000` (web — run with `flutter run -d chrome --web-port 3000`)

The deep link is already registered in `AndroidManifest.xml` and the iOS/macOS `Info.plist`.

### App credentials

`lib/config/supabase_config.dart` holds the project URL and the **anon** key (never the
service_role key). Or pass them at run time:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## 2. Run

```bash
flutter pub get
flutter run
flutter test   # cart, pagination and formatter tests
```

---

## Roles and what each one sees

| Capability | Signed out | Customer | Admin |
|---|---|---|---|
| Sign up / log in (email or Google) | ✅ | – | – |
| View products and categories | ❌ | ✅ | ✅ |
| Add / edit / delete products | ❌ | ❌ | ✅ |
| Manage categories | ❌ | ❌ | ✅ |
| Cart, place order, own order history | ❌ | ✅ | ❌ |
| All orders + change status | ❌ | ❌ | ✅ |

Every new account starts as a **customer** (`handle_new_user` trigger).

**Customer screens:** Shop (search, category chips, price-range slider, sort, pagination —
filters carried over from the backend-filter-pagination activity) with **Add to cart** on each
card · Product details · Cart · Checkout confirmation · My Orders · Profile.

**Admin screens:** Products (same list, **Edit / Delete** on each card, **+ Add product** FAB) ·
Product form (add & edit, image upload, validation) · Categories · All orders (status
filter + status dropdown) · Profile.

## Security: why hiding a button is not enough

The app hides admin controls from customers, but that is only UX. The anon key and the REST API
are public, so anyone could call Supabase directly. The **database** enforces the rules:

- RLS is enabled on every table; every policy targets `authenticated`, so signed-out requests
  get nothing.
- `is_admin()` (SECURITY DEFINER) decides admin-only writes on `products` and `categories`,
  admin reads of all `profiles` / `orders` / `order_items`, and admin status updates.
- Customers can update only their own profile row, and only `firstname` / `lastname`
  (column privileges) — never `role_id`.
- Customers cannot insert into `orders` at all. Checkout goes through `place_order()`, which:
  - receives only product ids + quantities,
  - reads names, prices and stock **from the database**, locking each product row,
  - saves the order + items, reduces stock, and sets the status to `done`,
  - runs as **one transaction** — if anything fails (e.g. not enough stock), nothing is saved.
- `order_items` keeps a snapshot of `product_name` and `unit_price`, so past orders stay
  correct after a price change or a product delete.

### Schema notes (vs. the ER diagram)

- `order_items.product_name` was added (the snapshot required by the spec).
- `order_items.product_id` is nullable with `ON DELETE SET NULL`, so a product that was
  ordered can still be deleted without breaking order history.
- `products.price` is `NOT NULL DEFAULT 0` with `CHECK (price >= 0)`; stock has `CHECK (stock >= 0)`.

## Code structure

Screens call providers, providers call services, and **services are the only code that talks
to Supabase**.

```
lib/
  config/      Supabase URL + anon key
  core/        AppException (error kinds), formatters
  models/      Profile, ProductCategory, Product, CartItem, ShopOrder, ProductFilter …
  services/    auth, profile, category, product, storage, order  ← only Supabase code
  providers/   Riverpod: auth, profile, products/filters, categories, cart, orders, theme
  router/      go_router with the auth gate and role gate
  screens/     auth/  customer/  admin/  common/
  widgets/     product card, catalog, filters, pagination, loading/error/empty views …
supabase/      SQL to run in the Supabase SQL Editor
```

Every async provider's loading, error (including a "Permission denied" state) and empty states
are shown in the UI. Text controllers, the search debounce timer, the auth stream subscription
and the router are disposed properly.

## Submission screenshots (Supabase dashboard)

| Requirement | Where |
|---|---|
| a. Database Schema | Database → **Schema Visualizer** |
| b. Database Functions and Triggers | Database → **Functions** (`handle_new_user`, `is_admin`, `place_order`) and Database → **Triggers** (`on_auth_user_created`) |
| c. users table | Authentication → **Users** (and Table Editor → `profiles` to show roles) |
| d. RLS Policies | Authentication → **Policies** (one section per table, plus `storage.objects`) |
