# DAPZ DIGITAL — Frontend Prototype v1.0

Original service-business website direction informed by the user's DigitalHub and DAPZ TOOLS references. The design is not a copy of either reference.

## Included
- Responsive landing page with original DAPZ DIGITAL identity.
- Service cards populated from `js/services.js`.
- Service detail dialog.
- Checkout form with selected-service summary and price.
- Cash / WhatsApp order message flow.
- Draft specifications, security notes, QA checklist, and deployment checklist.

## Important limitations
This is a frontend prototype, not a production-ready payment system. QRIS is deliberately disabled. The current catalogue and prices are examples and must be approved before publication. The WhatsApp number is a placeholder.

Before accepting real orders, implement a trusted backend, server-side price calculation, secure admin access, privacy/terms pages, and official payment-provider integration. Never place private API keys in frontend JavaScript or trust a screenshot as proof of payment.

## Preview
Open `index.html` through a local static server. The checkout page is `checkout.html`.

## Main files
- `index.html` — landing page
- `checkout.html` — order request form
- `css/` — styles
- `js/services.js` — service catalogue and example prices
- `js/main.js` — landing-page interactions
- `js/checkout.js` — WhatsApp checkout flow
- `docs/` — specification, security, QA, deployment notes


## Perbaikan v1.1
- Navigasi utama sekarang membuka halaman khusus: Home, Services, How it works, About, Contact.
- Menu mobile tetap dapat dibuka/tutup dan berpindah halaman.
- Menambahkan pengaman overflow horizontal untuk menghilangkan area kosong putih di sisi kanan pada mobile.
- Menambahkan halaman Services terpisah dengan detail layanan dan checkout.
