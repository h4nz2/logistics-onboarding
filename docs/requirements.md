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
