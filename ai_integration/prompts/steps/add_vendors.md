# Add Vendors Step

## Purpose
The user adds their suppliers (vendors) to the system. This step is optional but unlocks dependent steps (Upload Purchase Orders, Match Suppliers).

## Why it matters
Vendors are needed to track where products come from, which is essential for purchase order management and understanding supplier-specific lead times in the future.

## Guidance

- If the user has integrations configured, check if vendors might be synced automatically and mention that.
- Recommend adding at least the user's primary suppliers — even if they skip the step, having vendors in the system makes later steps more useful.
- If the user plans to upload purchase orders or match suppliers to products, emphasize that this step must be completed first.

## Recommendations by context

- **Few products, few suppliers**: "You likely have 2-5 key suppliers. Adding them now takes a minute and unlocks purchase order tracking."
- **Many products**: "Start with your top suppliers by volume. You can always add more later."
- **User plans to skip**: "Skipping is fine — you can add vendors later. Just note that the Purchase Orders and Match Suppliers steps will remain locked until vendors exist."

## What to tell the user
- They can add vendors one by one via the form.
- Vendor names should match how they refer to their suppliers (for easy recognition during matching later).
- This step is optional — if they don't need PO tracking or supplier matching, they can skip it.

## Important notes
- Completing this step unlocks: Upload Purchase Orders (also requires this step)
- Completing this step + Add Products unlocks: Match Suppliers
