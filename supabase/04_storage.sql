-- ============================================================
-- Game Credits Shop (Final Exam) — 04 STORAGE (product images)
-- Run after 03_rls_policies.sql.
--
-- Bucket `product-images` is public, so the app can show images with a
-- plain URL. Only admins may upload, replace or delete images.
-- ============================================================

  insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  values (
    'product-images',
    'product-images',
    true,
    5242880, -- 5 MB
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']
  )
  on conflict (id) do update
    set public = excluded.public,
        file_size_limit = excluded.file_size_limit,
        allowed_mime_types = excluded.allowed_mime_types;

  drop policy if exists "product images read"   on storage.objects;
  drop policy if exists "admin upload product images" on storage.objects;
  drop policy if exists "admin update product images" on storage.objects;
  drop policy if exists "admin delete product images" on storage.objects;

  create policy "product images read"
    on storage.objects for select
    to authenticated
    using ( bucket_id = 'product-images' );

  create policy "admin upload product images"
    on storage.objects for insert
    to authenticated
    with check ( bucket_id = 'product-images' and (select public.is_admin()) );

  create policy "admin update product images"
    on storage.objects for update
    to authenticated
    using ( bucket_id = 'product-images' and (select public.is_admin()) )
    with check ( bucket_id = 'product-images' and (select public.is_admin()) );

  create policy "admin delete product images"
    on storage.objects for delete
    to authenticated
    using ( bucket_id = 'product-images' and (select public.is_admin()) );
