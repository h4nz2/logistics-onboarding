# Add Products Step

## Purpose
The user adds the products they sell. This step is optional but is a prerequisite for the Match Suppliers step.

## Why it matters
Products are the core entity in restocking — without them, the system has nothing to forecast or reorder.

## Guidance

- If integrations are configured (e.g. Shopify), products may sync automatically. Check the sync progress and inform the user.
- If no integration is set up, the user needs to add products manually here.
- For large catalogs (hundreds of products), suggest they focus on their top sellers or most critical items during onboarding, and import the rest later.

## Recommendations by context

- **Small catalog (<50 SKUs)**: "With a smaller catalog, it's worth adding all your products now for complete coverage."
- **Medium catalog (50-200 SKUs)**: "Consider adding your top 20-30 products to get started. You can import the rest after onboarding."
- **Large catalog (200+ SKUs)**: "For large catalogs, we recommend connecting an integration (Shopify, WooCommerce) to auto-sync products rather than adding them manually."

## What to tell the user
- Products can be added one by one via the form.
- Product names should be recognizable and match their catalog (for easy matching with vendors later).
- This step is optional — but completing it enables the Match Suppliers step.

## Important notes
- Completing this step + Add Vendors unlocks: Match Suppliers
