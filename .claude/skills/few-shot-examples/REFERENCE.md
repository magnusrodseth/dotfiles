# Few-Shot Reference Patterns

Copy-paste patterns for the common few-shot scenarios in AI and agentic applications. Each pattern pairs example design with the schema/config choices that reinforce it.

## 1. Null handling to reduce hallucination

The highest-leverage use of few-shot examples. Models invent values to fill gaps; explicit null-handling examples remove that incentive by showing that "missing in → null out" is the correct behavior.

```xml
<example>
  <input>Customer: John Smith, Email: null, Phone: +1-555-0123</input>
  <output>
    {
      "name": "John Smith",
      "email": null,
      "phone": "+15550123",
      "status": "partial_record"
    }
  </output>
</example>

<example>
  <input>Customer: , Email: , Phone: </input>
  <output>
    {
      "name": null,
      "email": null,
      "phone": null,
      "status": "empty_record"
    }
  </output>
</example>
```

Reinforce with a schema where fields are **required but nullable**, forcing the model to acknowledge missing data rather than omit it:

```json
{
  "type": "object",
  "properties": {
    "name":  {"type": "string"},
    "email": {"type": ["string", "null"]},
    "phone": {"type": ["string", "null"]}
  },
  "required": ["name", "email", "phone"]
}
```

## 2. Format normalization

Map several input formats to one canonical output to teach normalization rather than copying.

```xml
<example><input>Date: March 15th, 2024</input><output>2024-03-15</output></example>
<example><input>Date: 15/03/2024</input><output>2024-03-15</output></example>
<example><input>Date: 2024.03.15</input><output>2024-03-15</output></example>
```

## 3. Classification with an extensible (catch-all) enum

Prefer a small enum plus an `"other"` value and a detail field over enumerating every possible category. The catch-all degrades gracefully on novel inputs; the exhaustive enum breaks every time a new category appears (fragile-expansion anti-pattern).

```json
{
  "category": {
    "type": "string",
    "enum": ["billing", "technical", "account", "other"]
  },
  "category_detail": {
    "type": ["string", "null"],
    "description": "If category is 'other', a brief description"
  }
}
```

Show the `"other"` path in a few-shot example so the model uses it instead of forcing a bad fit:

```xml
<example>
  <input>I want to partner with you on a co-marketing campaign.</input>
  <output>{"category": "other", "category_detail": "business/partnership inquiry"}</output>
</example>
```

## 4. Schema redundancy for self-validation

Include both stated and calculated fields so downstream code can flag likely extraction errors.

```json
{
  "stated_total":     {"type": "number"},
  "calculated_total": {"type": "number", "description": "Sum of line items"},
  "totals_match":     {"type": "boolean"}
}
```

If `totals_match` is false, route the record for review rather than trusting it.

## 5. Reasoning + confidence fields for routing

Give the model a field to record *why* it answered as it did, plus a confidence score, to enable systematic analysis and human-in-the-loop routing.

```json
{
  "classification": "false_positive",
  "detected_pattern": "Comment references legacy behavior changed in commit abc123",
  "confidence": 0.85
}
```

Typical routing thresholds:

- `> 0.95` — auto-approve
- `0.80 – 0.95` — spot-check
- `< 0.80` — mandatory human review

## Design checklist

- [ ] Each example wrapped in `<example>` / `<input>` / `<output>`.
- [ ] At least one example covers missing/null/empty input.
- [ ] Input formats vary; output shape is fixed.
- [ ] Examples are representative (safe to imitate), not adversarial.
- [ ] 2–5 examples — common case plus the edge cases that matter.
- [ ] Paired with a JSON schema (nullable-but-required where data may be absent).
- [ ] Temperature 0 for structured/extraction/classification tasks.
- [ ] Validated against a labeled dataset, not assumed.
