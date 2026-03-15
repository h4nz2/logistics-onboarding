Company - the core model representing the ecommerce platform.
Integration - represents third party integrations of the company. The one to many relationshiip assumes that each company assumes that company cannot integrate more than ones with the provider. The configuration is json to allow us to store any format needed, as different intergations might need to store different kinds of data. As I don't presume there would be any filtering or sorting based on this attribute, it should be fine to simply store it as json attribute.
Warehouse - not further specified in the UI, so I just left it with simple name and association to company.
Purchase order - assuming this acts more or less as an invoice with several products on it. For our purposes, the date of the order seemed the only important attribute, as by comparing it to the deliver date, it would help us understand how long it usually takes for a product to be devivered after being ordered.
PurchaseOrderItem - tells us how many products were ordered and when they are expected to be delivered.
Bundle - my understanding is that bundle consists of multiple products that are being sold as one.
Product - represents the actual items being sold. I added many to many relationship to vendors, as I can imagine that it might be possible that some products can be ordered from multiple vendors. When starting, I would also consider starting with a simple one to many relationship and switch to many to many later.
SalesHistory - used to track quantity of products sold, useful for predicting when the item will need to be restocked again.
Vendor - my understanding is that vendor is meant as a supplier who can supply specific products.

Notes:

- I only added minimum attributes needed to satisfy the requirements, I assume that in real life there would be many more
- For each model, I would also add created_at and updated_at timestamps, as they are useful in many ways and do not cost much to store.
