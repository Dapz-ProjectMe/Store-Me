# DAPZ DIGITAL v2.0 — Implementation Checklist

## Backend foundation (v2.0.1)
- [x] Define customer, service, order, and payment tables.
- [x] Add customer profile creation on Supabase Auth signup.
- [x] Add database-side order price snapshots.
- [x] Add Row Level Security policies.
- [x] Keep draft example services inactive pending owner approval.

## Supabase project setup
- [ ] Create the Supabase project.
- [ ] Apply `supabase/migrations/001_initial_schema.sql`.
- [ ] Create the owner's Auth account and assign the admin role manually.
- [ ] Confirm and approve the service catalogue and prices.
- [ ] Test anonymous, customer, and admin access separately.

## Application integration
- [ ] Add a small Supabase client module using only the project URL and publishable key.
- [ ] Build signup, login, logout, and profile screens/flows.
- [ ] Load active services from the database without changing the approved visual baseline.
- [ ] Require login before order submission.
- [ ] Submit orders and display the database-calculated order amount.
- [ ] Build admin-only service and order management.

## Payments and launch readiness
- [ ] Select an official QRIS-capable payment provider.
- [ ] Implement payment creation in a trusted backend/Edge Function.
- [ ] Verify webhook signatures and make event processing idempotent.
- [ ] Add privacy, terms, cancellation/refund, and support information.
- [ ] Complete mobile, accessibility, performance, and security testing.

Do not mark the platform production-ready while any launch-readiness item remains incomplete.
