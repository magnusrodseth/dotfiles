---
name: empirical-research
description: Appraise whether an empirical claim actually holds and by how much, against primary literature rather than search-result summaries. Runs a mandatory refutation pass, tiers every source, restates findings at the user's own parameters, and reports a claims table with reasoned confidence. Use when a question turns on whether something is true: does X actually work, is this benchmark meaningful, does this supplement/protocol/framework/product deliver its claimed effect, is this study any good, is this vendor claim real. NOT for API or library documentation (use find-docs). NOT for gathering uncontested facts into a repo note (use research). NOT for recalling what the user already wrote (use read-up-on).
---

# Empirical Research

Fires when **there is something here that could be false**. Documentation describes what a system does and there is no fact of the matter to be mistaken about. An empirical claim asserts the world behaves a certain way, so it can be wrong, overstated, contested, measured under conditions that are not the user's, or funded by whoever benefits.

## Tier

**Light** (default): steps 1-6.
**Deep** (the answer moves money, health, a public claim, or an irreversible decision): steps 1-6 plus every **Deep** addition marked below.

The refutation pass is mandatory in **both** tiers. It is one query and it is the highest-yield step here. A run that skips it is web search wearing a lab coat.

## Protocol

**1. Decompose.** Split the question into atomic claims that could individually be false. Not "should I take creatine" but "creatine increases strength in trained adults", "creatine causes kidney harm", "loading phases outperform steady dosing". Vague questions cannot be refuted, so they cannot be researched.

**2. Retrieve primary sources.** See [Retrieval](#retrieval). Web search **orients only**. It never sources a claim. Pull the actual abstract before asserting what a paper found.

**3. Tier every source** before leaning on it. See [Source tiers](#source-tiers).

**4. Refutation pass (mandatory).** Run at least one query built to *break* your current conclusion, not support it. If you believe X works, search for X failing, X null results, X criticism, X overstated. Record what you ran and what came back, including "nothing found."
> **Deep:** traverse the citation graph of your top source. Who cited it, and did they challenge it? This mechanically surfaces post-publication challenges, superseding work, and non-English literature that keyword search misses.

**5. Parameter transfer.** Write out the study's population, dose, duration and conditions, *then* compare to the user's. **The study's parameters are almost never the user's.** A study dosed 5 g and the user takes 3. A benchmark ran at 100 QPS and the user runs 10. A return series assumes 30 years and the user has 12. Trained subjects, untrained user.
Where the primary parameters allow it, **recompute at the user's numbers and show the working**. Where they do not, say the number may not transfer. Faithfully citing a figure measured under conditions that are not the user's is a correct-looking wrong answer, and it is more dangerous than an obvious error because every citation checks out.
> **Deep:** flag funding source and author affiliation per source. Vendor-funded trials of the vendor's own product are admissible but must be labelled.

**6. Report.** Claims table first, prose synthesis after. See [Output](#output).

> **Deep also:** search the user's other working languages when local practice, regulation or availability matters (Norwegian sources for Norwegian healthcare, consumer rights, or product availability). Check whether the top source has been superseded or retracted.

## Source tiers

| Tier | What |
|---|---|
| **T1** | Systematic review or meta-analysis of RCTs |
| **T2** | Individual RCT; peer-reviewed narrative review |
| **T3** | Observational, cohort, questionnaire, case series |
| **T4** | Mechanism, bench, in-vitro, expert opinion, guideline with no cited evidence |
| **T5** | Vendor material, marketing, content-marketing blog, press release |

**T5 may never support an efficacy claim.** It is admissible only for uncontested specification facts (a material's refractive index, a published API limit, a product's stated dimensions). Naming the tier in the output is what stops a marketing blog from hiding behind confident phrasing.

## Verdicts

Use exactly these. Split a claim into two rows rather than straddling two verdicts.

| Verdict | Means |
|---|---|
| **Demonstrated** | Outcome evidence, decent tier, at parameters near the user's |
| **Refuted** | Outcome evidence against |
| **Mechanism-plausible, outcome-untested** | The physics or biology checks out; nobody has shown it changes what the user cares about |
| **Contested** | Real evidence both directions; state which is higher tier |
| **No evidence found** | Searched and found nothing. Not the same as refuted |

**Never upgrade a verdict because the mechanism is satisfying.** A clean causal story is a reason to go looking for outcome evidence, not a substitute for finding it. Most product marketing lives in *mechanism-plausible, outcome-untested*, and collapsing that into *demonstrated* is this skill's central failure mode.

## Output

Mandatory table, then prose. The columns exist so that a skipped step leaves a visible hole.

| Claim | Verdict | Best source (tier) | Refutation attempt | Confidence + why |
|---|---|---|---|---|

- **Verdict** is stated at the user's parameters, never the study's. "Supported, but small at the user's dose" beats "Supported".
- **Refutation attempt** records the query run and the result, including "nothing found".
- **Confidence** states its reasoning, never a bare word. "High: T1 meta-analysis, effect direction consistent across 17 trials" or "Low: single T3 questionnaire, vendor-funded, parameters far from the user's".

Fabricating these cells is a bigger lie than vague prose, and each is checkable with one command.

**Destination:** report inline. Offer to persist afterwards. When already working in a notes vault or a repo with a research convention, follow that convention rather than dumping a raw report, and let the offer default toward yes.

## Retrieval

Free, no API key, `curl` and `jq` only. Prefer these over web search for anything with a DOI.

```bash
# Abstract, open-access status, retraction flag, citation count
curl -s "https://api.openalex.org/works/doi:$DOI" | jq '{title,oa:.open_access.oa_url,retracted:.is_retracted,cited:.cited_by_count}'

# Full abstract (works when the publisher blocks direct fetch)
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=DOI:%22$DOI%22&format=json&resultType=core" | jq -r '.resultList.result[0].abstractText'

# Search by topic
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=$Q&fields=title,abstract,year,venue,citationCount,externalIds&limit=10" | jq '.data[]'

# Who cited this, i.e. who challenged it  (step 4, Deep)
curl -s "https://api.semanticscholar.org/graph/v1/paper/DOI:$DOI/citations?fields=title,year,venue&limit=20" | jq -r '.data[] | "\(.citingPaper.year)  \(.citingPaper.title)"'
```

**Fallback chain, in order:** the APIs above → `WebSearch` (orientation only) → `WebFetch` → the **playwriter** skill for anything returning 403 or sitting behind Cloudflare.

**A paywall never ends the attempt.** Walk the chain. If full text stays unreachable, use the abstract and say the full text was not read, rather than quietly citing a paper you only saw summarised.

## Worked example

For an end-to-end run showing decomposition, a refutation pass that overturned a confident claim, and a recomputation that changed the recommendation, see [references/worked-example.md](references/worked-example.md).
