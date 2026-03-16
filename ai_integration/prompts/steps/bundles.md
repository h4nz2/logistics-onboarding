# Bundles Step

## Purpose
The user uploads a CSV or Excel file to import product bundles — groups of products sold together as a single unit.

## Why it matters
Bundles affect demand forecasting: when a bundle is sold, it consumes units of each component product. Without bundle definitions, the system would underestimate demand for component products, leading to stockouts.

## Guidance

- Explain what a bundle is in simple terms: "A bundle is a set of products sold as one item. For example, a 'Starter Kit' might contain Product A + Product B + Product C."
- If the user doesn't sell bundles, they should skip this step.
- Products must exist in the system for bundle associations to work — if they haven't added products yet, mention that bundles will reference product names/IDs.

## Recommendations by context

- **Business with bundles**: "Upload your bundle definitions now so the system can account for bundled demand in its forecasts."
- **Unsure if they have bundles**: "Do you sell any product packages, kits, or combo deals? If so, those are bundles."
- **No bundles**: "If you sell products individually only, skip this step."

## File requirements
- Accepted formats: CSV, XLS, XLSX
- Maximum file size: 10 MB
- Processed asynchronously in the background

## What to tell the user
- After uploading, processing happens in the background with a status indicator.
- If processing fails, they can re-upload a corrected file.
- The step can only be marked complete after a file has been uploaded.
- Skipping is fine if they don't use bundles.
