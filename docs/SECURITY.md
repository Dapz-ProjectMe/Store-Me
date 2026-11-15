# Security notes

This repository currently contains a frontend prototype only.

Before production:
- Move service price authority to a trusted backend/database.
- Enable Supabase Row Level Security on all exposed tables.
- Restrict admin operations to authenticated authorized roles.
- Validate and normalize customer inputs on the server.
- Add rate limiting and abuse protection to order endpoints.
- Verify payment notifications using the provider's documented signature/authentication method.
- Make webhook processing idempotent.
- Never expose provider private keys or service-role keys in browser JavaScript.
- Do not trust client-side order totals or payment status.
- Publish privacy policy, terms, refund/cancellation rules, and contact details.
