# DAPZ DIGITAL v2.0 — Supabase Backend Setup

This guide prepares the database layer. It does not connect the live website yet because the Supabase project URL and publishable key have not been supplied/configured.

## 1. Create a Supabase project

1. Create a project in the Supabase dashboard.
2. Save the database password securely; do not put it in frontend files.
3. Open **SQL Editor**.
4. Run `supabase/migrations/001_initial_schema.sql` in the SQL Editor.
5. Confirm that `profiles`, `services`, `orders`, and `payments` exist under the `public` schema.

## 2. Configure the first admin

1. Register the owner's account through Supabase Auth after the frontend authentication flow is implemented.
2. Find that account's UUID in **Authentication → Users**.
3. In SQL Editor, run the following after replacing the email with the exact owner email:

```sql
update public.profiles
set role = 'admin'
where id = (
  select id from auth.users where email = 'OWNER_EMAIL_HERE'
);
```

Do not add an admin-registration option to the public website. Do not expose the database service-role key.

## 3. Approve catalogue data

The five initial service rows are inserted as inactive examples. Review the prices and service scope first. Only after approval, activate selected services from the Supabase dashboard or admin interface.

Example (run only after owner approval):

```sql
update public.services
set is_active = true
where slug in ('web-portfolio', 'web-business', 'poster', 'presentation', 'document');
```

## 4. API keys and environment

The browser may use only the Supabase project URL and publishable/anon key. The service-role key and payment-provider secret must remain in a trusted server environment (for example, Supabase Edge Function secrets). Never commit secrets to GitHub.

## 5. Still required before production

- Implement and test signup, login, logout, and profile update.
- Replace the static frontend catalogue with active rows from `services`.
- Require authentication before creating an order.
- Create orders through the database trigger and read the server-calculated amount back.
- Implement admin-only order management using RLS.
- Select an official QRIS-capable payment provider and implement its server-side API/webhook.
- Verify provider signatures and make webhook handling idempotent.
- Test RLS with separate anonymous, customer, and admin sessions.

## Important

Do not publish this project as a live payment platform until the backend, payment webhook, business policies, and security tests are complete.
