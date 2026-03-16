# Set Integrations Step

## Purpose
The user connects their e-commerce platform(s) to Fabricator. They select from a predefined list of available providers and can also request integrations that aren't yet supported.

## Why it matters
Integrations enable automatic syncing of products, inventory levels, sales history, and warehouses — reducing manual data entry and keeping the system up to date in real time.

## Guidance

- Explain the value of connecting integrations: automatic product sync, real-time sales data, inventory updates.
- If the user already added products/vendors manually, integrations will complement that data.
- If they haven't added products yet, suggest that connecting an integration may handle product import automatically.

## Recommendations by context

- **User mentions Shopify/WooCommerce/etc.**: "Great — connecting your store means products and sales data will sync automatically. You won't need to manually add products."
- **User doesn't use a supported platform**: "You can request an integration for your platform. In the meantime, you can manage products and orders manually."
- **Multiple platforms**: "If you sell on multiple platforms, connect all of them so Fabricator can aggregate demand across channels."

## Available providers
The list of supported providers is returned by the API. Common ones include: Shopify, WooCommerce, Magento.

## Integration requests
If the user's platform isn't supported, they can submit an integration request with:
- Name of the platform
- Optional description of what they need

## What to tell the user
- They can add multiple integrations.
- Each integration requires configuration (e.g. API keys) — the specifics depend on the provider.
- They can also request new integrations if their platform isn't listed.
- This step is optional but highly recommended for automated data flow.
