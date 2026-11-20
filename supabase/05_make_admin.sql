-- ============================================================
-- Game Credits Shop (Final Exam) — 05 MAKE AN ADMIN
-- Every account starts as a customer. To get an admin:
--   1. Sign up in the app with the account you want as admin.
--   2. Replace the email below and run this in the SQL Editor.
-- (The SQL Editor runs as the database owner, so RLS and the column
--  grants that stop users from changing their own role don't apply.)
-- ============================================================

update public.profiles
   set role_id = (select id from public.roles where role = 'admin')
 where email = 'admin@example.com';   -- ← change this

-- Record who set up the roles (roles.encoded_by → auth.users.id).
update public.roles
   set encoded_by = (select id from auth.users where email = 'admin@example.com')
 where encoded_by is null;

-- Check:
select p.email, p.firstname, p.lastname, r.role
from public.profiles p
join public.roles r on r.id = p.role_id
order by r.role, p.email;
