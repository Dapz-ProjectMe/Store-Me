# Changelog — v2.0.1 Backend Foundation

- Added initial Supabase PostgreSQL migration.
- Added customer profiles with a safe default `customer` role.
- Added a trusted service catalogue; example prices are inactive by default.
- Added customer orders with database-side price snapshots and server-generated order codes.
- Added a payments table reserved for trusted backend/provider writes.
- Enabled Row Level Security policies for profiles, services, orders, and payments.
- Added Supabase setup and database design documentation.
- No existing HTML, CSS, JavaScript, brand colors, homepage, or loading animation files were changed in this backend-foundation step.

This is a database foundation, not a completed live backend or payment integration. Apply and test the migration in a new Supabase project before production use.
