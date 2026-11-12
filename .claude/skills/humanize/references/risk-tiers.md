# Risk tiers

Classify changes by their effect on the text. Meaning preservation applies at every tier.
Use the user's requested scope and existing authorization before asking a question.

## Tier 1: mechanical changes

Apply when the intended correction is unambiguous and the content stays identical.

- Remove trailing whitespace and accidental duplicate spaces in editable prose.
- Normalize straight quotes or other typography according to the user's preferences.
  Preserve exact quotations, code, formulas and identifiers.
- Remove tracking parameters without changing the destination.
- Repair leaked formatting when the destination cannot render it.

Citation artifacts need more than deletion when they stand in for evidence. Restore a
real source only when supplied or verified; otherwise flag the missing reference.
Preserve intentional drafting placeholders and identify them as unfinished content.

Replacing an em dash, arrow or range can change logical attachment or notation. Treat
that as Tier 2 or Tier 3 unless the replacement is mechanically equivalent.
A formatting preference is not evidence that the author made an accidental choice.

## Tier 2: local edits that preserve meaning

Apply within the user's scope, then mention only material changes.

- Replace an ornamental word with a plain equivalent that preserves degree and meaning.
- Delete a filler opener or tail that adds no fact, qualification or logical relation.
- Restore a direct verb without inventing an actor or action.
- Recast an emphatic colon or split a sentence while preserving scope and attribution.
- Combine adjacent sentences about one action when the emphasis and relations survive.
- Remove duplicated words or an empty reply-shaped preamble.
- Use a consistent term when the text clearly uses synonyms for the same concept.
- Remove vague consensus framing only when the supplied source and its actual claim
  remain identifiable.

Keep legitimate technical meanings. "Robust" in statistics and "landscape" for a screen
orientation need no replacement. If the meaning is clear, leave them without asking.

"Weasel attribution" is not permission to turn "experts suggest X" into "X".
Preserve the attribution and uncertainty; flag the unidentified source separately.
Removing a number, distinct list item, uncertainty marker or causal link is never a
routine stylistic cut.

## Tier 3: changes affecting argument, structure or voice

Apply when already authorized and supported by the supplied material. Otherwise keep
the passage intact and ask about the material decision.

- Reorder evidence, delete substantial text, merge or split paragraphs when emphasis changes.
- Change audience, register, pronouns, a central analogy or a deliberate rhetorical device.
- Resolve an ambiguous comparison, negation, quantifier or reference.
- Change a claim's confidence, scope or implied causality.
- Add substantive context, a definition, an anecdote or a specific fact.

Authorization permits the requested edit, not fabrication. Use only facts, experiences
and opinions the author supplied, or verified material within an authorized research scope.
If the needed information is absent, identify the gap outside the rewritten prose.

Narrative conventions need genre judgment. Do not manufacture ambiguity in a resolved
essay, a contestable position in an explanation, or emotion in a formal memo.

## Asking

Ask a focused question when the unresolved decision would materially change meaning or
voice. Give a recommendation and concise alternatives. Use the available user-input tool;
there is no dependency on a tool named AskUserQuestion.

Batch related decisions and avoid repeated approval requests. A broad request to
restructure covers routine paragraph work. A narrow request to remove em dashes does not.
Complete safe, independent edits while a question is pending. Do not treat silence as
approval or insert placeholders into the author's prose.
