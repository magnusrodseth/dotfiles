# Sources and evidence limits

These criteria combine design arguments, practitioner guidance, and bounded empirical findings. They are an editorial synthesis, not a validated quality score. The source selection used public articles, excerpts, and reference material; it does not claim a complete reading of the listed books.

## Main foundations

| Source | Contribution |
| --- | --- |
| Parnas, [On the Criteria To Be Used in Decomposing Systems into Modules](https://john.cs.olemiss.edu/~hcc/csci555/notes/localcopy/Parnas_Criteria_Decomposing.pdf) | Information hiding and decomposition judged against changes. A worked design argument. |
| Ousterhout, [A Philosophy of Software Design](https://web.stanford.edu/~ouster/cgi-bin/book.php) | Complexity, deep modules, caller knowledge, and design documentation. Practitioner and teaching experience. |
| Fowler, [Refactoring](https://martinfowler.com/books/refactoring.html) and [Code Smell](https://martinfowler.com/bliki/CodeSmell.html) | Small transformations that preserve behavior; smells prompt investigation rather than automatic remedies. |
| Feathers, [Working Effectively with Legacy Code: Seams](https://www.informit.com/articles/article.aspx?p=359417&seqNum=2) | Altering behavior at seams to control dependencies and make existing code testable. |
| Evans, [DDD Reference](https://www.domainlanguage.com/ddd/reference/) | Domain language, context boundaries, consistency, and translation between models. |
| Thomas and Hunt, [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/) | Orthogonality, duplicated knowledge, contracts, reversibility, and feedback. |
| Google, [What to Look for in a Code Review](https://google.github.io/eng-practices/review/reviewer/looking-for.html) | Practical review criteria across behavior, design, complexity, tests, and documentation. |

## Conditional design references

- Khononov, [Balancing Coupling in Software Design](https://www.informit.com/store/balancing-coupling-in-software-design-universal-design-9780137353521): coupling dimensions and the relationship between modularity and change.
- Kleppmann, [Designing Data-Intensive Applications](https://dataintensive.net/): reliability, scalability, and data-system tradeoffs.
- Hohpe and Woolf, [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/): messaging contracts, translation, and integration.
- Nygard, [Release It!](https://pragprog.com/titles/mnee2/release-it-second-edition/): stability patterns, overload, and production failure.
- Fowler, [What Do You Mean by Event-Driven?](https://martinfowler.com/articles/201701-event-driven.html): separate decisions for notification, state transfer, event sourcing, and CQRS.

## Disagreement and empirical limits

Ousterhout and Martin's [direct discussion](https://github.com/johnousterhout/aposd-vs-clean-code) records disagreements about method length, comments, and TDD. This skill uses caller knowledge, coherence, and verification to judge a change rather than adopting universal size limits.

[A large scale empirical study of the impact of Spaghetti Code and Blob anti-patterns on program comprehension](https://www.sciencedirect.com/science/article/abs/pii/S0950584920300288) reports comprehension costs from repeated occurrences in university-based Java tasks. It supports investigating accumulated design problems; its setting limits generalization.

Ljung and Gonzalez-Huerta's [To Clean-Code or Not To Clean-Code](https://arxiv.org/abs/2208.07056) reports practitioner perceptions from a survey of 39 respondents. Agreement with principles does not establish causal benefits for every prescription.

Coverage, complexity, mutation scores, and dependency counts answer narrower questions than overall software quality. Interpret each measure with its mechanism, workload, and limitations. Use concrete failures and change scenarios to assess the design choices that metrics cannot establish.
