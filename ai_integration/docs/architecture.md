# AI Onboarding Guide — Architecture

## Overview

The Smart Onboarding Guide is an AI-powered assistant that provides step-specific, contextual guidance during onboarding. It uses a layered context strategy to keep LLM prompts focused and token-efficient.

## Directory structure

```
ai_integration/
├── prompts/                    # Files sent to the LLM at runtime
│   ├── system.md               # System prompt (always loaded)
│   └── steps/                  # Step-specific context (one loaded per step)
│       ├── welcome.md
│       ├── lead_time.md
│       ├── stock_days.md
│       ├── forecasting_period.md
│       ├── add_vendors.md
│       ├── add_products.md
│       ├── upload_pos.md
│       ├── match_suppliers.md
│       ├── bundles.md
│       └── set_integrations.md
└── docs/                       # Developer documentation (never sent to the LLM)
    ├── architecture.md         # This file
    └── company_context.md      # Company context template spec
```

## Context layers

The final prompt sent to the LLM is assembled from four layers:

```
┌─────────────────────────────────────────────┐
│  Layer 1: System Prompt (prompts/system.md)  │  Always loaded
│  - Role, behavior rules, tone               │
├─────────────────────────────────────────────┤
│  Layer 2: Company Context (dynamic)          │  Always loaded, rebuilt per step
│  - Company profile + scale indicators       │  (see docs/company_context.md)
│  - Onboarding progress snapshot             │
│  - File upload statuses, integration state  │
├─────────────────────────────────────────────┤
│  Layer 3: Step Context (prompts/steps/*.md)  │  Only ONE loaded per step
│  - Step purpose and rationale               │
│  - Industry-specific recommendations        │
│  - Clarifying questions to ask              │
│  - Prerequisites and dependencies           │
├─────────────────────────────────────────────┤
│  Layer 4: Conversation History               │  Managed by the LLM runtime
│  - User's questions and agent responses     │
│  - Clarifying answers the user provided     │
└─────────────────────────────────────────────┘
```

### How prompt assembly works

The backend assembles the prompt by:

1. Reading `prompts/system.md`
2. Replacing `{{company_context}}` with the dynamic company context (see `docs/company_context.md`)
3. Replacing `{{step_context}}` with the contents of the appropriate `prompts/steps/<step_name>.md`
4. Sending the assembled prompt as the system message, along with the conversation history

### Step-to-file mapping

| Step name            | File to load                          |
| -------------------- | ------------------------------------- |
| `welcome`            | `prompts/steps/welcome.md`            |
| `lead_time`          | `prompts/steps/lead_time.md`          |
| `stock_days`         | `prompts/steps/stock_days.md`         |
| `forecasting_period` | `prompts/steps/forecasting_period.md` |
| `add_vendors`        | `prompts/steps/add_vendors.md`        |
| `add_products`       | `prompts/steps/add_products.md`       |
| `upload_pos`         | `prompts/steps/upload_pos.md`         |
| `match_suppliers`    | `prompts/steps/match_suppliers.md`    |
| `bundles`            | `prompts/steps/bundles.md`            |
| `set_integrations`   | `prompts/steps/set_integrations.md`   |

## Key design decisions

### One step context at a time

Loading all 10 step descriptions at once would waste ~3,000 tokens and confuse the model with irrelevant guidance. Since the frontend knows which step the user is on, the backend loads only the matching step file. When the user moves to a new step, the conversation resets with the new step context.

### Counts over lists

The company context uses aggregate counts (`product_count: 150`) rather than listing all 150 products. This keeps the context small and is sufficient for the kind of recommendations the agent makes. If the agent ever needs specific names, tool use can fetch them on demand. This is a good starting point, as next step I would consider summarizing the data to provider better context for the LLM other than just count of records.

### Static domain knowledge in step files

Industry benchmarks and recommendation ranges (e.g. "fashion: 21-30 day lead times") are authored in the step files rather than relying on the LLM's training data. Benefits:

- We control the recommendations
- They can be updated without retraining
- They're auditable and reviewable by domain experts

### Conversation per step, not per session

Each step gets a fresh conversation context. The user's answers from previous steps are reflected in the company context (e.g. `lead_days: 7`), so the agent can reference them without needing the old conversation history. This avoids context window bloat across a 10-step flow.

## Token budget estimate

| Layer                    | Estimated tokens |
| ------------------------ | ---------------- |
| System prompt            | ~400             |
| Company context          | ~300             |
| Step context (largest)   | ~400             |
| **Total system context** | **~1,100**       |

This leaves the vast majority of the context window for conversation.

## Possible extensions

### Tool use for on-demand data

If the agent needs to look up specific products, vendors, or PO details, it could be given tools like:

- `list_products(limit, offset)` — paginated product list
- `list_vendors()` — vendor list with product counts
- `get_upload_status(step)` — check file processing status
