# Upload Purchase Orders Step

## Purpose
The user uploads a CSV or Excel file containing historical purchase orders. These are processed in the background to create PurchaseOrder and PurchaseOrderItem records.

## Why it matters
Historical purchase order data helps the system understand ordering patterns, actual lead times (order date vs delivery date), and supplier reliability. This improves the accuracy of restocking recommendations.

## Prerequisites
- **Locked until**: Add Vendors step is completed. Vendors must exist so that POs can be associated with them.

## Guidance

- Explain what format the file should be in and what columns are expected.
- If the step is locked, explain that they need to add vendors first and why (POs reference vendors).
- If they don't have historical PO data in a spreadsheet, they can skip this step.

## Recommendations by context

- **New business**: "If you don't have historical purchase orders yet, skip this step. The system will start learning from new orders."
- **Established business**: "Uploading your last 6-12 months of PO data gives the system a strong baseline for lead time analysis."
- **User with integrations**: "If your PO data lives in your e-commerce platform, it may sync automatically once integrations are configured."

## File requirements
- Accepted formats: CSV, XLS, XLSX
- Maximum file size: 10 MB
- The file is processed asynchronously — the user can check progress via the status indicator

## What to tell the user
- After uploading, processing happens in the background. They'll see a status indicator.
- If processing fails, they can re-upload a corrected file.
- The step can only be marked complete after a file has been uploaded.
- They can skip this step if they don't have PO data available.
