# Company Context — Template Specification

This document defines the structure of the `{{company_context}}` placeholder that gets injected into the system prompt. The backend builds this from the database when assembling the prompt.

## Template

```yaml
company:
  name: "Acme Corp"
  industry: "fashion"          # e.g. fashion, electronics, food, beauty, home_goods, sports, general
  size: "mid_market"           # small (1-10 employees), mid_market (11-100), enterprise (100+)
  location: "DE"               # ISO 3166-1 alpha-2 country code
  subscription_tier: "growth"  # e.g. free, starter, growth, enterprise
  created_at: "2026-02-10"    # account age — helps gauge onboarding urgency
  locale: "en"                 # ISO 639-1 language code — determines initial response language
  lead_days: 7                 # null if not yet set
  stock_days: 30               # null if not yet set
  forecasting_days: 90         # null if not yet set

products:
  total_count: 150
  categories:                  # top categories by product count (max 5)
    - name: "Dresses"
      count: 45
    - name: "Accessories"
      count: 38
    - name: "Shoes"
      count: 30
  price_range:
    min: 12.00
    max: 350.00
    avg: 85.50
  products_with_lead_time: 60  # how many products have a per-product lead_time set
  avg_product_lead_time: 18    # average across products that have lead_time set; null if none

vendors:
  total_count: 8
  countries:                   # distinct supplier countries
    - "DE"
    - "CN"
    - "IT"
  avg_lead_time: 21            # average of vendors.avg_lead_time; null if not set
  avg_reliability_score: 0.87  # average of vendors.reliability_score (0-1); null if not set

warehouses:
  total_count: 3
  types:                       # distinct warehouse types present
    - "owned"
    - "3pl"
  total_capacity: 15000        # sum of warehouses.capacity; null if capacity not tracked

sales:
  has_history: true             # whether any sales_history records exist
  days_of_history: 120          # span from earliest to latest sales_history.date; 0 if none
  avg_daily_revenue: 4200.00    # null if no history
  top_products_by_revenue:      # top 3 products by total revenue (max 3, omit if no history)
    - name: "Summer Dress"
      revenue: 52000.00
    - name: "Leather Belt"
      revenue: 31000.00
    - name: "Canvas Sneaker"
      revenue: 28500.00

bundles:
  total_count: 12

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
| `company.name` | `companies.name` |
| `company.industry` | `companies.industry` |
| `company.size` | `companies.size` |
| `company.location` | `companies.location` |
| `company.subscription_tier` | `companies.subscription_tier` |
| `company.created_at` | `companies.created_at` |
| `company.locale` | `companies.locale` (or derived from user's browser/account settings) |
| `company.lead_days` | `companies.lead_days` |
| `company.stock_days` | `companies.stock_days` |
| `company.forecasting_days` | `companies.forecasting_days` |
| `products.total_count` | `COUNT(*) FROM products` |
| `products.categories` | `GROUP BY category ORDER BY count DESC LIMIT 5` |
| `products.price_range` | `MIN/MAX/AVG(price) FROM products` |
| `products.products_with_lead_time` | `COUNT(*) FROM products WHERE lead_time IS NOT NULL` |
| `products.avg_product_lead_time` | `AVG(lead_time) FROM products WHERE lead_time IS NOT NULL` |
| `vendors.total_count` | `COUNT(*) FROM vendors` |
| `vendors.countries` | `DISTINCT(country) FROM vendors` |
| `vendors.avg_lead_time` | `AVG(avg_lead_time) FROM vendors` |
| `vendors.avg_reliability_score` | `AVG(reliability_score) FROM vendors` |
| `warehouses.total_count` | `COUNT(*) FROM warehouses` |
| `warehouses.types` | `DISTINCT(type) FROM warehouses` |
| `warehouses.total_capacity` | `SUM(capacity) FROM warehouses` |
| `sales.has_history` | `EXISTS(SELECT 1 FROM sales_history)` |
| `sales.days_of_history` | `MAX(date) - MIN(date) FROM sales_history` |
| `sales.avg_daily_revenue` | `SUM(revenue) / COUNT(DISTINCT date) FROM sales_history` |
| `sales.top_products_by_revenue` | `SUM(revenue) GROUP BY product_id ORDER BY revenue DESC LIMIT 3` |
| `bundles.total_count` | `COUNT(*) FROM bundles` |
| `onboarding.*` | `onboarding_steps` table + `Company::ONBOARDING_STEP_CONFIG` |
| `file_uploads.*` | `onboarding_file_uploads` table |
| `integrations.*` | `integrations` table + `Integration::PROVIDERS` |
| `vendor_product_assignments.*` | `products_vendors` join table |

## Design rationale

### Company profile fields

- **Industry** — Directly drives step recommendations. The step prompts contain industry-specific benchmarks (e.g. "fashion: 21-30 day lead times", "food/perishables: 1-7 days"). Without this field, the LLM must ask "What industry are you in?" on nearly every step.
- **Size** — Influences complexity recommendations. A small company with 20 SKUs doesn't need the same vendor diversification or bundle strategy as an enterprise with 5,000.
- **Location** — Affects supplier logistics assumptions. A company in Germany with European suppliers has very different lead time expectations than one in the US importing from Asia.
- **Subscription tier** — Lets the LLM tailor recommendations to available features. An enterprise tier user can be pointed toward advanced integrations; a free-tier user shouldn't be guided toward features they can't access.
- **Created at** — Signals how long the user has been on the platform. A month-old account still in onboarding may need a nudge; a brand-new account is expected. Also helps distinguish genuinely new companies (zero data is expected) from established ones that haven't imported data yet.
- **Locale** — ISO 639-1 language code that determines the LLM's initial response language. The system prompt instructs the LLM to respond in the user's language while keeping domain terminology consistent. Falls back to `"en"` if not set.

### Summaries over raw data

Each data source is summarized into a few high-signal fields rather than included in full. This keeps the context within ~400-500 tokens while giving the LLM enough to make informed recommendations:

- **Product categories + price range** instead of full product list — tells the LLM what kind of business this is (high-value fashion vs low-cost accessories) without listing 150 items.
- **Vendor countries + avg lead time** instead of full vendor list — lets the LLM infer supplier geography and logistics without per-vendor detail. A vendor list showing `["CN", "IT"]` immediately tells the LLM to suggest longer lead times than `["DE", "AT"]`.
- **Warehouse types + total capacity** instead of full warehouse list — "owned" vs "3pl" changes fulfillment recommendations; total capacity helps gauge scale.
- **Sales history summary** instead of raw records — `days_of_history` directly informs the forecasting_days recommendation (can't forecast from 90 days of history if you only have 30 days of data). Top products by revenue help the LLM prioritize advice.
- **Avg reliability score** — if vendors are unreliable (low score), the LLM can suggest higher safety stock.

### What this enables per step

| Step | Key context fields used |
|------|------------------------|
| `lead_time` | `vendors.countries`, `vendors.avg_lead_time`, `products.avg_product_lead_time`, `company.industry` |
| `stock_days` | `vendors.avg_reliability_score`, `sales.avg_daily_revenue`, `company.industry` |
| `forecasting_period` | `sales.days_of_history`, `sales.has_history`, `products.categories` |
| `add_vendors` | `vendors.total_count`, `vendors.countries`, `products.total_count` |
| `add_products` | `products.total_count`, `products.categories`, `products.price_range` |
| `upload_pos` | `vendors.total_count`, `products.total_count`, `sales.has_history` |
| `match_suppliers` | `vendor_product_assignments.*`, `vendors.total_count`, `products.total_count` |
| `bundles` | `bundles.total_count`, `products.categories` |
| `set_integrations` | `integrations.*`, `company.subscription_tier`, `company.location` |

## Format

YAML is shown here for readability. The actual injection format should match what works best for the chosen LLM. YAML tends to use fewer tokens than JSON.

## What NOT to include

- **Full product/vendor/warehouse lists** — too large; use summaries and counts. Tool calls can fetch specifics if needed.
- **Raw sales history records** — summarized into `days_of_history`, `avg_daily_revenue`, and top products. The LLM doesn't need individual transactions.
- **File contents** — processed in background; the agent doesn't need to see uploaded files.
- **Internal database IDs** — the agent doesn't need primary keys.
- **Sensitive fields** — API keys, passwords, or integration credentials must never appear in the context.

## When to rebuild

Rebuild the company context:
- When the user opens the onboarding page
- When the user navigates to a different step (step completion may have changed state)
- After a file upload finishes processing (status changes)
- After a data sync completes (product/vendor/warehouse counts and summaries may have changed)
