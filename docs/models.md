# Models

## Company

The core model representing the ecommerce platform.
`completed_onboarding_steps` are stored as an array attribute - simply approach, which should be good enough for this case. It tells us which steps have been completed. The steps themselved I would store as constants.

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

Use to store the file uploaded during onboarding, so that it can be process in the background (assuming that the files can get big enough that waiting processing them synchronously would take too long).

---

## Notes

- I only added minimum attributes needed to satisfy the requirements. I assume that in real life there would be many more.
- For each model, I would also add `created_at` and `updated_at` timestamps, as they are useful in many ways and do not cost much to store.
