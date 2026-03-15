# Onboarding System — Backend Architecture

## Table of Contents

1. [Data Model Design](#1-data-model-design)
2. [API Endpoint Design](#2-api-endpoint-design)
3. [Background Processes](#3-background-processes)
4. [Step Registry & Side Effects](#4-step-registry--side-effects)

---

## 1. Data Model Design

### Entity-Relationship Overview

```
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│            Company              │       │            Product              │
│─────────────────────────────────│       │─────────────────────────────────│
│ name                            │       │ name                            │
│ lead_days                       │       └────────┬───────────────┬────────┘
│ stock_days                      │                │               │
│ forecasting_days                │                │ *             │ *
│ completed_onboarding_steps[]    │                │               │
└───┬─────────┬───────────────┬───┘                │    ┌─────────┴─────────┐
    │         │               │                    │    │   SalesHistory     │
    │ 1       │ 1             │ 1                  │    │───────────────────│
    │         │               │                    │    │ product_id        │
    │         │               │                    │    │ date              │
    │         │               │                    │    └───────────────────┘
    │         │               │
    │         │               │    ┌─────────────────────────────────┐
    │         │               └───>│            Vendor               │
    │         │                1 * │─────────────────────────────────│
    │         │                    │ name                            │
    │         │                    │ company_id                      │
    │         │                    └──────────────┬──────────────────┘
    │         │                                   │
    │         │                                   │ *
    │         │    ┌──────────────────────────────────────────────────┐
    │         │    │              PurchaseOrderItem                   │
    │         │    │──────────────────────────────────────────────────│
    │         │    │ purchase_order_id                                │
    │         │    │ product_id  ─────────────────────────────────────┤ * Product
    │         │    │ vendor_id                                        │
    │         │    │ quantity                                         │
    │         │    │ expected_delivery_date                           │
    │         │    └──────────────────────┬───────────────────────────┘
    │         │                           │ *
    │         │    ┌──────────────────────┴───────────────────────────┐
    │         │    │              PurchaseOrder                       │
    │         └───>│──────────────────────────────────────────────────│
    │          1 * │ company_id                                       │
    │              │ order_date                                       │
    │              └─────────────────────────────────────────────────┘
    │
    │         ┌─────────────────────────────────┐
    │ 1     * │          Integration             │
    ├────────>│─────────────────────────────────│
    │         │ provider                         │
    │         │ configuration                    │
    │         └─────────────────────────────────┘
    │
    │         ┌─────────────────────────────────┐
    │ 1     * │            Bundle                │
    ├────────>│─────────────────────────────────│
    │         │ name                             │
    │         └────────────────┬────────────────┘
    │                          │ 1
    │                          │ *
    │         ┌────────────────┴────────────────┐
    │         │         BundleProduct            │
    │         │─────────────────────────────────│
    │         │ bundle_id                        │
    │         │ product_id                       │
    │         └─────────────────────────────────┘
    │
    │         ┌─────────────────────────────────┐
    │ 1     * │          Warehouse               │
    └────────>│─────────────────────────────────│
              │ name                             │
              └─────────────────────────────────┘

    STEP_DEPENDENCIES — Ruby constant, not a DB table
```

### Changes to Existing Models

#### `Company` (add columns)

| Column                       | Type     | Default | Notes                                                            |
| ---------------------------- | -------- | ------- | ---------------------------------------------------------------- |
| `lead_days`                  | integer  | `nil`   | Set in onboarding step 1                                         |
| `stock_days`                 | integer  | `nil`   | Set in onboarding step 2                                         |
| `forecasting_days`           | integer  | `nil`   | Set in onboarding step 3                                         |
| `completed_onboarding_steps` | string[] | `[]`    | Tracks which steps are done, e.g. `['welcome', 'set_lead_time']` |

**Migration:**

```ruby
class AddOnboardingFieldsToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :lead_days, :integer
    add_column :companies, :stock_days, :integer
    add_column :companies, :forecasting_days, :integer
    add_column :companies, :completed_onboarding_steps, :string, array: true, default: []
  end
end
```

The `completed_onboarding_steps` array is the **source of truth** for progress. The "current step" is derived at runtime: the first step in the ordered registry whose key is not in this array. This avoids maintaining a separate pointer that could drift out of sync.

#### `Vendor` (existing — add column)

Vendor belongs to Company. The supplier-product matching (step 5) is stored through `PurchaseOrderItem`, which links a product to a vendor.

| Column       | Type   | Notes            |
| ------------ | ------ | ---------------- |
| `company_id` | bigint | FK → `companies` |

### New Models

#### `PurchaseOrder` (step 4 — Upload existing POs)

Groups line items into a single order.

| Column                      | Type       | Notes                  |
| --------------------------- | ---------- | ---------------------- |
| `id`                        | bigint     | PK                     |
| `company_id`                | bigint     | FK → `companies`       |
| `order_date`                | date       | Date the PO was placed |
| `created_at` / `updated_at` | timestamps |                        |

#### `PurchaseOrderItem`

Each row is one line item belonging to a `PurchaseOrder`.

| Column                      | Type       | Notes                  |
| --------------------------- | ---------- | ---------------------- |
| `id`                        | bigint     | PK                     |
| `purchase_order_id`         | bigint     | FK → `purchase_orders` |
| `product_id`                | bigint     | FK → `products`        |
| `vendor_id`                 | bigint     | FK → `vendors`         |
| `quantity`                  | integer    |                        |
| `expected_delivery_date`    | date       |                        |
| `created_at` / `updated_at` | timestamps |                        |

```ruby
class CreatePurchaseOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_orders do |t|
      t.references :company, null: false, foreign_key: true
      t.date :order_date, null: false
      t.timestamps
    end

    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.date :expected_delivery_date, null: false
      t.timestamps
    end
  end
end
```

#### `Bundle` (step 6 — Set bundles)

A bundle belongs to a company and has many products through a join table.

| Column                      | Type       | Notes                              |
| --------------------------- | ---------- | ---------------------------------- |
| `id`                        | bigint     | PK                                 |
| `company_id`                | bigint     | FK → `companies`                   |
| `name`                      | string     | Bundle name (e.g. "Gift Set")      |
| `created_at` / `updated_at` | timestamps |                                    |

#### `BundleProduct`

Join table linking bundles to their component products.

| Column                      | Type       | Notes              |
| --------------------------- | ---------- | ------------------ |
| `id`                        | bigint     | PK                 |
| `bundle_id`                 | bigint     | FK → `bundles`     |
| `product_id`                | bigint     | FK → `products`    |
| `created_at` / `updated_at` | timestamps |                    |

```ruby
class CreateBundles < ActiveRecord::Migration[7.1]
  def change
    create_table :bundles do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    create_table :bundle_products do |t|
      t.references :bundle, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end

    add_index :bundle_products, [:bundle_id, :product_id], unique: true
  end
end
```

#### `Integration` (step 7 — Set integrations)

| Column                      | Type       | Notes                                                                    |
| --------------------------- | ---------- | ------------------------------------------------------------------------ |
| `id`                        | bigint     | PK                                                                       |
| `company_id`                | bigint     | FK → `companies`                                                         |
| `provider`                  | string     | `shopify`, `amazon`, or `custom_request`                                 |
| `configuration`             | jsonb      | Provider-specific configuration (OAuth tokens, request details, etc.)    |
| `created_at` / `updated_at` | timestamps |                                                                          |

```ruby
class CreateIntegrations < ActiveRecord::Migration[7.1]
  def change
    create_table :integrations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :provider, null: false
      t.jsonb :configuration, default: {}
      t.timestamps
    end

    add_index :integrations, [:company_id, :provider]
  end
end
```

#### `OnboardingFileUpload` (steps 4 & 6)

Tracks file upload and async processing status so the frontend can poll.

| Column                      | Type       | Notes                                          |
| --------------------------- | ---------- | ---------------------------------------------- |
| `id`                        | bigint     | PK                                             |
| `company_id`                | bigint     | FK → `companies`                               |
| `step_key`                  | string     | `upload_pos` or `set_bundles`                  |
| `processing_status`         | enum       | `pending`, `processing`, `completed`, `failed` |
| `error_message`             | text       | nullable — populated on failure                |
| `created_at` / `updated_at` | timestamps |                                                |

File attachment via **ActiveStorage** (`has_one_attached :file`).

```ruby
class CreateOnboardingFileUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :onboarding_file_uploads do |t|
      t.references :company, null: false, foreign_key: true
      t.string :step_key, null: false
      t.integer :processing_status, default: 0, null: false
      t.text :error_message
      t.timestamps
    end
  end
end
```

#### Step Dependencies (Ruby constant — no database table)

Locking rules are defined as a constant in the codebase. No migration or seed data needed.

```ruby
# app/models/onboarding/step_dependencies.rb
module Onboarding
  STEP_DEPENDENCIES = {
    upload_pos: [
      { type: :sync_complete, key: 'product_sync' }
    ],
    match_suppliers: [
      { type: :sync_complete, key: 'product_sync' },
      { type: :step_complete, key: 'upload_pos' }
    ],
    set_bundles: [
      { type: :step_complete, key: 'match_suppliers' }
    ],
    set_integrations: [
      { type: :step_complete, key: 'set_bundles' }
    ]
  }.freeze
end
```

Steps not listed (0–3) have no dependencies and are always unlocked.

### Locking Rules (Presumptions)

| Steps                       | Rule                                                                                                                                   |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| 0–3 (Welcome → Forecasting) | Always unlocked. Sequential order enforced by checking `completed_onboarding_steps` — you can only complete the next uncompleted step. |
| 4 (Upload POs)              | Locked until product sync is complete. Can be **skipped** by the user.                                                                 |
| 5 (Match Suppliers)         | Locked until product sync is complete **AND** step 4 is completed/skipped.                                                             |
| 6 (Set Bundles)             | Locked until step 5 is completed.                                                                                                      |
| 7 (Set Integrations)        | Locked until step 6 is completed.                                                                                                      |

### Design Justifications

1. **`completed_onboarding_steps` array on Company**: Simple, low overhead. The current step is derived from the ordered registry minus completed keys — no separate pointer to maintain. PostgreSQL array columns support `ANY()` queries for filtering.

2. **Step data on domain models, not a generic blob**: `lead_days`, `stock_days`, and `forecasting_days` live on Company because they're used throughout the application beyond onboarding. This avoids data duplication.

3. **`STEP_DEPENDENCIES` constant for locking**: Keeps lock rules in one place as a simple Ruby hash. Adding a new dependency (e.g., "step X requires warehouse sync") is a one-line addition to the constant — no migration or seed needed.

4. **`Bundle` + `BundleProduct` join table**: Clean separation — `Bundle` holds metadata (name, company), `BundleProduct` maps component products. If quantities per component are needed later, adding a `quantity` column to `BundleProduct` is a single migration.

---

## 2. API Endpoint Design

All endpoints are scoped to the authenticated company (via session or token). Base path: **`/api/v1/onboarding`**.

### 2.1 `GET /api/v1/onboarding`

**Purpose:** Returns the full onboarding state. The frontend calls this on page load to render the correct step and lock states. This is how "resume where you left off" works.

**Response (200 OK):**

```json
{
  "onboarding": {
    "current_step": "set_days_of_stock",
    "completed_steps": ["welcome", "set_lead_time"],
    "sync_progress": {
      "products": { "total": 1200, "fetched": 850, "complete": false },
      "warehouses": { "total": 5, "fetched": 5, "complete": true }
    },
    "steps": [
      {
        "step_key": "welcome",
        "position": 0,
        "status": "completed",
        "locked": false
      },
      {
        "step_key": "set_lead_time",
        "position": 1,
        "status": "completed",
        "locked": false,
        "data": { "lead_days": 14 }
      },
      {
        "step_key": "set_days_of_stock",
        "position": 2,
        "status": "current",
        "locked": false,
        "data": {}
      },
      {
        "step_key": "set_forecasting_days",
        "position": 3,
        "status": "pending",
        "locked": false,
        "data": {}
      },
      {
        "step_key": "upload_pos",
        "position": 4,
        "status": "pending",
        "locked": true
      },
      {
        "step_key": "match_suppliers",
        "position": 5,
        "status": "pending",
        "locked": true
      },
      {
        "step_key": "set_bundles",
        "position": 6,
        "status": "pending",
        "locked": true
      },
      {
        "step_key": "set_integrations",
        "position": 7,
        "status": "pending",
        "locked": true
      }
    ]
  }
}
```

**Implementation notes:**

- `current_step`: Derived from the first step in the registry not in `completed_onboarding_steps`.
- `status` per step: `completed` if in the array, `current` if it's the derived current step, `pending` otherwise.
- `locked`: Computed by `LockEvaluator` for each step.
- `data`: Populated from the relevant model (e.g., `company.lead_days`). Only included for steps that have been completed or are current.
- `sync_progress`: Always included so the frontend can show sync status and explain why steps are locked.

---

### 2.2 `PUT /api/v1/onboarding/steps/:step_key`

**Purpose:** Complete a step by saving its data. This is the primary endpoint the frontend calls when the user fills in a step and clicks "Save" / "Next".

**Request (step: `set_lead_time`):**

```json
{
  "data": {
    "lead_days": 14
  }
}
```

**Response (200 OK):**

```json
{
  "step": {
    "step_key": "set_lead_time",
    "status": "completed"
  },
  "next_step": "set_days_of_stock"
}
```

**Error Responses:**

- **422 Unprocessable Entity** — Step is locked, out of order, or data validation fails:

  ```json
  {
    "error": "step_locked",
    "message": "This step is locked. Required: product sync must be complete."
  }
  ```

- **404 Not Found** — Invalid `step_key`.

**Step-specific request bodies:**

| Step                   | Request `data`               |
| ---------------------- | ---------------------------- |
| `welcome`              | `{}` (no data)               |
| `set_lead_time`        | `{ "lead_days": 14 }`        |
| `set_days_of_stock`    | `{ "stock_days": 30 }`       |
| `set_forecasting_days` | `{ "forecasting_days": 90 }` |

Steps 4–7 use their own dedicated endpoints (below) rather than this generic one.

---

### 2.3 `PUT /api/v1/onboarding/steps/:step_key/skip`

**Purpose:** Mark a skippable step as done without providing data. Currently only step 4 (`upload_pos`) is skippable.

**Response (200 OK):**

```json
{
  "step": {
    "step_key": "upload_pos",
    "status": "skipped"
  },
  "next_step": "match_suppliers"
}
```

**Error:** `422` if the step is not skippable or is locked.

---

### 2.4 `POST /api/v1/onboarding/steps/:step_key/upload`

**Purpose:** Upload a CSV/Excel file for steps 4 (`upload_pos`) and 6 (`set_bundles`). Returns immediately with a tracking ID; processing happens asynchronously.

**Request:** `multipart/form-data` with a `file` field.

**Response (202 Accepted):**

```json
{
  "upload": {
    "id": 42,
    "processing_status": "pending"
  }
}
```

---

### 2.5 `GET /api/v1/onboarding/uploads/:id`

**Purpose:** Poll file processing status. Frontend calls this on an interval after uploading.

**Response (200 OK):**

```json
{
  "upload": {
    "id": 42,
    "processing_status": "completed",
    "error_message": null
  }
}
```

Possible `processing_status` values: `pending`, `processing`, `completed`, `failed`.

---

### 2.6 `GET /api/v1/onboarding/sync_progress`

**Purpose:** Dedicated lightweight endpoint for polling sync status. The frontend can call this more frequently than the full `GET /onboarding` endpoint.

**Response (200 OK):**

```json
{
  "products": { "total": 1200, "fetched": 850, "complete": false },
  "warehouses": { "total": 5, "fetched": 5, "complete": true }
}
```

---

### 2.7 `POST /api/v1/onboarding/steps/match_suppliers`

**Purpose:** Save product-vendor mappings for step 5. Accepts a batch of mappings.

**Request:**

```json
{
  "mappings": [
    { "product_id": 1, "vendor_id": 10 },
    { "product_id": 2, "vendor_id": 11 },
    { "product_id": 3, "vendor_id": 10 }
  ]
}
```

**Response (200 OK):**

```json
{
  "step": {
    "step_key": "match_suppliers",
    "status": "completed"
  },
  "next_step": "set_bundles",
  "mappings_saved": 3
}
```

**Errors:** `422` if any product_id or vendor_id is invalid, or step is locked.

---

### 2.8 `POST /api/v1/onboarding/steps/set_integrations`

**Purpose:** Save integration selections for step 7 (final step).

**Request:**

```json
{
  "integrations": [
    { "provider": "shopify" },
    { "provider": "custom_request", "details": "Our ERP system XYZ" }
  ]
}
```

**Response (200 OK):**

```json
{
  "step": {
    "step_key": "set_integrations",
    "status": "completed"
  },
  "next_step": null,
  "onboarding_complete": true
}
```

When `next_step` is `null`, onboarding is complete (all steps are in `completed_onboarding_steps`).

---

### Endpoint Summary

| Method | Path                                        | Purpose                                 |
| ------ | ------------------------------------------- | --------------------------------------- |
| `GET`  | `/api/v1/onboarding`                        | Full onboarding state (resume support)  |
| `PUT`  | `/api/v1/onboarding/steps/:step_key`        | Complete a step (steps 0–3)             |
| `PUT`  | `/api/v1/onboarding/steps/:step_key/skip`   | Skip a step (step 4)                    |
| `POST` | `/api/v1/onboarding/steps/:step_key/upload` | Upload file (steps 4, 6)                |
| `GET`  | `/api/v1/onboarding/uploads/:id`            | Poll file processing status             |
| `GET`  | `/api/v1/onboarding/sync_progress`          | Poll sync progress                      |
| `POST` | `/api/v1/onboarding/steps/match_suppliers`  | Save supplier-product mappings (step 5) |
| `POST` | `/api/v1/onboarding/steps/set_integrations` | Save integration selections (step 7)    |

---

## 3. Background Processes

All async jobs use **Sidekiq** for background processing.

### Worker Overview

| Worker                         | Trigger                     | Purpose                                                                                      | Queue             |
| ------------------------------ | --------------------------- | -------------------------------------------------------------------------------------------- | ----------------- |
| `LeadTimeUpdater`              | Step 1 completed            | Updates product lead times across the system based on the new company setting                | `default`         |
| `RefreshCalculationsWorker`    | Step 3 completed            | Recalculates forecasting data using the new forecasting window                               | `default`         |
| `PoFileProcessorWorker`        | Step 4 file uploaded        | Parses CSV/Excel file, validates rows, creates `PurchaseOrder` + `PurchaseOrderItem` records | `file_processing` |
| `BundleFileProcessorWorker`    | Step 6 file uploaded        | Parses CSV/Excel file, validates rows, creates `Bundle` records                              | `file_processing` |
| `IntegrationSetupWorker`       | Step 7 completed            | Initiates OAuth flows or sends custom integration requests                                   | `integrations`    |
| `OnboardingLockCheckWorker`    | Periodic cron (every 2 min) | Re-evaluates step locks when sync progress changes                                           | `default`         |
| `OnboardingNotificationWorker` | Various events              | Sends onboarding-related emails                                                              | `mailers`         |

### File Processing Flow

```
User uploads file
       │
       ▼
POST /steps/:step_key/upload
       │
       ├─► Save file via ActiveStorage
       ├─► Create OnboardingFileUpload (status: pending)
       ├─► Return 202 to frontend
       │
       └─► Enqueue PoFileProcessorWorker / BundleFileProcessorWorker
              │
              ├─► Update status → "processing"
              ├─► Parse CSV/Excel rows
              ├─► Validate data (product IDs exist, etc.)
              ├─► Insert records in batches
              │
              ├─ On success:
              │    ├─► Update status → "completed"
              │    ├─► Add step to completed_onboarding_steps
              │    └─► Run LockEvaluator (may unlock next steps)
              │
              └─ On failure:
                   ├─► Update status → "failed"
                   └─► Set error_message (e.g. "Row 15: unknown product SKU 'ABC123'")
```

The frontend polls `GET /onboarding/uploads/:id` to track progress.

### Sync Lock Re-evaluation

`OnboardingLockCheckWorker` runs on a **cron schedule** (e.g., every 2 minutes via `sidekiq-cron` or `sidekiq-scheduler`). For each company that has not yet completed all onboarding steps, it:

1. Calls `SyncProgressService.new(company).progress` to check sync status
2. Runs `LockEvaluator.new(company).evaluate!`
3. If any steps become unlocked, it can optionally trigger a notification

Alternatively, if the sync services support **callbacks/webhooks**, the lock check can be triggered immediately when a sync completes, rather than relying on polling.

### Notification Triggers

| Event                           | Email                                   |
| ------------------------------- | --------------------------------------- |
| Company starts onboarding       | Welcome email with overview of steps    |
| Onboarding incomplete after 48h | Nudge email to resume                   |
| All steps completed             | Completion confirmation with next steps |
| File processing fails           | Alert to retry upload                   |

### Sync Progress Service

Wraps the existing fetcher services to provide a unified interface:

```ruby
# app/services/onboarding/sync_progress_service.rb
module Onboarding
  class SyncProgressService
    FETCHERS = {
      'product_sync'   => ProductFetcher,
      'warehouse_sync' => WarehouseFetcher
    }.freeze

    def initialize(company)
      @company = company
    end

    def progress
      FETCHERS.transform_values do |klass|
        klass.new(@company).progress
      end
    end

    def complete?(key)
      fetcher_class = FETCHERS[key]
      result = fetcher_class.new(@company).progress
      result[:fetched] >= result[:total]
    end
  end
end
```

---

## 4. Step Registry & Side Effects

The step registry is the core pattern that makes the onboarding system **extensible**. All step metadata — ordering, skippability, validators, and side effects — lives in one place. Controllers and services read from the registry; they don't contain step-specific logic.

### Registry Definition

```ruby
# app/models/onboarding/step_registry.rb
module Onboarding
  STEP_REGISTRY = [
    {
      key: :welcome,
      position: 0,
      skippable: false,
      side_effect: nil,
      validator: nil
    },
    {
      key: :set_lead_time,
      position: 1,
      skippable: false,
      side_effect: 'LeadTimeUpdater',
      validator: 'Onboarding::Validators::LeadTime'
    },
    {
      key: :set_days_of_stock,
      position: 2,
      skippable: false,
      side_effect: nil,
      validator: 'Onboarding::Validators::DaysOfStock'
    },
    {
      key: :set_forecasting_days,
      position: 3,
      skippable: false,
      side_effect: 'RefreshCalculationsWorker',
      validator: 'Onboarding::Validators::ForecastingDays'
    },
    {
      key: :upload_pos,
      position: 4,
      skippable: true,
      side_effect: 'PoFileProcessorWorker',
      validator: nil
    },
    {
      key: :match_suppliers,
      position: 5,
      skippable: false,
      side_effect: nil,
      validator: 'Onboarding::Validators::SupplierMappings'
    },
    {
      key: :set_bundles,
      position: 6,
      skippable: false,
      side_effect: 'BundleFileProcessorWorker',
      validator: nil
    },
    {
      key: :set_integrations,
      position: 7,
      skippable: false,
      side_effect: 'IntegrationSetupWorker',
      validator: 'Onboarding::Validators::Integrations'
    }
  ].freeze

  def self.find_step(key)
    STEP_REGISTRY.find { |s| s[:key] == key.to_sym }
  end

  def self.ordered_keys
    STEP_REGISTRY.map { |s| s[:key].to_s }
  end

  def self.current_step_for(company)
    ordered_keys.find { |key| !company.completed_onboarding_steps.include?(key) }
  end
end
```

### Adding a New Step

To add a new step (e.g., "Set safety stock" at position 3.5):

1. **Add an entry** to `STEP_REGISTRY` at the desired position
2. **Create a validator** (optional): `Onboarding::Validators::SafetyStock`
3. **Create a side-effect worker** (optional): `SafetyStockUpdater`
4. **Add locking rules** (if any): Add an entry to `STEP_DEPENDENCIES`
5. **Add a migration** if the step stores data on an existing model (e.g., `add_column :companies, :safety_stock_days, :integer`)

No changes needed to: controllers, `CompleteStep` service, `LockEvaluator`, or API serializers.

### CompleteStep Service

The central service that orchestrates step completion. The controller delegates all logic here.

```ruby
# app/services/onboarding/complete_step.rb
module Onboarding
  class CompleteStep
    def initialize(company, step_key, data = {})
      @company = company
      @step_key = step_key.to_sym
      @data = data
      @config = Onboarding.find_step(@step_key)
    end

    def call
      return failure(:not_found, 'Unknown step') unless @config
      return failure(:locked, 'Step is locked') if LockEvaluator.new(@company).locked?(@step_key)
      return failure(:out_of_order, 'Complete previous steps first') unless can_complete?

      # Validate step-specific data
      if @config[:validator]
        validator = @config[:validator].constantize.new(@data)
        return failure(:invalid, validator.errors.full_messages) unless validator.valid?
      end

      ActiveRecord::Base.transaction do
        # Persist step data to the appropriate model
        persist_step_data!

        # Record step as completed
        @company.completed_onboarding_steps << @step_key.to_s
        @company.completed_onboarding_steps.uniq!

        @company.save!
      end

      # Trigger async side effect (outside transaction)
      if @config[:side_effect]
        @config[:side_effect].constantize.perform_async(@company.id)
      end

      # Re-evaluate locks for downstream steps
      LockEvaluator.new(@company).evaluate!

      success(next_step: Onboarding.current_step_for(@company))
    end

    private

    def can_complete?
      Onboarding.current_step_for(@company) == @step_key.to_s
    end

    def persist_step_data!
      case @step_key
      when :set_lead_time
        @company.update!(lead_days: @data[:lead_days])
      when :set_days_of_stock
        @company.update!(stock_days: @data[:stock_days])
      when :set_forecasting_days
        @company.update!(forecasting_days: @data[:forecasting_days])
      when :set_integrations
        @data[:integrations].each do |integration|
          Integration.create!(
            company_id: @company.id,
            provider: integration[:provider],
            configuration: integration.except(:provider)
          )
        end
      end
      # Steps welcome, upload_pos, match_suppliers, and set_bundles
      # are handled by their async workers or dedicated endpoints
    end

    def success(next_step:)
      OpenStruct.new(success?: true, next_step: next_step)
    end

    def failure(code, message)
      OpenStruct.new(success?: false, error_code: code, message: message)
    end
  end
end
```

### Lock Evaluator

Reads dependency rules from the `STEP_DEPENDENCIES` constant and checks whether each is satisfied.

```ruby
# app/services/onboarding/lock_evaluator.rb
module Onboarding
  class LockEvaluator
    def initialize(company)
      @company = company
    end

    # Check if a specific step is currently locked
    def locked?(step_key)
      deps = STEP_DEPENDENCIES[step_key.to_sym] || []
      deps.any? { |dep| !dependency_met?(dep) }
    end

    # Re-evaluate all steps (called after a step completes or sync progresses)
    def evaluate!
      # Lock status is derived from the constant + current state,
      # so there's nothing to persist. This provides a hook point
      # for future side effects like notifications when steps unlock.
    end

    private

    def dependency_met?(dep)
      case dep[:type]
      when :sync_complete
        SyncProgressService.new(@company).complete?(dep[:key])
      when :step_complete
        @company.completed_onboarding_steps.include?(dep[:key])
      else
        false
      end
    end
  end
end
```

### Controller

Thin controller — all logic is in the service:

```ruby
# app/controllers/api/v1/onboarding/steps_controller.rb
module Api
  module V1
    module Onboarding
      class StepsController < ApplicationController
        def update
          result = ::Onboarding::CompleteStep.new(
            current_company,
            params[:step_key],
            step_params
          ).call

          if result.success?
            render json: {
              step: { step_key: params[:step_key], status: 'completed' },
              next_step: result.next_step
            }
          else
            render json: { error: result.error_code, message: result.message },
                   status: :unprocessable_entity
          end
        end

        def skip
          config = ::Onboarding.find_step(params[:step_key])

          unless config&.fetch(:skippable, false)
            return render json: { error: 'not_skippable' }, status: :unprocessable_entity
          end

          result = ::Onboarding::CompleteStep.new(
            current_company,
            params[:step_key]
          ).call

          if result.success?
            render json: {
              step: { step_key: params[:step_key], status: 'skipped' },
              next_step: result.next_step
            }
          else
            render json: { error: result.error_code, message: result.message },
                   status: :unprocessable_entity
          end
        end

        private

        def step_params
          params.require(:data).permit!.to_h.deep_symbolize_keys
        end
      end
    end
  end
end
```
