# DAPZ DIGITAL — Specification v1.0

## Product goal
A small digital-services platform where visitors can browse services, review starting prices, submit an order request, and choose an approved payment route.

## Initial pages
- Home and service catalogue
- Service detail dialog
- Checkout request
- Future: About, Contact, Admin dashboard, Payment status

## Initial services
The five service entries in `js/services.js` are draft examples. Owner approval is required before publication.

## Payment rules
- Cash: prepare a WhatsApp message with selected service and customer details.
- QRIS: disabled until an official dynamic QRIS/API integration is approved and configured.
- The browser must never determine final paid status.
- The server must calculate the payable amount from trusted service records.

## Non-functional requirements
- Responsive layout
- Accessible labels and keyboard-operable controls
- Clear loading, success, and error states
- Separate HTML, CSS, and JavaScript
- No payment secrets in client-side files
