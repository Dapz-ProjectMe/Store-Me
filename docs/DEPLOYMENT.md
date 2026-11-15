# Deployment checklist

This package is a static frontend prototype. It can be previewed locally or deployed as a static site after the owner fills in the correct business contact details and approves the draft service catalogue.

## Before publishing
1. Update `BUSINESS_WHATSAPP` in `js/checkout.js` with the business contact number in international format.
2. Review every service name, scope, starting price, and estimated completion time in `js/services.js`.
3. Confirm business ownership and account eligibility with a parent/guardian where required.
4. Do not enable QRIS until an official provider integration is available and tested.
5. Do not collect sensitive customer information that is not needed to deliver the service.

## Production requirements still outstanding
- Backend order creation and trusted price calculation.
- Database access rules and admin authentication.
- Official dynamic QRIS integration, signed notification verification, and idempotent webhook handling.
- Privacy notice, service terms, cancellation/refund policy, and support details.
- End-to-end browser testing on real devices.
