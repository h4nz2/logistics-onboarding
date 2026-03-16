# Requirements

Design backend API for a React frontend, that will allows the user to complete onboarding for his company.

Onboarding steps must satisfy the following:

- we can track which steps have been completed for a company
- we can track which steps have been skipped for a company
- order of steps is defined somewhere
- some steps can only be completed after a condition has been met (e.g. previous step completed or file processing of previous step completed)

## Onboarding steps

### 1. Welcome

Only contains welcome text with basic information.

### 2. Set your lead time

User sets the lead time in days. This step must be completed.

### 3. Set days of stock for products

User to sets the days of stock. This step must be completed.

### 4. Set forecasting days

Users sets wow far back (in days) should we look when calculating daily average sales of a product. This step must be completed.

### 5. Upload existing Purchas orders

User can upload excel or csv file with purchase orders. This step is optional. This step is unlocked only after Vendors have been added into the app.

### 6. Match suppliers and products

User can choose, which vendors can be used as suppliers. This step is optional.

### 7. Set bundles

User can upload an excel or csv file, which will be used to import bundles. This step is optional.

### 8. Set integrations

User can add and configure integrations. User selects from a predefined list. Additionaly, use can request a new integration.

# Models

## Company

The core model representing the ecommerce platform. Stores company-level configuration such as lead time, stock days, and forecasting days. The available onboarding steps are defined as constants on this model, while their completion status is tracked via the `OnboardingStep` model.

## OnboardingStep

Tracks the status of each onboarding step for a company. Uses integer enums for both the step identifier and its status (pending, completed, or skipped).

## Integration

Represents third-party integrations of the company. The one-to-many relationship assumes that each company cannot integrate more than once with the same provider. The configuration is JSON to allow us to store any format needed, as different integrations might need to store different kinds of data. As I don't presume there would be any filtering or sorting based on this attribute, it should be fine to simply store it as a JSON attribute.

## Warehouse

Not further specified in the UI, so I just left it with a simple name and association to company.

## PurchaseOrder

Assuming this acts more or less as an invoice with several products on it. For our purposes, the date of the order seemed the only important attribute, as by comparing it to the delivery date, it would help us understand how long it usually takes for a product to be delivered after being ordered. Maybe adding another identifer which can be imported would also be useful.

## PurchaseOrderItem

Tells us how many products were ordered and when they are expected to be delivered.

## Bundle

My understanding is that a bundle consists of multiple products that are being sold as one. Belongs to a company, as bundles are company-specific groupings.

## Product

Represents the actual items being sold. Belongs to a company, as products are managed per company. I added a many-to-many relationship to vendors, as I can imagine that it might be possible that some products can be ordered from multiple vendors. When starting, I would also consider starting with a simple one-to-many relationship and switching to many-to-many later.

## SalesHistory

Used to track quantity of products sold, useful for predicting when the item will need to be restocked again.

## Vendor

My understanding is that a vendor is meant as a supplier who can supply specific products.

## OnboardingFileUpload

Used to store files uploaded during onboarding, so that they can be processed in the background (assuming that files can get big enough that processing them synchronously would take too long). File size is limited to 10 MB. A background job is enqueued after upload to handle processing.

## IntegrationRequest

Allows users to request integrations that are not yet available in the predefined list. Stores the requested integration name and an optional description. Belongs to a company.

---

## Notes

- I only added minimum attributes needed to satisfy the requirements. I assume that in real life there would be many more.
- For each model, I would also add `created_at` and `updated_at` timestamps, as they are useful in many ways and do not cost much to store.

# REST API

All endpoints are under `/api/v1`. The company is currently resolved automatically (will be derived from authenticated user in the future).

## Onboarding Status

### `GET /api/v1/onboarding`

Returns the current onboarding progress for the company, including all steps and their statuses.

**Params:** none

**Request:**
```
GET /api/v1/onboarding
```

**Response:**
```json
{
  "company": {
    "id": 1,
    "name": "Acme Corp",
    "lead_days": 7,
    "stock_days": 30,
    "forecasting_days": 90
  },
  "onboarding": {
    "completed": false,
    "current_step": "lead_time",
    "steps": [
      { "name": "welcome", "position": 0, "status": "completed", "mandatory": false, "locked": false, "lock_reason": null },
      { "name": "lead_time", "position": 1, "status": "pending", "mandatory": true, "locked": false, "lock_reason": null },
      { "name": "upload_pos", "position": 6, "status": "pending", "mandatory": false, "locked": true, "lock_reason": "Requires vendors to be added first" }
    ]
  }
}
```

## Onboarding Step Endpoints

Each step has a `PATCH` endpoint to complete it, and optional steps also have a `PATCH .../skip` endpoint. All step completion responses follow the same format.

### `PATCH /api/v1/onboarding/welcome`

Marks the welcome step as completed.

**Params:** none

**Request:**
```
PATCH /api/v1/onboarding/welcome
```

**Response:**
```json
{
  "step": { "name": "welcome", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": null, "stock_days": null, "forecasting_days": null }
}
```

### `PATCH /api/v1/onboarding/welcome/skip`

Skips the welcome step. Only available for non-mandatory steps.

**Params:** none

**Request:**
```
PATCH /api/v1/onboarding/welcome/skip
```

**Response:**
```json
{
  "step": { "name": "welcome", "status": "skipped" }
}
```

### `PATCH /api/v1/onboarding/lead_time`

Sets the company's lead time and completes the step. Mandatory.

**Params:** `lead_days` (positive integer, required)

**Request:**
```json
PATCH /api/v1/onboarding/lead_time
{ "lead_days": 7 }
```

**Response:**
```json
{
  "step": { "name": "lead_time", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": null, "forecasting_days": null }
}
```

### `PATCH /api/v1/onboarding/stock_days`

Sets the company's days of stock and completes the step. Mandatory.

**Params:** `stock_days` (positive integer, required)

**Request:**
```json
PATCH /api/v1/onboarding/stock_days
{ "stock_days": 30 }
```

**Response:**
```json
{
  "step": { "name": "stock_days", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": null }
}
```

### `PATCH /api/v1/onboarding/forecasting_period`

Sets the company's forecasting period and completes the step. Mandatory.

**Params:** `forecasting_days` (positive integer, required)

**Request:**
```json
PATCH /api/v1/onboarding/forecasting_period
{ "forecasting_days": 90 }
```

**Response:**
```json
{
  "step": { "name": "forecasting_period", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": 90 }
}
```

### `PATCH /api/v1/onboarding/add_vendors`

Marks the add vendors step as completed.

**Params:** none

**Request:**
```
PATCH /api/v1/onboarding/add_vendors
```

**Response:**
```json
{
  "step": { "name": "add_vendors", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": 90 }
}
```

### `PATCH /api/v1/onboarding/add_products`

Marks the add products step as completed.

**Params:** none

### `PATCH /api/v1/onboarding/upload_pos`

Uploads a CSV or Excel file (max 10 MB) containing purchase orders and completes the step. This step is locked until vendors have been added. The uploaded file is stored and a background job (`PurchaseOrderImportJob`) is enqueued to process it asynchronously. The processing status can be polled via `GET /api/v1/onboarding/file_uploads/:id`.

**Params:** `file` (file, required — CSV, XLS, or XLSX)

**Request:**
```
PATCH /api/v1/onboarding/upload_pos
Content-Type: multipart/form-data
file=<uploaded_file>
```

**Response:**
```json
{
  "step": { "name": "upload_pos", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": 90 }
}
```

**Error when locked:**
```json
{ "error": "Step is locked", "lock_reason": "Requires vendors to be added first" }
```

**Error when file missing:**
```json
{ "error": "File is required" }
```

**Error when invalid file type:**
```json
{ "error": "Invalid file type. Allowed types: CSV, XLS, XLSX" }
```

**Error when file too large:**
```json
{ "error": "File is too large (maximum is 10 MB)" }
```

### `PATCH /api/v1/onboarding/match_suppliers`

Assigns vendors to products and marks the match suppliers step as completed. The assignments parameter is optional — if omitted, the step is simply marked as completed without changing any product-vendor associations.

**Params:** `assignments` (array, optional) — each element: `{ product_id, vendor_ids }`

**Request:**
```json
PATCH /api/v1/onboarding/match_suppliers
{
  "assignments": [
    { "product_id": 1, "vendor_ids": [1, 2] },
    { "product_id": 2, "vendor_ids": [3] }
  ]
}
```

**Response:**
```json
{
  "step": { "name": "match_suppliers", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": 90 }
}
```

**Error when product/vendor not found:**
```json
{ "error": "Some vendor IDs do not belong to this company" }
```

### `PATCH /api/v1/onboarding/bundles`

Uploads a CSV or Excel file (max 10 MB) containing bundles and completes the step. The uploaded file is stored and a background job (`BundleImportJob`) is enqueued to process it asynchronously. The processing status can be polled via `GET /api/v1/onboarding/file_uploads/:id`.

**Params:** `file` (file, required — CSV, XLS, or XLSX)

**Request:**
```
PATCH /api/v1/onboarding/bundles
Content-Type: multipart/form-data
file=<uploaded_file>
```

**Response:**
```json
{
  "step": { "name": "bundles", "status": "completed" },
  "company": { "id": 1, "name": "Acme Corp", "lead_days": 7, "stock_days": 30, "forecasting_days": 90 }
}
```

**Error when file missing:**
```json
{ "error": "File is required" }
```

**Error when invalid file type:**
```json
{ "error": "Invalid file type. Allowed types: CSV, XLS, XLSX" }
```

**Error when file too large:**
```json
{ "error": "File is too large (maximum is 10 MB)" }
```

### `PATCH /api/v1/onboarding/set_integrations`

Marks the integrations step as completed.

**Params:** none

### Skip endpoints

All optional steps support `PATCH /api/v1/onboarding/{step_name}/skip`. Available for: `welcome`, `add_vendors`, `add_products`, `upload_pos`, `match_suppliers`, `bundles`, `set_integrations`. Mandatory steps (`lead_time`, `stock_days`, `forecasting_period`) return an error when skip is attempted.

## File Uploads

### `POST /api/v1/onboarding/file_uploads`

Uploads a file for a specific onboarding step (purchase orders or bundles).

**Params:** `step` (string, required — one of: `upload_pos`, `bundles`), `file` (file, required)

**Request:**
```
POST /api/v1/onboarding/file_uploads
Content-Type: multipart/form-data
step=upload_pos&file=<uploaded_file>
```

**Response (201):**
```json
{
  "file_upload": {
    "id": 1,
    "step": "upload_pos",
    "processing_status": "pending",
    "created_at": "2026-03-16T10:00:00Z"
  }
}
```

### `GET /api/v1/onboarding/file_uploads/:id`

Returns the status of a previously uploaded file (useful for polling processing status).

**Params:** `id` (integer, required — in URL)

**Request:**
```
GET /api/v1/onboarding/file_uploads/1
```

**Response:**
```json
{
  "file_upload": {
    "id": 1,
    "step": "upload_pos",
    "processing_status": "pending",
    "created_at": "2026-03-16T10:00:00Z"
  }
}
```

## Vendors

### `GET /api/v1/vendors`

Returns all vendors for the company with their associated product IDs.

**Params:** none

**Request:**
```
GET /api/v1/vendors
```

**Response:**
```json
{
  "vendors": [
    { "id": 1, "name": "Supplier A", "product_ids": [1, 3, 5] },
    { "id": 2, "name": "Supplier B", "product_ids": [2, 4] }
  ]
}
```

### `POST /api/v1/vendors`

Creates a new vendor for the company.

**Params:** `vendor[name]` (string, required)

**Request:**
```json
POST /api/v1/vendors
{ "vendor": { "name": "Supplier A" } }
```

**Response (201):**
```json
{
  "vendor": { "id": 1, "name": "Supplier A", "product_ids": [] }
}
```

## Products

### `GET /api/v1/products`

Returns all products for the company with their associated vendor IDs.

**Params:** none

**Request:**
```
GET /api/v1/products
```

**Response:**
```json
{
  "products": [
    { "id": 1, "name": "Widget", "vendor_ids": [1, 2] },
    { "id": 2, "name": "Gadget", "vendor_ids": [3] }
  ]
}
```

### `POST /api/v1/products`

Creates a new product for the company.

**Params:** `product[name]` (string, required)

**Request:**
```json
POST /api/v1/products
{ "product": { "name": "Widget" } }
```

**Response (201):**
```json
{
  "product": { "id": 1, "name": "Widget", "vendor_ids": [] }
}
```

### `PATCH /api/v1/products/assign_vendors`

Bulk assigns vendors to products. Validates that all vendor IDs belong to the company.

**Params:** `assignments` (array, required) — each element: `{ product_id, vendor_ids }`

**Request:**
```json
PATCH /api/v1/products/assign_vendors
{
  "assignments": [
    { "product_id": 1, "vendor_ids": [1, 2] },
    { "product_id": 2, "vendor_ids": [3] }
  ]
}
```

**Response:**
```json
{
  "products": [
    { "id": 1, "name": "Widget", "vendor_ids": [1, 2] },
    { "id": 2, "name": "Gadget", "vendor_ids": [3] }
  ]
}
```

## Integrations

### `GET /api/v1/integrations`

Returns all configured integrations and the list of providers still available to add.

**Params:** none

**Request:**
```
GET /api/v1/integrations
```

**Response:**
```json
{
  "integrations": [
    { "id": 1, "provider": "shopify", "configuration": { "api_key": "abc123" } }
  ],
  "available_providers": ["woocommerce", "magento"]
}
```

### `POST /api/v1/integrations`

Creates a new integration for the company.

**Params:** `integration[provider]` (string, required), `integration[configuration]` (object, optional)

**Request:**
```json
POST /api/v1/integrations
{ "integration": { "provider": "shopify", "configuration": { "api_key": "abc123" } } }
```

**Response (201):**
```json
{
  "integration": { "id": 1, "provider": "shopify", "configuration": { "api_key": "abc123" } }
}
```

### `PATCH /api/v1/integrations/:id`

Updates an existing integration's configuration.

**Params:** `id` (integer, required — in URL), `integration[provider]` (string), `integration[configuration]` (object)

**Request:**
```json
PATCH /api/v1/integrations/1
{ "integration": { "configuration": { "api_key": "new_key" } } }
```

**Response:**
```json
{
  "integration": { "id": 1, "provider": "shopify", "configuration": { "api_key": "new_key" } }
}
```

### `DELETE /api/v1/integrations/:id`

Removes an integration.

**Params:** `id` (integer, required — in URL)

**Request:**
```
DELETE /api/v1/integrations/1
```

**Response:** `204 No Content`

## Integration Requests

### `GET /api/v1/integration_requests`

Returns all integration requests submitted by the company.

**Params:** none

**Request:**
```
GET /api/v1/integration_requests
```

**Response:**
```json
{
  "integration_requests": [
    { "id": 1, "name": "SAP", "description": "Need SAP integration for inventory sync", "created_at": "2026-03-16T10:00:00Z" }
  ]
}
```

### `POST /api/v1/integration_requests`

Submits a request for an integration that is not yet available.

**Params:** `integration_request[name]` (string, required), `integration_request[description]` (string, optional)

**Request:**
```json
POST /api/v1/integration_requests
{ "integration_request": { "name": "SAP", "description": "Need SAP integration for inventory sync" } }
```

**Response (201):**
```json
{
  "integration_request": { "id": 1, "name": "SAP", "description": "Need SAP integration for inventory sync", "created_at": "2026-03-16T10:00:00Z" }
}
```
