# DAPZ DIGITAL v2.0 — Database Design

## Tables

| Table | Purpose | Access |
|---|---|---|
| `profiles` | Customer identity and role | Customer: own row; admin: all |
| `services` | Published service catalogue and trusted prices | Public: active rows; admin: all |
| `orders` | Customer order requests and price snapshots | Customer: own rows; admin: all |
| `payments` | Payment-provider references and verified events | Trusted backend writes; admin reads |

## Important rules

1. A new Supabase Auth account automatically receives a `profiles` row with role `customer`.
2. Customers cannot grant themselves the `admin` role. Admin promotion is a manual trusted SQL operation.
3. Public visitors can read only services where `is_active = true`.
4. Draft service records are seeded with `is_active = false`. The listed prices are examples from the frontend and must be approved before activation.
5. A customer must be authenticated to create an order.
6. The `prepare_customer_order` database trigger takes the current service name and price from `services`. It ignores browser-supplied totals, owner ID, order code, order status, and payment status.
7. Customers cannot update their order or write payment records directly.
8. Payment confirmation must come from a trusted server/webhook after validating the payment provider's signature. Never accept a browser redirect as proof of payment.

## Order lifecycle

- Order: `pending` → `confirmed` → `in_progress` → `completed`
- Cancellation: an admin may set `cancelled` according to the published cancellation policy.
- Payment: `unpaid` → `waiting` → `paid`; exceptional states include `failed` and `refunded`.

The application should enforce valid transitions in trusted backend code, not by trusting client input.

## Before launch

- Approve service names, descriptions, prices, and durations.
- Confirm the business WhatsApp number.
- Decide whether cash orders require manual confirmation and define the QRIS provider.
- Add privacy policy, terms, refund/cancellation policy, and customer support details.
- Test RLS with anonymous, customer, and admin accounts in a non-production project.
