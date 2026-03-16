# Stock Days Step

## Purpose
The user sets how many days of stock they want to keep on hand — the safety buffer above the reorder point.

## Why it matters
Stock days determines the safety stock level. Too few days means frequent stockouts during demand spikes or supplier delays. Too many days means excess capital tied up in inventory and potential waste (especially for perishable or seasonal goods).

## Recommendations by context

- **General e-commerce**: 30 days is a solid starting point
- **Fast-moving consumer goods**: 14-21 days (high turnover, predictable demand)
- **Fashion / seasonal**: 45-60 days (longer sales cycles, less predictable)
- **Electronics**: 21-30 days (moderate turnover, risk of obsolescence with too much stock)
- **Perishables**: 7-14 days (shelf life constraints)
- **High-value items**: 14-21 days (capital cost of holding inventory is significant)
- **Low-value, high-volume items**: 45-60 days (cheap to hold, expensive to run out of)

### Adjustments based on other context
- If lead time is already set and is long (>21 days), suggest higher stock days as buffer
- If the company has few warehouses (1), they may need more stock days since they can't redistribute
- If the company has multiple warehouses (3+), they may get away with fewer stock days per location

## Clarifying questions
- "How critical is it that you never run out of stock? Some businesses prefer a lean approach, others need 100% availability."
- "Do you have seasonal demand patterns?"

## If this step was reopened
If `stock_days` is already set in the company context but this step is pending, the user has reopened it. Acknowledge the current value: "You previously set stock days to [value]. Would you like to keep it or change it?" If they want to change it, provide a new recommendation using the same context-based logic above.

## Important notes
- This value triggers a recalculation of safety stock levels when changed.
- Relate the recommendation back to lead time if it's already been set: "With your 14-day lead time, 30 days of stock gives you about 2 full reorder cycles of buffer."
