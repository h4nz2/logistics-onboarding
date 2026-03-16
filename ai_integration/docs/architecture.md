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
│       ├── set_integrations.md
│       └── fallback.md
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
│  - Company profile (industry, size, location)│  (see docs/company_context.md)
│  - Product, vendor, warehouse summaries     │
│  - Sales history summary                    │
│  - Onboarding progress snapshot             │
│  - File upload statuses, integration state  │
├─────────────────────────────────────────────┤
│  Layer 3: Step Context (prompts/steps/*.md)  │  Only ONE loaded per step
│  - Step purpose and rationale               │
│  - Industry-specific recommendations        │
│  - Clarifying questions to ask              │
│  - Prerequisites and dependencies           │
├─────────────────────────────────────────────┤
│  Layer 4: Conversation History               │  Managed by the backend runtime
│  - User's questions and agent responses     │  (see "Conversation management" below)
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

## Fallback handling

### Unknown step name

If `step_name` does not match any file in the step-to-file mapping, load `prompts/steps/fallback.md` instead. This prevents runtime errors and gives the user generic but helpful guidance. Log a warning so the mismatch can be investigated.

### Malformed or missing company context

If the company context cannot be built (e.g. database error, missing company record), substitute a minimal fallback:

```yaml
company:
  name: "Unknown"
  note: "Company context could not be loaded. Ask the user for details as needed."
```

The LLM will fall back to asking clarifying questions rather than making context-dependent recommendations. Log an error so the root cause can be fixed.

## Key design decisions

### One step context at a time

Loading all 10 step descriptions at once would waste ~3,000 tokens and confuse the model with irrelevant guidance. Since the frontend knows which step the user is on, the backend loads only the matching step file. When the user moves to a new step, the conversation resets with the new step context.

### Summaries over raw data

The company context uses aggregated summaries rather than raw lists. For example, products are represented as a total count, top categories with counts, and a price range — not a list of 150 items. Vendors are summarized by distinct countries, average lead time, and reliability score. Sales history is condensed to days of history, average daily revenue, and top 3 products by revenue. This keeps the context at ~500 tokens while giving the LLM enough signal to make informed, step-specific recommendations. If the agent ever needs specific records, tool use can fetch them on demand.

### Static domain knowledge in step files

Industry benchmarks and recommendation ranges (e.g. "fashion: 21-30 day lead times") are authored in the step files rather than relying on the LLM's training data. Benefits:

- We control the recommendations
- They can be updated without retraining
- They're auditable and reviewable by domain experts

### Structured response format

The system prompt defines a consistent output format with labeled fields (**Recommendation**, **Rationale**, **Next consideration**) rather than free-form prose. Different response types (recommendations, clarifying questions, locked step explanations, skip decisions) each have their own format guidance. A concrete example is included in the system prompt to anchor the LLM's behavior across model versions. Formatting is restricted to bold labels only — no headers, tables, or code blocks — to keep responses scannable in a chat-style UI.

### Conversation per step, not per session

Each step gets a fresh conversation context. The user's answers from previous steps are reflected in the company context (e.g. `lead_days: 7`), so the agent can reference them without needing the old conversation history. This avoids context window bloat across a 10-step flow.

## Token budget estimate

| Layer                    | Estimated tokens |
| ------------------------ | ---------------- |
| System prompt            | ~600             |
| Company context          | ~500             |
| Step context (largest)   | ~400             |
| **Total system context** | **~1,500**       |

This leaves the vast majority of the context window for conversation.

## Conversation management

Layer 4 (conversation history) requires active management by the backend runtime.

### Turn limits and summarization

Each step conversation is capped at **20 turns** (10 user messages + 10 assistant responses). When the conversation reaches 16 turns, the runtime should:

1. Summarize turns 1–12 into a single assistant message (~200 tokens)
2. Keep turns 13–16 verbatim (preserves recency)
3. Append the summary as the first message in the trimmed history

If the user still hasn't completed the step after 20 turns, the assistant should suggest they set a value and move on, offering to revisit later.

### Context window guard

Before each LLM call, the runtime must check total token count (system context + conversation history). If it exceeds **80% of the model's context window**:

1. Summarize the oldest half of conversation turns into a single message
2. Prepend the summary, keep recent turns verbatim
3. Log a warning — hitting this limit within a single step likely indicates the user is stuck or off-topic

### Conversation lifecycle

| Event                     | Action                                      |
| ------------------------- | ------------------------------------------- |
| User navigates to step    | Start fresh conversation with system prompt |
| User completes step       | Discard conversation, persist values to DB  |
| User navigates away       | Discard conversation                        |
| User returns to same step | Start fresh conversation (values are in company context) |
| Browser refresh           | Start fresh conversation                    |

## Model compatibility

The prompts are designed to be model-agnostic. When switching LLM providers or model versions, verify the following:

### Context format

YAML is used for the company context. Some models parse YAML less reliably than others. If the model struggles with YAML (hallucinating keys, misreading indentation), switch to JSON. JSON costs ~20% more tokens but is universally well-handled. Test by providing a company context and asking the model to list the values it sees.

### Instruction adherence

Test that the model respects the structured response format (**Recommendation** / **Rationale** / **Next consideration**) and the brevity constraints. Weaker models tend to be verbose or drift into free-form prose. If this happens, reinforce with an explicit instruction at the end of the system prompt: "You must use the response format defined above. Do not exceed 3 sentences per field."

### Recommendation sourcing

Verify the model uses the industry ranges from the step files rather than inventing its own from training data. Test with a prompt like "What lead time should I set?" and confirm the answer cites ranges that appear in the step context, not generic values. If the model ignores step context in favor of its own knowledge, add: "Base your recommendations only on the ranges provided in the step context. Do not substitute your own benchmarks."

### Template delimiters

The `{{placeholder}}` syntax is model-neutral but ensure the assembly code does not conflict with any model's special token syntax (e.g. some models use `{{` for template literals). Validate that the replaced output contains no leftover template markers.

### Language quality

If the system is used with a non-English `locale` (see system prompt), verify that the model produces accurate recommendations in the target language. Instruction-following quality degrades in some languages — test the most common target locales before deploying.

## Possible extensions

### Tool use for on-demand data

If the agent needs to look up specific products, vendors, or PO details, it could be given tools like:

- `list_products(limit, offset)` — paginated product list
- `list_vendors()` — vendor list with product counts
- `get_upload_status(step)` — check file processing status
