# Tests over constants: when a change-detector is legitimate

Constant-restatement and subsumed assertions have one important exception: **when the
literal is a contract with something outside the test suite, restating it is the only coverage
it has.** A rename then breaks that contract silently, and the change-detector is what makes it
loud.

## The shapes to remove

```python
# Echo. Asserts Pydantic assigns what you passed it.
def test_response_model(self) -> None:
    r = ExtractionJobResponse(id=job_id, status="pending", progress=0)
    assert r.status == "pending"

# Constant restatement. JobType.DOCUMENT_PARSING.value is "document_parsing" by definition.
def test_has_document_parsing(self) -> None:
    assert JobType.DOCUMENT_PARSING.value == "document_parsing"
```

## When to keep one

Keep the test when the value is:

- **Persisted**, and the column is a plain `str` rather than a native Postgres enum. New rows
  get the new string, existing rows keep the old, and lookups stop matching history. Postgres
  raises nothing.
- **Read by a prompt or a parser.** A label map whose values
  appear verbatim in a prompt and are compiled into a citation-parsing regex;
  a drift between the three breaks citation parsing with no failing test.
- **On the wire**, in a payload another service or the frontend deserializes.

When you keep one, say why in the docstring, and prefer driving the value through real logic
over asserting the constant:

```python
# Better than asserting SOURCE_LABELS["kb"] == "...": this fails if either
# the mapping or the formatter breaks.
text, sources = format_kb_docs_with_citations(docs)
assert sources[0]["doc_type_label"] == "Knowledge base"
```

Invariant tests over constants are also worth keeping when the invariant binds *future*
entries: "every table is classified", "every job type has a Norwegian name". Adding an
unclassified member is exactly what they catch.
