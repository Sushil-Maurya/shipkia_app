# Web-to-mobile parity review

Reviewed 8 September 2026 using the local authenticated web workspace at 390 x 844, alongside `C:/Users/sushilmaurya/Documents/shipkia-lib`. This pass visited 41 route locations, retried slow-loading forms after workspace initialization, and opened eight existing record details. Business records/settings were not changed. Credentials and account record values are excluded from this report.

This is a review of the routed customer workspace and its source entry points, not a claim that every repository file, role, or action was executed. Admin-only screens were inventoried in source and still require a separate authenticated role review. Full mobile parity is **not complete**.

## Page-by-page findings

| Page | Web review / source | Flutter result and remaining differences |
| --- | --- | --- |
| Home | Welcome/profile, onboarding readiness, low-wallet state and workflow shortcuts. `views/home/HomeView.tsx` | Replaced fabricated dashboard metrics/sample orders with welcome and real navigation. Onboarding checkpoints, balance state and Create Order shortcut await their native workflows. |
| Orders list | New, Ready to Ship, Ready to Pickup, In Transit, Delivered, Cancelled, RTO, All; shipping, pickup and document actions. `modules/orders/list.tsx`, `constants.ts`, row/actions components | Existing API search/filter/list/detail browsing retained. Bulk actions, shipping/pickup/documents and full quick-filter parity remain incomplete. |
| Order create/edit | Fully loaded new form and existing record reviewed. Pickup, delivery/billing, product grid, other charges, payment, package and other details. `formConfig.ts`, `totals.ts`, `payload.ts`, `OrderDetailView.tsx`, `detailPageConfig.ts` | Plain metadata fields are insufficient: reactive totals, product/tax lookup, hidden computed fields, billing copy and shipping actions need a dedicated native composition. Existing-order details now use registered form fields with New-stage/runtime-permission editing, PATCH changes, product lookup, billing/payment visibility and totals. Order creation, shipping actions, automatic dimension preview and full aside panels remain pending. |
| Returns list | Inherits Orders tabs excluding Ready to Ship and RTO. Searches ID/reference/AWB/phone/postal code. `modules/return_order/list.ts` | Added the matching tabs and backend filters. Create/cancel/ship actions remain pending. |
| Return create/edit | Fully loaded new form and existing detail reviewed: source-order selector, reason/status, pickup/contact/address, return warehouse, products/charges/package. `ReturnOrderDetailView.tsx` | Source-order fetch/copy, delivery-to-return field mapping and warehouse lookup are custom logic; not reproduced by the generic detail view. |
| Pickup & Manifest | Scheduled, Completed, Partially Completed, Cancelled; manifest download and tickets. `modules/pickup_and_manifest/module.ts` | Added status tabs using `status = value`, distinct from order `stage` filters. Manifest generation/download and support actions pending. |
| NDR | All, Pending, Unsuccessful, Delivered, Delivery Reattempted; empty state observed. Detail is a custom drawer. `modules/delivery_attempt/list.tsx`, `DeliveryAttemptDetailView.tsx`, `views/shipping/DeliveryAttempt` | Added matching tabs using `stage in [value]`, combined with OR search. Communication history, reattempt workflows and report actions pending. |
| Weight Disputes | List endpoint returned HTTP 400 during this review | Mobile reports API failure. Backend issue prevents a successful live-data comparison; dispute workflow parity not established. |
| Wallet & Recharge | Ledger/category filters and Add Balance; list endpoint returned HTTP 400, wallet balance GET succeeded | Generic record browsing is distinct from checkout/recharge. Existing dedicated wallet simulation still needs replacement with the real financial workflow. |
| Support | List API succeeded. `/support_ticket/new` did not resolve to a supported create page. `modules/support_ticket` custom actions/detail/attachment components | List/detail browsing exists; ticket creation, conversation, attachments and status actions remain pending. Do not infer a generic create URL. |
| Remittance hub | COD Remittances and Remittance destinations | Navigation exists; role-specific exposure remains to be aligned. |
| COD Remittances | COD Remitted / Upcoming COD. `modules/customer_cod_remittances/module.ts` | Generic list exists; Upcoming COD uses a distinct request and requires a dedicated implementation. |
| Remittances | List API succeeded. `modules/customer_remittance/module.ts`, `services/remittance.service.ts` | Record browsing exists; settlement/import actions require separate verification. |
| Tools hub | Serviceability and Rate Card | Generic navigation exists; tool workflows are not native-complete. |
| Rate Card | Partner choices; `/oms/shipping/partners` and `/bms/rate_card` succeeded | Native partner/zone comparison UI pending. |
| Serviceability | Pincode check form and Check action | Native validated query/result flow pending; no live check submitted in this review. |
| Channels | Add New Channel and Sync Logs; list API succeeded. `services/channel.service.ts` and channel views | Record browsing exists; OAuth/store credentials, synchronization and logs require custom UI. |
| Settings hub | Company Setup, Catalog & Packaging, Shipping & Automation, Notifications & Verification, Access Control, Logs, Appearance | Native grouped hub exists. Web category subnavigation and role-specific menus still differ. |
| Company Setup | Existing company form reviewed: name/phone/email/website/tax/address/threshold balance; Update | API form available. Country-aware phone controls, exact layout/subnavigation and permission reconciliation remain. |
| Products | List, new form and existing detail reviewed: name, HSN, dimensions, weight, price, tax and tax preference; Create/Update | API fields and create/edit supported. Shared currency/dimension/weight suffixes now match web notation. Unique-name preflight and linked record display text still need parity checks. |
| Pickup Addresses | List, fully loaded new form and existing detail reviewed: address/contact, operational week/time, RTO; primary status | Added metadata-driven week checklist with all API days selected on create, hidden empty postal-derived fields, and required RTO when applicable. Primary action and runtime update permissions require further review. |
| Bank Accounts | List empty; new form reviewed: Account Name, Account Number, Bank, IFSC; Create. `modules/bank-account/formConfig.ts` | Added exact web placeholders. API field definitions and create/edit available. Existing live bank detail and Make Primary not verified because no bank record was available. |
| Tax Rates | List/new/existing reviewed: Type and Rate, Save; custom modal source `modules/tax_rate/form.ts` | API-backed fields/save supported; retains Save label. Native page differs from the web modal presentation. |
| Boxes | List/new/existing reviewed: Active, length/breadth/height, box/max weight; Create/Update visible | Create and read-only details available. A visible Update control alone does not establish permission to mutate; source/runtime permission reconciliation pending. |
| Product Box Combination | Empty list with Create action; permissions endpoint succeeded | Generic browsing only; combination creation and linked packaging rules pending. |
| Product Box Proposal | List endpoint returned HTTP 500 | Mobile displays failure; successful proposal comparison blocked by backend response. |
| Templates | List/existing detail reviewed: template name, document type, page size, Update template. `modules/template/service.ts`, template builder | Generic record/source viewing exists. Real editor, preview/rendering, validation and custom save endpoints pending. |
| Users | List/existing detail reviewed: profile inputs, Profile/API Key tabs, Update, Add User. `modules/users/UserDetailView.tsx`, `CreateUserModal.tsx` | Read-only metadata view exists. Invite, role management, password and API-key workflows pending. Secrets were not revealed. |
| Order Status Logs | All, Pending, Processing, Sent, Failed, Finished; empty list; generated defaults in `framework/object/moduleLoader.ts` | Generic record browsing exists; exact status tabs and search defaults still need mapping. |
| Shipment Automation | None/Cheapest/Fastest/Custom, delay, partner/service priority and Save | Settings read available; courier-priority editing remains pending. |
| NDR Flow | Mode selection and Save, with conditional language | Native settings form exists; radio-card layout differs from the web. |
| Order Notification | New, Shipped, Delivery Delayed, Out For Delivery, Delivered, Cancelled; Save | Native API toggles exist; ordering and table/group layout differ. |
| Order Confirmation | Mode/payment controls and Save | Native API form exists; visual option cards and all dependent-state transitions require further parity verification. |
| Default Dimension | Package dimension/weight settings and Save | API read/write and unit conversion exist; custom calculated-field presentation is not identical. |
| Appearance | Theme builder/presets and Default/Compact form factor | Native light/dark/system only; accent presets, density and persistence are not synchronized. |

## Confirmed form structures

Orders: pickup/status; delivery phone/alternate phone/name/address/postal/landmark and billing-same control; product rows (product name, HSN, unit price, quantity, discount, tax rate and tax preference); optional shipping/transaction/gift-wrap/discount charges; payment; dimensions/dead weight; channel, tag and notes. Computed monetary/volumetric fields are hidden/replaced by the web insight composition.

Returns: source order; reason/status/contact; return address; warehouse; product rows; optional charges/discount; package dimensions/dead weight. `returnOrderFieldMap` maps delivery fields to return fields, and source-order copying also loads pickup/warehouse information.

Pickup: address type/postal/landmark/address; contact name/phone/email/role; the API-provided Sunday-through-Saturday options with an Open checkbox; opening/closing time; RTO-same switch and required RTO address otherwise. The week options are read from metadata, not hardcoded in Flutter.

Shared changes applied in this pass: bank placeholders, pickup module normalization, visible-field layout without blank hidden-field slots, inline currency/CM/KG adornments, Create/Update labels (Tax retains Save), and datetime display in the device timezone while serializing UTC.

## Repository trace

| Folder | Role in the review |
| --- | --- |
| `src/App.tsx`, `src/lib/appRoutes.ts`, `src/config` | Route inventory, custom routes and workspace destinations |
| `src/framework/object` | Module loading, fallback module definitions, list tabs, permissions and records/fields endpoints |
| `src/framework/views`, `src/views/form`, `src/framework/reactive` | List/detail composition, metadata adaptation, field visibility and reactive behavior |
| `src/modules` | Inventoried module folders/files; inspected the listed operational/asset configs and their custom detail entry points |
| `src/components/ui/forms/FormBuilder` | Type registry, unit conversion, field rendering and grid behavior |
| `src/components/ui/inputs`, `src/hooks/useFormBuilder.ts` | Linked options, postal lookup, phone/date controls and form state contracts |
| `src/views/home`, `shipping`, `finance`, `remittance`, `wallet`, `support`, `settings`, `tracking` | Routed custom page families and corresponding module imports |
| `src/services`, `src/lib/api` | Shipping, wallet, remittance, channel, settings, document, upload and object-option service boundaries |
| `src/features`, `src/Redux`, `src/hoc` | Auth/onboarding/profile and role context referenced by page composition |
| `src/assets`, `src/styles`, `src/icons`, `src/template-builder`, `src/mocks`, `src/test` | Inventoried supporting assets, template tooling and test fixtures; mocks are not treated as production API contracts |

Admin variants (`order_details`, return/pickup detail variants, customers, invoices, company transactions, administrative remittances, wallet/recharge and rate configuration) have source entries beyond the customer menu. Their role-specific pages/actions are not declared live-verified by this account review.

## Follow-up order

1. Complete Order creation, shipping/actions and dimension preview, then Returns source-order/copy logic.
2. Shipping, pickup/manifests and NDR actions with their custom detail UI.
3. Role-aware navigation and runtime permissions; reconcile source permissions with server-provided overrides before enabling more writes.
4. Wallet/checkout, support conversations, channel connection and remittance workflows.
5. Template editor/preview, uploads, user/API-key actions and remaining custom settings visuals.

The source review and current fixes do not justify claiming that all Flutter forms now look or behave identically to the web app. Native controls adapt to phone width; missing workflow behavior is explicitly tracked above.

## Verification

- Full Flutter regression suite: 96 tests passed.
- After the final inline-unit presentation adjustment: all 15 focused API-form/parity tests passed.
- Flutter analysis: no issues found.
- Android debug APK rebuilt successfully at `build/app/outputs/flutter-apk/app-debug.apk`.
- Temporary review/check logs removed; maintained documentation and regression tests retained.

The web review used a mobile browser viewport. This pass did not validate the rebuilt APK on a physical device, build iOS, or submit live business forms.

## Compact controls and order detail follow-up

Reopened an existing order in Chrome at 390 x 844. Visible web toolbar buttons measured 24 px high and form controls 28 px high. The native shared chip/button controls now size from their content, center labels, and grow for enlarged text. Removed the fixed-height order tab strip and migrated module tabs to AppChip; status badges no longer stretch across their parent. Auth/account/NDR primary actions use content width.

Order details now render API-registered fields instead of summary cards. The record response retains storage units until the form adapter converts them, preventing double currency conversion. Edit access requires the live `/oms/orders/permissions` update flag and stage New. Later stages remain the same form in read-only mode. Updates PATCH changed editable values, include billing values when billing-same is disabled, and retain entered values on failure. Product lookup fills metadata-mapped price/tax fields; row editing, duplication and removal use the shared grid renderer. The summary follows exclusive/inclusive tax, discounts, charges and COD/prepaid validation. Empty hidden sections are suppressed.

Remaining differences: new-order creation, Ship Now/courier selection, shipping documents, Charges/activity panels, automatic dimension preview and country-code phone selectors are not completed by this follow-up. Product rows use a native row editor instead of the web's horizontally scrolling inline grid. This pass does not establish whole-app workflow parity.

Follow-up verification: 104 regression tests passed, Flutter analysis reported no issues, and the Android debug APK rebuilt successfully. Tests cover content-sized controls at enlarged text, iOS button sizing, API product-field mapping and unit round-trips, billing payloads, totals validation, saved/failed updates, read-only stages and existing routing. No live business form was submitted; the APK was not exercised on a physical device and iOS was not built. Temporary screenshot and check logs were removed after verification.

## Order detail reference layout and readonly follow-up

The supplied mobile image and API field response now drive the detail presentation: shipment identity/AWB, pickup/destination and stage progress header; individually framed form sections; and a floating Form / Order summary / Activity navigator. Switching panels preserves the unsaved form. Activity uses the web GET `/oms/orders/records/activity` contract with record ID and pagination, including empty/error/retry states. Runtime order access still applies; each field's `readonly: true` independently disables editing, including nested product fields, and read-only top-level fields are excluded from updates. Tests use only the attachment's field metadata with synthetic record values.

Login, logout and shared authentication actions have their previous full width and 40-pixel minimum height restored. Other app controls retain content sizing.

Verification for this layout follow-up: all 106 tests passed, Flutter analysis found no issues, and the Android debug APK built successfully. Temporary check logs were removed. Device-level visual verification and an iOS build were not performed.
