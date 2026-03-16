# Requirements

Design backend API for a React frontend, that will allows the user to complete onboarding for his company.

Onboarding steps must satisfy the following:

- we can track which steps have been completed for a company
- we can track which steps have been skipped for a company
- order of steps is defined somewhere
- some steps can only be completed after a condition has been met (e.g. previous step completed or file processing of previous step completed)

## Onboarding steps

### 1. Welcome

Only contains welcome text with basic information.

### 2. Set your lead time

User sets the lead time in days. This step must be completed.

### 3. Set days of stock for products

User to sets the days of stock. This step must be completed.

### 4. Set forecasting days

Users sets wow far back (in days) should we look when calculating daily average sales of a product. This step must be completed.

### 5. Upload existing Purchas orders

User can upload excel or csv file with purchase orders. This step is optional. This step is unlocked only after Vendors have been added into the app.

### 6. Match suppliers and products

User can choose, which vendors can be used as suppliers. This step is optional.

### 7. Set bundles

User can upload an excel or csv file, which will be used to import bundles. This step is optional.

### 8. Set integrations

User can add and configure integrations. User selects from a predefined list. Additionaly, use can request a new integration.

# Models

## Company

The core model representing the ecommerce platform. Stores company-level configuration such as lead time, stock days, and forecasting days. The available onboarding steps are defined as constants on this model, while their completion status is tracked via the `OnboardingStep` model.

## OnboardingStep

Tracks the status of each onboarding step for a company. Uses integer enums for both the step identifier and its status (pending, completed, or skipped).

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

## IntegrationRequest

Allows users to request integrations that are not yet available in the predefined list. Stores the requested integration name and an optional description. Belongs to a company.

---

## Notes

- I only added minimum attributes needed to satisfy the requirements. I assume that in real life there would be many more.
- For each model, I would also add `created_at` and `updated_at` timestamps, as they are useful in many ways and do not cost much to store.

# REST API
