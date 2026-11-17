# Game Credits Shop — Supabase Auth, Price Filter + Pagination

CS Elective 2 · Supabase-Auth Activity (branch `backend-auth`), built on the
Supabase-Flutter Activity (branch `backend-filter-pagination`).

Builds on the PrelimExam Game Credits Shop. The product catalog now lives in a
Supabase `products` table instead of a hardcoded list, and the home screen adds:

- **Price filter** — a `RangeSlider` (₱50 steps). Releasing the slider runs a
  Supabase query with `.gte('price', min).lte('price', max)`.
- **Pagination** — 6 products per page, fetched with `.range(from, to)` plus
  `.count(CountOption.exact)` for the page buttons.
- **State management** — `ProductsController` (`ChangeNotifier`, same pattern
  as `CartController`) holds the products, price range, current page and
  loading/error state. The home screen rebuilds through `ListenableBuilder`.

The query (filter → order → paginate), from `lib/state/products_controller.dart`:

```dart
final response = await supabase
    .from('products')
    .select()
    .gte('price', selectedRange.start)   // 1. Filter
    .lte('price', selectedRange.end)
    .order('price', ascending: true)     // 2. Order
    .order('id', ascending: true)
    .range(from, to)                     // 3. Paginate
    .count(CountOption.exact);           // total rows → number of pages
```

Changing the price range always jumps back to page 1, so you never land on a
page that no longer exists.

## Authentication (`backend-auth`)

The shop now requires signing in. Two ways to sign in:

- **Email + password** — sign up / sign in with Supabase Auth.
- **GitHub** (the additional 3rd-party provider) — opens GitHub in the
  browser, then returns to the app through the deep link
  `io.supabase.gamecreditsshop://login-callback/`.

`AuthController` (`lib/state/auth_controller.dart`) listens to
`supabase.auth.onAuthStateChange`. The router uses it as its
`refreshListenable`, so signed-out users only see `/login` and signed-in
users go straight to the shop. Sign out from the account menu on the home
screen.

### GitHub provider setup

1. **GitHub → Settings → Developer settings → OAuth Apps → New OAuth App**
   - Homepage URL: `https://<your-project-ref>.supabase.co`
   - Authorization callback URL: `https://<your-project-ref>.supabase.co/auth/v1/callback`
   - Register, then copy the **Client ID** and generate a **Client secret**.
2. **Supabase → Authentication → Sign In / Providers → GitHub**: enable it,
   paste the Client ID and Client secret, and save.
3. **Supabase → Authentication → URL Configuration → Redirect URLs**: add
   `io.supabase.gamecreditsshop://login-callback/`
4. Fully stop and re-run the app (the URL scheme is registered in
   `macos/Runner/Info.plist`, `ios/Runner/Info.plist` and
   `android/app/src/main/AndroidManifest.xml`, which need a rebuild).

Optional: run [`supabase/auth.sql`](supabase/auth.sql) so the database only
lets signed-in users read products.

## Setup

1. **Create the table.** In your Supabase project open **SQL Editor**, paste
   the contents of [`supabase/schema.sql`](supabase/schema.sql) and run it.
   It creates `products`, enables Row Level Security with a public read
   policy, and seeds 13 products (3 pages).
2. **Add your keys.** From **Project Settings → API**, copy the Project URL
   and the anon / publishable key into `lib/config/supabase_config.dart`,
   or pass them at run time:

   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

   Never use the `service_role` key in the app.
3. **Install and run.**

   ```bash
   flutter pub get
   flutter run
   ```

## Files changed from PrelimExam

| File | Change |
| --- | --- |
| `supabase/schema.sql` | New: table, RLS policy, seed data |
| `lib/config/supabase_config.dart` | New: project URL + anon key |
| `lib/state/products_controller.dart` | New: filter + pagination state and queries |
| `lib/widgets/price_filter_panel.dart` | New: price `RangeSlider` |
| `lib/widgets/pagination_bar.dart` | New: Previous / page numbers / Next |
| `lib/widgets/credit_image.dart` | New: asset image or generated card for products without one |
| `lib/main.dart` | Initializes Supabase |
| `lib/screens/home_screen.dart` | Uses the controller, filter panel and pagination bar |
| `lib/router.dart` | Detail page receives the product via `extra` (fetches by id on direct links) |
| `lib/models/game_credit.dart` | `fromMap` for Supabase rows; `image` is optional |
| `lib/data/game_credits.dart` | Removed: data now comes from Supabase |
