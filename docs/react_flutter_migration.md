# React to Flutter migration blueprint

Reference: `C:/Users/sushilmaurya/Documents/shipkia-lib`. Mobile: current Flutter repository.

## Scope and evidence

The existing Flutter app contains a design system, Dio API client, secure token storage, auth controller, go_router shell, and dynamic form engine. Reuse these. Several feature screens still use sample fallbacks, inactive actions, or simulated success. A route appearing in the catalog does not establish parity.

Discovery has traced the application router, object framework, authentication, module role rules, and Orders browsing contracts. This is a working blueprint, not a claim that every React page has been audited. Each subsequent module requires its own source trace before implementation.

## Architecture and DRY rules

Keep `lib/src/core` for networking, auth, routing, feedback, forms, and shared async state. Keep `design_system` for platform-aware controls and states. Features own their domain models, repositories, controllers, and page compositions. No auth headers or response unwrapping in widgets. No additional global state library is needed for the first page: use a feature-owned ChangeNotifier built on the reusable paginated controller.

Lists share cancellation, last-request-wins handling, page retry, duplicate record handling, and refresh semantics. Feature repositories own endpoint and filter contracts. Use lazy builders, visible retry and empty states, accessible touch targets, and existing theme tokens. Keep preview fixtures out of production feature loading.

## Implementation order and inventory

| Step | React features | Mobile work |
| --- | --- | --- |
| 1 | Orders list and record details | API-backed browsing, filters, search, pagination, read-only details |
| 2 | Orders forms, products, boxes, pickup addresses, tax rates | Metadata/options loading, dependent fields, creation/editing, totals and validation |
| 3 | Shipping, return orders, pickup/manifest, delivery attempts | Courier quotes/selection, confirmation, grouped pickup, cancellation, NDR processing |
| 4 | Documents and templates | Labels/invoices/manifests, generation progress, native save/share/print |
| 5 | Home and dashboard variants | Real metrics, loading/error states, role-appropriate navigation |
| 6 | Wallet, transactions, invoice, COD/remittance, bank accounts, customers | Ledger lists, recharge verification, beneficiary and settlement workflows |
| 7 | Support and tracking | Ticket creation/chat/attachments, authenticated and public tracking |
| 8 | Channels and onboarding | Store connection/OAuth, sync/logs, company setup and terms acceptance |
| 9 | Settings, users, automation, tools, help | Permission editing, preferences, serviceability/rates, bulk uploads, operational settings |

These groups derive from `src/App.tsx`, `src/lib/appRoutes.ts`, `src/modules`, and the custom views. They are not an exhaustive per-action parity matrix. Admin/customer variants require independent permission and endpoint review.

## Step 1: Orders browsing

React source: `src/modules/orders/list.tsx`, `constants.ts`, `OrderQuickFilters.tsx`, `orderStatus.ts`, `module.ts`, `src/framework/object/ObjectApi.ts`, `filterPayload.ts`, `src/framework/views/objectList/search.ts`, `src/framework/views/ObjectListView.tsx`, `src/views/shipping/orders/types.ts`.

Flutter target: `features/orders/{domain,data}`, OrdersScreen, OrderDetailScreen; shared `core/state/paginated_controller.dart` and `core/api/record_page.dart`.

Routes: `/orders`, `/orders/:id`; query fields `stage` and `search`. React detail identity prefers `name`, then `id`, then `row_id`.

API: POST `/oms/orders/records/list`, query `page` and `rows` as strings; optional body `{filters: {id, type: nested, connector: and, filterSet: [...]}}`. Response after central envelope unwrapping is `{values: [...], fields: [...], pages: {currentPageNo, totalPages, totalRecords}}`. GET `/oms/orders/records/:id` loads a record. Do not use the legacy `/api/orders` constant for this workflow.

Search: React uses `awb contains value OR delivery_phone contains value`, grouped within the AND filters. It does not send the Orders search as a direct query parameter. Order-ID matching is available as an advanced filter.

Stages: New, Ready to Ship, Ready to Pickup, In-Transit (display In Transit), Delivered, Cancelled, RTO, All. Never re-filter server results using a lossy local status enum. Preserve the raw stage label, including exceptions and unknown statuses.

Filters: `payment_method = cod/prepaid`; today and last seven calendar days (today minus six days), serializing local midnight to UTC; AWB/courier missing using `is false`; status uses `stage`; ecommerce platform is `ecom_platform`; destination uses `delivery_city` and `delivery_postal_code` with contains. Multiple values in a category use `in`, not incompatible AND equalities.

Permissions: React ordermanager and buopsoadmin can read/create/update/import/export/ship/schedule/download/cancel/raise-ticket, but not delete. Buopso has read-only Orders access. The current Flutter route guard remains in use for reads; full role/action parity must precede mutations.

Data flow: user changes query -> repository builds backend filters -> shared API client authenticates/unwraps -> repository validates values/pages and maps records -> paginated controller accepts only the latest request -> lazy list renders. Detail reads use the same repository, cancellation, and visible error handling.

Mobile adaptation: prominent editable search, horizontally scrolling stage controls, filter sheet, order cards, pull-to-refresh, explicit load-more and retry. Keep loaded records on refresh/load-more failure; clear them when the query changes. No sample data on errors. No successful-operation message without an actual operation.

Known staged differences: linked channel/pickup autocomplete and metadata-provided courier options need the options/metadata step. Ecommerce platform selection also remains for the options step. Existing hardcoded courier choices and inactive Add/Export controls are removed from this browsing increment. Create/edit/import/export, selection/bulk actions, shipping, support creation, downloads and status mutations remain pending and must not be advertised as completed. The old simulated detail actions are replaced by read-only information/copy actions for this increment.

## Verification and migration risks

Validate requests and parsing using captured React contracts; test search grouping, UTC dates, pagination totals, failures, races, refresh, retry, disposal, and route restoration with explicit API fixtures. Run Flutter analyze, relevant tests, then Android build where the installed toolchain permits. Android/iOS device and authenticated backend verification remain separate from local tests.

Refresh relies on cookies in React: retain the centralized mobile renewal/storage strategy and test real server behavior. Backend metadata and permissions may differ by account. Browser OAuth, payment checkout, cross-tab coordination, web workers, printing, attachments, and template editing need explicit native designs. Do not infer that mock handlers are production contracts. The React manifest includes commented-out boot machinery; do not reproduce inactive architecture.

## Parity status

| Capability | Status |
| --- | --- |
| Orders API list/search/basic filters/pagination/refresh | Implemented; local tests pass |
| Orders API detail read/error states | Implemented; local tests pass |
| Shared pagination lifecycle | Implemented; local tests pass |
| Read-only record field metadata, units, sections and nested records | Implemented for asset browsing; edit/options engine pending |
| Orders create/edit and mutations | Pending |
| Asset lists/details and workspace settings | See asset increment below; full mutation parity pending |
| Authenticated backend smoke test | React workspace reviewed at phone width; Flutter device test pending |
| Android debug APK compilation | Passed |
| Android device verification | Not run |
| iOS device verification | Not run |

## Verification results for step 1

- Flutter analyzer: no issues.
- Full regression suite: 73 application tests passed; one additional temporary UI preview render passed.
- Includes narrow-width/larger-text rendering, filter reset, search debounce, stale responses, disposal, partial-page retry, malformed payloads, backend field mapping, authentication redirect and nested route restoration.
- Local preview uses test data and a substitute system font; it is not an authenticated device screenshot.
- Android debug APK build: passed. Artifact: `build/app/outputs/flutter-apk/app-debug.apk`.
- Live backend and iOS device testing: not run.

## Asset and settings increment (8 September 2026)

Reviewed the authenticated local web workspace at 390 x 844 and traced the React object framework, module definitions, company page, user details, print templates, and customer settings service. No live business records or settings were changed. Credentials are intentionally excluded from this document.

### Native browsing coverage

The shared `ModuleRepository`, `ModuleRecord`, `RecordField`, and paginated controller now drive every catalog record list and its actual detail route. Lists support debounced server search, refresh, paging, retry, counts and readable cards. Details support metadata labels and sections, selectable values, primary badges, linked catalog records, nested maps/grids and expandable template source. Private token/password fields are excluded from fallback rendering. API errors never become successful empty lists.

| Workspace | Pages available on mobile | Live review observations |
| --- | --- | --- |
| Company & payouts | Company profile, pickup addresses, tax rates, bank accounts; administrative variants retain existing catalog routes | Company opens the authenticated customer ID directly; pickup/tax records inspected; bank list was empty, so new-bank field metadata was reviewed |
| Catalog & packaging | Products, boxes, product-box combinations, product-box proposals, default dimensions | Product and box details inspected; combinations empty; proposal list returned HTTP 500 |
| Shipping & automation | Print template list/details, shipment automation settings, NDR settings | Templates use print_template API type; automation settings can be read; NDR settings can be changed |
| Notifications & verification | WhatsApp order events and order confirmation | API-backed forms, save state and visible failures |
| Workspace | Users and profile details, order status logs, appearance | User details use auth service; logs empty; native light/dark/system theme available |
| Operations and finance | Returns, pickup/manifests, NDR records, disputes, channels, support records, invoices, wallet/transaction records, remittances, customers and rate-configuration records | Shared list/detail implementation; individual operational actions and role variants still require end-to-end validation |

### Confirmed contracts

- Lists: POST `/oms/{object}/records/list`, query `page`/`rows`, result `values`, `fields`, `pages`. The user service uses POST `/auth/users`; its pagination may contain `totalNoOfPages`.
- Details: GET `/oms/{object}/records/{id}` returns `{value, fields}`. Users use GET `/auth/users/{id}`. Template values can omit an ID, so the requested ID remains the route identity. IDs are encoded once.
- Templates: the visible `/settings/template` route maps to `print_template`, not `template`.
- Company: GET `/oms/company_info/records/{profile.customerId}`; no invented company list request.
- Search: module-configured fields use a nested OR inside the AND filter; modules without configured fields use the server search query parameter. Search results are never filtered a second time locally.
- Unit metadata: currency is stored in paise, weight in grams, dimensions in millimetres; native displays use INR, kg and cm. Orders now also unwrap detail records and use currency metadata to avoid displaying paise as rupees. Metadata-free legacy values are preserved.
- Customer settings: GET/PUT `/oms/customer-settings?type={type}`; writes use `{[type]: payload}`. Types are `whatsapp`, `ndr_flow`, `order_confirmation`, `default_dimension`, `automated_shipment`.
- Default dimensions convert cm/kg back to mm/g and calculate volumetric weight in grams using stored length * breadth * height / 5000. Confirmation automation is disabled on save when confirmation is off or both payment categories are disabled. Language is only sent for advanced flows.

### Remaining parity work

Asset create/edit forms, bank/pickup primary mutations, user invitation/password/API-key actions, template editing/printing, courier priority editing, custom dashboard/tools workflows, role-specific navigation and operational mutations are not complete. Shipment automation is currently view-only. Appearance changes the native theme for the current app session; web accent/density preferences are not synchronized. No live settings PUT was performed during verification. Android and iOS authenticated device testing remain necessary; an iOS binary cannot be built with the Windows toolchain.

Temporary mobile preview images and their gallery were removed after visual verification, as requested. The recorded verification results below remain for migration tracking.

### Verification for the asset increment

- Static analysis: no issues.
- Full suite: 80 application tests passed plus one preview-render test; an additional direct asset-link integration test passed afterward (81 application tests in total).
- Covered response wrappers, metadata units, search payloads, alternate pagination, retry states, mobile list-to-detail navigation, notification save payloads and the actual app router's direct product link.
- Six Flutter mobile preview images generated; settings, product details, pickup details and notification layouts visually inspected.
- Android debug APK rebuilt successfully at `build/app/outputs/flutter-apk/app-debug.apk` (257,149,738 bytes). Gradle emitted Java native-access warnings; its build completed.
- The development API defaults to `http://api.shipkia.lcl`. A physical phone or emulator must resolve and reach that host. The existing `API_BASE_URL` build override can target a device-reachable backend.
- Live account verification was read-only through the React web app. Settings writes were verified with test API fixtures, not changes to the live account. iOS/device verification remains pending.

## API-driven form builder increment

Asset forms now load GET `/oms/{object}/records/fields` (users use `/auth/users/fields`) and pass the response through `ApiFormAdapter` into the existing `DynamicFormBuilder` and `createShipKiaFieldRegistry`. Edit/view forms load the record separately and retain the same API field names. Field definitions are not copied into individual asset pages.

Source contracts: React `FormBuilder/fieldRegistry.ts`, `FormBuilder/types.ts`, `views/form/baseForm/detailApiAdapter.ts`, `lib/api/objectOptions.ts`, `lib/api/postalCode.ts`, and the bank/pickup form configurations.

| API metadata | Native behavior |
| --- | --- |
| text, email, password, phone, uid | Registered inputs; identity/account strings retain leading zeroes |
| int/number, float | Numeric fields, finite/range validation and numeric payloads |
| option/select/autocomplete, radio, multiSelect | Server-provided options and typed option IDs; comma/newline option formats supported |
| bool/boolean/checkbox, switch | Boolean controls and boolean payloads |
| date, time, datetime | Native date/time selection and API date/time serialization |
| unit | Display units and API storage conversion through the shared unit rules |
| link | Debounced, paginated GET `/oms/{object_type}/options` selection; roles use `/auth/users/roles` |
| postal_code | Debounced lookup using `/oms/postal-code`; metadata maps city/state/country, stale lookups are cancelled/ignored, pending/error lookups block saving |
| grid/editableGrid | Metadata-driven row form, required child validation, row count bounds and add/edit/remove controls |
| section | Ordered sections; repeated section names do not collide with field IDs |
| json | JSON editing with validation and structured serialization |
| unknown/specialized fields | Visible unsupported state; editable fields prevent submission instead of dropping data |

The adapter preserves `name`, label, required/readonly/disabled/hidden flags, `form_view`, defaults (`defaultValue` and backend aliases), options, numeric/text limits, nested field definitions, and descriptions. Duplicate field names and malformed field responses fail visibly. Form visibility and generated read-only IDs are respected during validation and serialization.

Open a record and choose **Edit details** or **View form fields**. Authorized ordermanager/buopsoadmin accounts can create products, banks, taxes, boxes and pickup addresses, and edit products, banks, taxes and company information. Other roles can inspect the API form without save controls. This allowlist follows the audited React module permissions; generic save calls are not enabled for custom template/user workflows. Creates POST to the records base; edits PATCH the encoded record ID. Both refresh the caller only after API success.

Bank Other-name visibility/clearing and pickup RTO visibility/clearing are applied, along with pickup operating-time validation. Pickup operational-day rows use native row editing rather than the web's default week checklist; payload rows still contain the API-defined day field. Arbitrary React reactive logic, attachments/image uploads, API-key actions, conditional field-group widgets, and Orders-specific forms remain pending. Those specialized widgets are not presented as fully migrated.

Settings screens whose React definitions are custom (rather than API object fields) remain separate. No live account records were created or edited during testing; form saves are exercised with explicit test API fixtures.

Form increment validation: all 91 application tests passed; Flutter static analysis found no issues. Tests cover registry aliases, response envelopes, repeated sections, defaults, multi-select IDs, hidden/read-only fields, unit round trips, invalid numbers, nested grid validation, unsupported fields, conditional fields, dates/JSON, API-backed create, read-only roles and stale postal lookups. Android debug APK rebuild passed after the form integration; authenticated live mutations and iOS device testing were not performed.

## Follow-up page-by-page review

See [web parity review](web_parity_review.md) for the fresh authenticated route/form/detail review and source trace. This pass removes sample Home metrics, adds source-defined Returns/NDR/Pickup tabs, and adds shared bank/pickup form overrides, hidden-field layout handling and inline unit labels. The report supersedes earlier assumptions of generic screen parity and identifies the remaining custom workflows.

### Compact controls and existing-order forms

Shared chips, status badges and action buttons now fit their content and center labels; the order-stage strip sizes naturally. Existing order details use the API field registry and single-column form builder with live update permissions, New-stage editing, product row lookup/edit/duplicate/remove, conditional billing/payment fields and an order summary. Updates use the records PATCH contract and preserve input on errors. See the follow-up section in [the parity review](web_parity_review.md) for remaining custom workflows.
