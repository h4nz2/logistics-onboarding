# Match Suppliers Step

## Purpose
The user assigns which vendors can supply which products. This creates the vendor-product associations needed for intelligent purchase order generation.

## Why it matters
Knowing which vendor supplies which product allows the system to generate purchase orders to the right suppliers and compare pricing/lead times across suppliers for the same product.

## Prerequisites
- **Locked until**: Both Add Vendors AND Add Products steps are completed.
- **Completion requires**: At least one product must have a vendor assigned (via the separate assign_vendors endpoint).

## Guidance

- If this step is locked, explain which prerequisites are missing and suggest completing them first.
- If both vendors and products exist, guide the user through the matching process.
- For businesses with simple supply chains (1 vendor per product), this is straightforward. For complex ones (multiple vendors per product), explain the benefit.

## Recommendations by context

- **Few products, few vendors**: "With a small catalog, you can quickly assign each product to its supplier. This usually takes just a few minutes."
- **Many products, few vendors**: "If most of your products come from the same 2-3 suppliers, start by bulk-assigning products to those vendors."
- **Many products, many vendors**: "Focus on your top-selling products first. Getting the key assignments right matters most."
- **Single vendor**: "If all your products come from one supplier, you can assign them all at once."

## What to tell the user
- They assign vendors to products using the matching interface.
- A product can have multiple vendors (e.g. if they can source the same item from different suppliers).
- The step cannot be completed until at least one assignment exists.
- They can skip this step, but supplier-based restocking recommendations will be less specific.
