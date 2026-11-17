# DAPZ DIGITAL — v2.0 Frontend Upgrade

DAPZ DIGITAL v2.0 is an upgrade of the v1.1 frontend prototype. The original purple, violet, and lavender identity is preserved.

## v2.0 updates
- Premium Modern homepage with a more distinctive hero section and clearer brand introduction.
- Refined button system with consistent hover and focus states.
- Original DAPZ palette retained from v1.1 CSS variables and design tokens.
- Custom Dynamic Premium loading animation using the DAPZ monogram and matching brand colors.
- Loading animation includes a reduced-motion fallback and a timeout safety net.
- Existing pages, service catalogue, dialogs, and WhatsApp order-request flow are retained.

## Pages
- `index.html` — Premium Modern homepage
- `services.html` — service catalogue
- `process.html` — ordering process
- `about.html` — brand information
- `contact.html` — contact guidance
- `checkout.html` — order request form

## Important production limitations
This remains a frontend prototype. Supabase, admin dashboard, dynamic QRIS, server-side pricing, and payment verification are not yet implemented. Service prices are examples and must be approved. The WhatsApp number is still a placeholder.

Before production, add a trusted backend, server-side validation, secure admin authorization, official payment-provider integration, privacy policy, terms, and refund/cancellation rules. Never expose private API keys in browser code.

## Preview
Open `index.html` through a local static server.
