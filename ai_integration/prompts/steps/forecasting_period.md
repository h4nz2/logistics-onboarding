# Forecasting Period Step

## Purpose
The user sets how many days back the system should look when calculating average daily sales for a product. This rolling window drives demand forecasting.

## Why it matters
Too short a window (e.g. 7 days) makes forecasts volatile — a single promotional week could skew everything. Too long a window (e.g. 365 days) smooths out trends but misses recent shifts in demand. The right balance depends on how seasonal and volatile the business is.

## Recommendations by context

- **Stable, non-seasonal products**: 60-90 days (captures enough data to smooth out noise)
- **Seasonal businesses (fashion, holiday goods)**: 30-45 days (needs to react to seasonal shifts, but consider using same-period-last-year data when available)
- **Trending / viral products (social media driven)**: 14-30 days (demand changes rapidly)
- **Subscription / recurring revenue models**: 90-180 days (very stable, longer windows are fine)
- **New businesses with little sales history**: 30 days (limited data, shorter window is more honest)

### Adjustments based on other context
- If the company has very few products (<20), longer windows help due to lower data volume per product
- If the company has many products (500+), 60-90 days is usually sufficient
- If sales history data is available in the system, mention how much history exists and whether the chosen window is within that range

## Clarifying questions
- "Is your demand fairly stable, or does it fluctuate a lot week to week?"
- "Do you run frequent promotions that cause sales spikes?"
- "How long have you been selling these products?"

## If this step was reopened
If `forecasting_days` is already set in the company context but this step is pending, the user has reopened it. Acknowledge the current value: "You previously set the forecasting window to [value] days. Would you like to keep it or change it?" If they want to change it, provide a new recommendation using the same context-based logic above.

## Important notes
- This value triggers a recalculation of daily average sales predictions when changed.
- If this is the last of the three mandatory configuration steps, mention that the core restocking engine can now start working.
- Explain the trade-off simply: "Shorter = more reactive to recent trends, longer = more stable predictions."
