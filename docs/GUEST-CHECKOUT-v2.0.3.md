# DAPZ DIGITAL v2.0.3 — Guest Checkout & Order Tracking

## Product decision
Customers do not create accounts. They submit an order request with their name, WhatsApp number, and service details. PostgreSQL generates a random order code that is shown on the digital receipt.

## Database
Apply migrations in order:
1. `001_initial_schema.sql`
2. `002_guest_checkout.sql`

The existing authenticated `orders` table is retained for compatibility. The guest checkout flow uses `guest_orders`.

## Edge Functions
Deploy:
- `create-guest-order`
- `track-guest-order`

Both functions use the server-side `SUPABASE_SERVICE_ROLE_KEY`. Never put this key in frontend JavaScript or commit it to GitHub. Supabase provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to deployed Edge Functions.

The create function accepts a service slug and customer contact details. The database trigger looks up the active service and snapshots its current price; browser-supplied prices are never trusted.

The tracking function accepts an exact order code and returns only the service, total, payment method/status, order status, and timestamps. It does not return the customer's name, WhatsApp number, or notes.

## Current payment limitation
Only cash / WhatsApp confirmation is enabled. QRIS must remain disabled until the official DANA Bisnis QRIS integration and server-side payment verification webhook are configured. A browser redirect or screenshot is not proof of payment.

## Admin access
Authenticated admins can read and update guest order progress through the `is_admin()` RLS policy. Customer accounts are not needed. Do not expose guest-order table access to anonymous users.

## Before launch
- Apply both SQL migrations.
- Deploy both Edge Functions.
- Configure the frontend with the Supabase project URL and publishable key (never the service-role key).
- Approve service prices and activate only the services that are ready.
- Add rate limiting / abuse protection for public Edge Function endpoints.
- Test guest order creation, invalid inputs, tracking by exact ID, and admin-only access.
- Complete DANA QRIS integration and signed webhook verification before enabling QRIS.
