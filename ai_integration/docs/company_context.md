# Company Context — Template Specification

This document defines the structure of the `{{company_context}}` placeholder that gets injected into the system prompt. The backend builds this from the database when assembling the prompt.

## Template

```yaml
company:
  name: "Acme Corp"
  lead_days: 7              # null if not yet set
  stock_days: 30            # null if not yet set
  forecasting_days: 90      # null if not yet set

scale:
  product_count: 150
  vendor_count: 8
  warehouse_count: 3
  bundle_count: 12

onboarding:
  current_step: "lead_time"
  completed_steps:
    - welcome
  skipped_steps: []
  pending_steps:
    - lead_time
    - stock_days
    - forecasting_period
    - add_vendors
    - add_products
    - upload_pos
    - match_suppliers
    - bundles
    - set_integrations
  locked_steps:
    - step: upload_pos
      reason: "Complete 'Add Vendors' to unlock"
    - step: match_suppliers
      reason: "Complete 'Add Vendors' and 'Add Products' to unlock"

file_uploads:
  - step: upload_pos
    processing_status: null    # null = no upload yet, or: pending, completed, failed
    error_message: null
  - step: bundles
    processing_status: null
    error_message: null

integrations:
  configured:
    - provider: "shopify"
  available_providers:
    - "woocommerce"
    - "magento"
  pending_requests:
    - name: "SAP"

vendor_product_assignments:
  total_products: 150
  products_with_vendors: 45   # relevant for match_suppliers step
```

## Data sources

| Field | Source |
|-------|--------|
| `company.*` | `companies` table |
| `scale.product_count` | `COUNT(*) FROM products WHERE company_id = ?` |
| `scale.vendor_count` | `COUNT(*) FROM vendors WHERE company_id = ?` |
| `scale.warehouse_count` | `COUNT(*) FROM warehouses WHERE company_id = ?` |
| `scale.bundle_count` | `COUNT(*) FROM bundles WHERE company_id = ?` |
| `onboarding.*` | `onboarding_steps` table + `Company::ONBOARDING_STEP_CONFIG` |
| `file_uploads.*` | `onboarding_file_uploads` table |
| `integrations.*` | `integrations` table + `Integration::PROVIDERS` |
| `vendor_product_assignments.*` | `products_vendors` join table |

## Format

YAML is shown here for readability. The actual injection format should match what works best for the chosen LLM. YAML tends to use fewer tokens than JSON.

## What NOT to include

- **Full product/vendor lists** — too large; use counts. Tool calls can fetch specifics if needed.
- **Sales history data** — not relevant during onboarding guidance.
- **File contents** — processed in background; the agent doesn't need to see uploaded files.
- **Internal database IDs** — the agent doesn't need primary keys.

## When to rebuild

Rebuild the company context:
- When the user opens the onboarding page
- When the user navigates to a different step (step completion may have changed state)
- After a file upload finishes processing (status changes)
