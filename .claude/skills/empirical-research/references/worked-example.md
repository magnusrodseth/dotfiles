# Worked example

One end-to-end run, kept for the shape of the process. The domain is incidental. What transfers is the decomposition, the refutation pass, and the recomputation.

**Question as asked:** "I wear -3.50 contacts daily and screen glasses with about +0.5 and a blue filter over them. What should I actually be wearing?"

## 1. Decompose

The question as posed cannot be refuted. Split into claims that can:

1. A contact lens prescription and a spectacle prescription for the same eye are the same number.
2. Correcting myopia with contacts raises accommodative demand at near versus spectacles.
3. Blue-light filtering lenses reduce digital eye strain.
4. A low plus add reduces digital eye strain in non-presbyopes.
5. Contact lens wear worsens screen-related dry eye.

## 2. Retrieve

Publisher returned **403** to direct fetch on the key review. Europe PMC returned the complete abstract by DOI in one call. The paywall was an obstacle, not an ending.

## 3. Refutation pass, and what it caught

The conclusion forming was "blue filters do nothing, the Cochrane review settles it." The refutation query was the citation graph of that review: *who cited this, and did they disagree?*

It surfaced a 2025 questionnaire study reporting symptom improvement from long-term blue-filter use, and a Dutch-language paper. Neither overturned the T1 review, since a T3 questionnaire does not outweigh 17 RCTs. **But the first version of the answer never knew they existed**, and a confident claim that has not met its strongest opposition is not yet a finding.

Second catch: the same query surfaced non-English literature that keyword search in English had entirely missed.

## 4. Parameter transfer, which changed the answer

The literature's canonical worked example for claim 2 uses **-5.00 D**, where the effect is roughly 0.4 D. The user is **-3.50 D**.

Recomputing from vergence relations at the user's actual correction and vertex distance gave **~0.20 D at monitor distance** and **~0.34 D at reading distance**, then cross-checked by reproducing the literature's own -5.00 D figure with the same method.

That is under one 0.25 D step. **It removed the justification for the +0.5 add the user was already wearing.**

Reporting the literature's 0.4 D would have been a faithful citation of a real number and the wrong recommendation. Every source would have checked out.

## 5. The table it produced

| Claim | Verdict | Best source (tier) | Refutation attempt | Confidence + why |
|---|---|---|---|---|
| Spectacle and contact Rx are the same number | Refuted | Vertex relation, standard optics (T4 mechanism, uncontested) | Checked whether the difference is clinically ignorable below ±4.00 D: it is usually treated so, user sits at the boundary | High: deterministic calculation, not an empirical effect |
| Contacts raise near accommodative demand | Demonstrated, but ~0.20 D at this user's -3.50, not the 0.4 D of the literature's -5.00 D example | Ocular motor triad study (T2) | Searched for a contrary mechanism; none found | High for direction, high for magnitude since recomputed at the user's own parameters |
| Blue filters reduce eye strain | Refuted | Cochrane 2023, 17 RCTs (T1) | Citation graph: found a 2025 T3 questionnaire claiming benefit. Lower tier, does not overturn | High: T1 systematic review, and its strongest challenger is three tiers below it |
| Low plus add helps non-presbyopes | Contested, leaning no | 6-month RCT: no difference vs single vision (T2). CLEDA: subjective preference (T2) | Both directions actively sought and both reported | Medium: real evidence both ways; preference is real, measured benefit over single vision is not |
| Contacts worsen screen dry eye | Demonstrated in general, weakened for this user | Review of contact lens and digital eye strain (T2) | Checked the specific lens worn: engineered for this exact problem, vendor trial in 8+ h/day screen users | Medium: direction well supported, magnitude uncertain, and the mitigating trial is vendor-run (T2 with COI) |

## 6. What the run got right, and where it nearly failed

**Right:** recomputing rather than citing; reporting the disconfirming RCT alongside the supporting one; downgrading confidence when the mitigating trial turned out to be manufacturer-funded; revising a stated conclusion when later facts weakened it.

**Nearly failed:** the first pass searched only for mechanisms already believed in. Every query was built to confirm. The refutation pass was added afterwards and immediately found something the confirming queries never would have. That is why it is mandatory rather than optional.
