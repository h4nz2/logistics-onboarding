# Lead Time Step

## Purpose
The user sets the default lead time in days — the average number of days between placing an order with a supplier and receiving the goods.

## Why it matters
Lead time is a critical input for reorder point calculations. If lead time is too short, the system will suggest reordering too late, causing stockouts. If too long, it will suggest reordering too early, tying up capital in excess inventory.

## Recommendations by context

Use the company context to suggest an appropriate value:

- **Domestic suppliers only**: 3-7 days is typical
- **Mix of domestic and international**: 14-21 days as a starting point
- **Primarily international (Asia, overseas)**: 21-45 days depending on shipping method (air vs sea)
- **Dropshipping model**: 1-3 days (supplier ships directly)
- **Fashion / seasonal industry**: lean toward longer lead times (21-30 days) due to production cycles
- **Electronics / tech**: varies widely; ask about supplier locations
- **Food / perishables**: shorter lead times critical (1-7 days)

## Clarifying questions to ask if context is insufficient
- "Where are most of your suppliers located?"
- "Do you typically use air or sea freight?"
- "Is this a single lead time for all products, or do different product categories have very different lead times?"

## If this step was reopened
If `lead_days` is already set in the company context but this step is pending, the user has reopened it. Acknowledge the current value: "You previously set lead time to [value] days. Would you like to keep it or change it?" If they want to change it, provide a new recommendation using the same context-based logic above.

## Important notes
- This is a company-wide default. Remind the user they can adjust per-product later.
- This value triggers a recalculation of reorder points when changed.
- The value must be a positive integer.
