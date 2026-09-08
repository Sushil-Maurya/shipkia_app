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

## Compact order header and actions

Replaced the nested order AppBar with a content-sized toolbar and removed the already-consumed top inset below the app shell. Copy sits immediately beside the order ID; stage/status and ecommerce order references wrap when needed, with actions at the right edge. The shipment header retains the same ecommerce reference. Material icon buttons now honor their requested size without default extra padding.

The mobile bottom sheet has no desktop shortcut hints. Update, Refresh, Support Tickets navigation and stage-eligible cancellation with confirmation are connected. Download Invoice, New and Duplicate are explicitly disabled with a mobile-availability label until their native workflows are implemented. Cancellation uses the web DELETE `/oms/shipping/order` contract with `order_id`; no live order was cancelled during development.

Header/action verification: 108 tests passed, Flutter analysis is clean, and the Android debug APK rebuilt successfully. Temporary check logs were cleaned. The top-inset and header sizing checks run in widget tests; no physical-device or iOS build verification was performed.


## Order actions, autocomplete and compact listings (September 8)

This follow-up supersedes the earlier notes about disabled invoice, New and Duplicate actions and tags in the detail toolbar. The toolbar now contains back, order ID with a 20-pixel copy button (13-pixel icon), and the actions menu. Status/stage and ecommerce references are omitted from the toolbar; the shipment header retains its ecommerce reference. Order card stage badges align to the right content edge. Shared icon actions default to 30 pixels, including listing refresh/filter/clear controls. Create Order appears below the orders heading, opens the registered API form, enforces create permission in that form, and refreshes the queue after successful creation. Authentication buttons retain full width.

Revisited the React sources and the local web order detail at a 390 x 844 mobile viewport. Pickup address fields now search the API options endpoint with debounce, pagination, loading/retry and explicit selection; arbitrary text cannot be saved as an address ID, and API readonly metadata disables editing.

The order action sheet connects creation and duplication to POST `/oms/orders/records`, excluding source identity and shipping metadata when duplicating. Invoice/label downloads request the web document endpoints and validate PDF bytes before opening Android's save picker or the iOS share sheet. Ship Now loads live courier quotes and creates the shipment, followed by pickup scheduling where required. Scheduling follows the pickup address's operating days and same-day closing time. Support Tickets lists tickets filtered to this order and provides a registered form for raising a ticket. Refresh, Update and stage-eligible cancellation remain connected. Desktop keyboard shortcuts are omitted.

Validation: 115 tests passed and Flutter analysis reported no issues. Tests cover listing control sizes, right-aligned badges, narrow layouts with enlarged text, create-and-refresh navigation, document payloads, shipment/scheduling contracts, duplication exclusions, pickup selection validation and existing readonly behavior. No live business records were created, shipped, cancelled or modified during verification. iOS compilation and physical-device PDF picker behavior have not been verified on this Windows machine. Support-ticket attachment upload and remaining earlier parity gaps (such as automatic dimensions and country-code selectors) are still outstanding; this does not establish whole-app parity.

Android debug APK rebuilt successfully after this follow-up. Temporary verification logs were removed; production assets, regression tests and the APK were retained.


## Listing alignment and form interaction follow-up

Create Order now sits immediately to the right of Reload in a right-aligned action row. The search field and filter button are both 36 pixels high and vertically centered. The action row remains separate from the title for narrow screens and enlarged text.

Registered phone fields show India's flag and +91 prefix, matching the React PhoneInput default. The prefix is separate from the editable number; existing +91-prefixed values display without duplicating the code. Shared Material/Cupertino text inputs explicitly dismiss focus on outside taps. Pickup autocomplete groups its input and suggestions so selection still works; outside taps close the dropdown and keyboard, the dropdown has no Close button, and the input's cross clears its value and cancels pending searches. Readonly behavior remains enforced. New orders and empty order identities do not show copy controls.

Verification: Flutter analysis reported no issues. The regression run passed 115 tests; its single failing phone accessibility assertion was corrected for Flutter's merged semantics, and all seven order-action tests then passed, including phone keyboard dismissal, autocomplete clearing/outside dismissal and the new-order copy guard. Listing tests verify action ordering and matching search/filter geometry, including narrow layouts. Android debug APK rebuilt successfully. Task logs were removed after verification. Physical-device and iOS build verification remain outstanding.


## Reusable dropdowns and product editor follow-up

Select fields and linked-record fields now share `ApiOptionsField`. Suggestions use the input's available width, local registered options when present, or paginated API options for the registered object type. The component supports typed search, clearing, disabled options, readonly fields, retry, additional pages and outside-tap dismissal. The old separate linked-record picker was removed.

Product name now uses this autocomplete directly inside the row editor. Selecting an option fills the registered display mapping from option data when provided, otherwise from the linked record endpoint, preserving field-specific storage/display unit conversion. Free-text product names remain supported as in the previous renderer. Product row editing has a top-right Close icon and right-aligned Done button; the bottom Close text action was removed. Unit suffixes size to their content at the right edge and center vertically in the field.

Regression coverage includes local options without API calls, dropdown/input width agreement, unit suffix position, typed product search and mapped price/tax values, and the product editor's close/Done placement and saved row. Physical-device and iOS build checks remain outstanding.

Final verification: all 118 tests passed, Flutter analysis found no issues, and the Android debug APK rebuilt successfully. Temporary task logs were removed.

Orders heading placement correction: Reload and Create Order now share the Orders heading row, in the right-hand area, with Create Order after Reload. The subtitle remains below the heading. Narrow-screen and enlarged-text layout checks cover this placement.
Verification: all 7 Orders tests passed, analysis reported no issues, and the Android debug APK rebuilt successfully. Temporary logs were cleaned.


## Product row field registration and tax option validation

Product grid children retain the API's registered fields without the order header's empty-readonly-field suppression. HSN Code and Tax Rate therefore remain visible in a new product drawer, retaining readonly access until autocomplete fills them. Explicit API visibility settings remain respected.

Single-select and radio options no longer interpret API min/max metadata as character limits. TAX Preference's max: 1 no longer rejects Inclusive or Exclusive; required and allowed-option validation still applies. Shared suggestions have an 8-pixel rounded, clipped border and alternate surface colors per row, with Material tap feedback preserved.

Verification: all 119 regression tests passed, including a fixture-based test checking all seven product fields, readonly field visibility and valid/invalid tax selections. Flutter analysis reported no issues. Physical-device and iOS checks remain outstanding.
Android debug APK rebuilt successfully. Temporary verification logs were removed after completion.
