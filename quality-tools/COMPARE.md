# SF Perf Monitor + SF Graphy vs. PMD vs. Apex Guru

A feature-by-feature comparison of three Apex developer tooling approaches.

![Apex Dev Tools Comparison](https://raw.githubusercontent.com/mchinnappan100/npmjs-images/main/quality-tools/Apex-Dev-tools.png)

---

## The Three Tools at a Glance

| | SF Perf Monitor + SF Graphy | PMD | Apex Guru |
|---|---|---|---|
| **Category** | Runtime monitor + knowledge graph | Static analysis engine | AI static analysis (platform-native) |
| **Data source** | Live EventLogFile + Apex source | Source code only | Source code only |
| **Scope** | Entire org or SFDX project | File, directory, or project | One class or trigger at a time |
| **Offline** | Yes (local SFDX path mode) | Yes | No — requires Salesforce connectivity |
| **Cost** | Free, open source | Free, open source | Included in Salesforce platform |
| **Setup** | `npm install && node server.js` | `pmd check -d src/ -R ruleset.xml` | None — built into Setup |

---

## What Each Tool Is

### SF Perf Monitor + SF Graphy

**SF Perf Monitor** is a local Node.js dashboard that downloads your org's EventLogFile data (ApexExecution, ApexTrigger, RestApi, ApexRestApi, ApexCallout) and visualises real runtime performance — slow queries, P95 runtimes, callout delays — against actual production traffic.

**SF Graphy** is its companion Apex Knowledge Graph explorer: it parses your local SFDX project or fetches live ApexClass bodies from any authenticated org, then renders a D3 force-directed graph of every class dependency, inheritance chain, SOQL target, and DML operation across the entire codebase at once.

### PMD

**PMD** is a mature open-source static analysis framework with Apex support. It applies a configurable rule set to source files and reports violations as structured output (text, XML, JSON, HTML, CSV). Rules are written in XPath or Java; the Apex rule set ships ~80+ rules covering best practices, code style, design patterns, error-prone constructs, performance, and security. PMD has no UI, no runtime data, and no graph — it is a pure text-in / report-out command-line tool designed for CI pipelines.

### Apex Guru

**Salesforce Apex Guru** (GA Spring '25) is a Salesforce-native AI service that performs static analysis on a single Apex class or trigger at a time. You invoke it from Setup → Apex Guru, or from the Developer Console, and it returns AI-generated recommendations about code quality, performance risks, and anti-patterns. It operates entirely inside the Salesforce platform UI.

---

## Side-by-Side Comparison

| Capability | SF Perf Monitor + SF Graphy | PMD | Apex Guru |
|---|---|---|---|
| **Analysis scope** | Entire org or SFDX project — all classes simultaneously | File, directory, or project | One class or trigger at a time |
| **Runtime performance data** | P50/P75/P90/P95/P99/Max, slow %, trend charts, heatmap, drill-down | None | None |
| **Static rule coverage** | 8 focused rules (SOQL/DML in loop, callout in trigger, etc.) | ~80+ Apex rules across 6 categories | AI-generated, broad and contextual |
| **Graph visualisation** | Full force-directed: CALLS, EXTENDS, IMPLEMENTS, QUERIES, USES, DML | None — text/report output only | None |
| **Architectural analysis** | God classes, orphans, circular deps, impact BFS, shortest path | Some design rules (e.g. ExcessiveClassLength, TooManyFields) | No architectural view |
| **SOQL / DML detection** | Graph edges + runtime query counts from EventLogFile | SOQL/DML in loop, unbounded queries, several dedicated rules | Per-class SOQL/DML pattern hints |
| **CI / scripting integration** | Headless via `node server.js`; CSV cache; cron | First-class CI tool; XML/JSON/GitHub Annotations output; Maven/Gradle plugins | No CLI / scripting support |
| **Custom rules** | Not applicable (fixed rule set) | Yes — XPath rules, Java rules, custom ruleset XML | No |
| **AI assistance** | AI Sidekick (Ollama / Claude / OpenAI / xAI / Gemini) with graph context injection | None | Salesforce-native LLM, per-class context |
| **Source viewer** | Monaco editor with anti-pattern highlights | No UI — editor plugins (VS Code, IntelliJ) recommended | Developer Console / Setup UI |
| **Export** | SVG, PNG, JSON (Gephi/Cytoscape), GraphML, CSV, HTML, Slack/Teams/Email | XML, JSON, CSV, HTML, text, GitHub Annotations | Copy/paste text from UI |
| **Notifications** | Slack (Block Kit + PNG upload), Teams, Email | Via CI (GitHub PR annotations, etc.) | None |
| **Offline** | Yes (local path mode) | Yes | No |
| **Multi-language** | Apex only | 15+ languages (Java, JavaScript, Python, etc.) | Apex only |
| **Incremental / file-level** | No | Yes (`--file-list`, incremental diff via CI) | Yes (one class at a time) |
| **False-positive tuning** | Not applicable | Suppress via `@SuppressWarnings`, baseline files, rule priority | Not applicable |

---

## Static Rule Depth: PMD vs. the Others

PMD has the broadest and most configurable static rule set of the three tools.

### PMD Apex rule categories

| Category | Example rules |
|---|---|
| **Best Practices** | `ApexUnitTestClassShouldHaveAsserts`, `AvoidLogicInTrigger`, `ApexUnitTestMethodShouldHaveIsTestAnnotation` |
| **Code Style** | `ClassNamingConventions`, `FieldNamingConventions`, `MethodNamingConventions` |
| **Design** | `ExcessiveClassLength`, `ExcessiveParameterList`, `CyclomaticComplexity`, `NcssMethodCount` |
| **Error Prone** | `ApexCSRF`, `AvoidDirectAccessTriggerMap`, `ApexBadCrypto`, `EmptyCatchBlock` |
| **Performance** | `OperationWithLimitsInLoop` (SOQL, DML, callout in loops) |
| **Security** | `ApexSharingViolations`, `ApexCRUDViolation`, `ApexInsecureEndpoint`, `ApexOpenRedirect`, `ApexSOQLInjection`, `ApexXSSFromURLParam` |

### SF Perf Monitor static rules (8 rules)

| Severity | Rule |
|---|---|
| Critical | SOQL inside loop |
| Critical | DML inside loop |
| Critical | HTTP callout in trigger |
| Warning | Non-bulkified trigger (`Trigger.new[0]`) |
| Warning | SOQL without LIMIT |
| Warning | Hardcoded Salesforce Id |
| Info | System.debug spam |
| Info | Large collection initialised inline |

SF Perf Monitor's static rule set is intentionally narrow — it targets only the patterns that have a directly measurable runtime impact (visible in EventLogFile data). PMD's rule set is far broader and includes security, naming, complexity, and test-quality rules that SF Perf Monitor does not attempt to cover.

### Apex Guru static analysis

Apex Guru's rule set is AI-generated and not documented as a fixed list. It can surface contextual, conversational recommendations that neither PMD nor SF Perf Monitor can produce — for example, reasoning about the semantic intent of a method and suggesting a better algorithm.

---

## Runtime Data: SF Perf Monitor Only

Neither PMD nor Apex Guru has any access to runtime data. SF Perf Monitor is the only tool of the three that can answer questions like:

- "Which Apex classes are actually slow in production — not just flagged by a linter?"
- "What is the P95 execution time for `OrderService.processAll` across the last 24 hours?"
- "How many governor-limit events has `AccountTrigger` generated this week?"
- "Is there a correlation between a known anti-pattern and measured runtime degradation?"

The heatmap (hour-of-day × day-of-week), trend chart, percentile breakdowns (P50→P99), and drill-down panel are all unique to SF Perf Monitor.

---

## Architecture Analysis: SF Graphy Only

Neither PMD nor Apex Guru provides a graph or any cross-class architectural view. SF Graphy is the only tool that can answer:

- "Which classes are most tightly coupled?"
- "What is the blast radius if I refactor `QuoteService`?"
- "Are there circular dependencies between service classes?"
- "Which classes have zero dependents (orphans)?"
- "Which classes exceed 35% of the max in-degree (god classes)?"

PMD's Design rules (e.g. `ExcessiveClassLength`, `CyclomaticComplexity`) provide per-class complexity signals, but no cross-class topology.

---

## CI Integration: PMD Leads

For automated CI quality gates, PMD is the natural choice:

- Generates GitHub Annotations, XML (for Checkstyle parsers), JSON, and HTML reports natively
- Maven (`pmd-maven-plugin`) and Gradle (`gradle-pmd`) plugins available
- Supports baseline files to suppress pre-existing violations and report only new regressions
- Rule priorities map to exit codes, enabling clean pass/fail gates
- `--file-list` and incremental scanning modes for large monorepos

SF Perf Monitor has a cron scheduler and headless mode but is designed for scheduled monitoring, not per-commit quality gating. Apex Guru has no CLI.

---

## ⚠️ PMD Warning: `@SuppressWarnings` Abuse

PMD allows developers to silence any rule violation by annotating a class or method with `@SuppressWarnings('PMD')` (or a specific rule name such as `@SuppressWarnings('PMD.ApexCRUDViolation')`). This is a legitimate escape hatch for genuine false positives — but in practice it is routinely misused to make the CI gate green without fixing the underlying problem.

### What it looks like

```apex
@SuppressWarnings('PMD.OperationWithLimitsInLoop')
public void processAll(List<Account> accounts) {
    for (Account a : accounts) {
        update a;  // DML inside loop — silenced, not fixed
    }
}
```

```apex
@SuppressWarnings('PMD')  // blanket suppression — silences every rule on this class
public class DataMigrationHelper {
    // ...
}
```

### Why this is dangerous

- A suppressed violation is **invisible in PMD reports** — the CI gate passes, the defect ships.
- Blanket `@SuppressWarnings('PMD')` on a class silences all current *and future* rules, including security rules added in later PMD versions.
- Over time, a codebase can accumulate dozens of suppressed violations that represent real governor-limit risks, CRUD/FLS gaps, or SOQL injection vectors — all hidden.
- Suppressions are often added under time pressure and never reviewed or removed once the underlying issue is resolved.

### How to audit: `pmd-annotations`

Use the **[pmd-annotations](https://www.npmjs.com/package/pmd-annotations)** npm package to scan an SFDX project and report every `@SuppressWarnings` annotation in use, who added it, and which rule it suppresses.

```bash
npm install -g pmd-annotations
pmd-annotations --dir force-app/main/default/classes
```

Sample output:

```
File                          Line  Annotation
────────────────────────────  ────  ──────────────────────────────────────────
DataMigrationHelper.cls          1  @SuppressWarnings('PMD')  [BLANKET — all rules]
OrderService.cls                12  @SuppressWarnings('PMD.OperationWithLimitsInLoop')
TriggerHandler.cls              34  @SuppressWarnings('PMD.ApexCRUDViolation')
AccountController.cls           89  @SuppressWarnings('PMD.ApexSOQLInjection')
```

### Recommended governance

| Action | Detail |
|---|---|
| **Ban blanket suppressions** | Reject any `@SuppressWarnings('PMD')` without a specific rule name in code review |
| **Require a comment** | Mandate that every suppression is accompanied by a comment explaining why the false positive is genuine |
| **Run `pmd-annotations` in CI** | Add it as a separate CI step and fail if new suppression annotations are introduced without a corresponding PR review label |
| **Periodic audit** | Schedule a quarterly `pmd-annotations` run and review the full list — remove suppressions where the underlying code has since been fixed |
| **Track as tech debt** | Log suppressions that cover real issues as backlog tickets rather than leaving them silently suppressed |

---

## When to Use Each Tool

### Use SF Perf Monitor when you want to:
- Understand **real production performance** — actual P95 runtimes, governor events, slow rates
- Correlate static anti-pattern findings with **measured runtime impact**
- **Trend** performance over time after a deploy
- Send automated **Slack / Teams / Email reports** on a schedule

### Use SF Graphy when you want to:
- See the **whole codebase topology** at once — calls, inheritance, SOQL targets, DML
- Perform **architectural review** before a large refactor
- Identify **god classes, orphans, or circular dependencies**
- Export the graph to share with the team or import into Gephi/Cytoscape
- Work **offline** from a local SFDX project with no org connection

### Use PMD when you want to:
- Enforce **naming conventions, code style, and complexity limits** in CI
- Run **security rules** (SOQL injection, CRUD/FLS violations, CSRF, XSS)
- Gate **pull requests** with a pass/fail quality check
- Cover **test quality** (missing asserts, missing `@isTest` annotations)
- Suppress known violations via baselines and tuned rule priorities

### Use Apex Guru when you want to:
- Get **quick AI feedback on a single class** without leaving the browser
- Leverage Salesforce's LLM trained on platform patterns
- Check a class during an active development session
- Operate entirely **within Salesforce's trust boundary**

---

## Complementary, Not Competing

The three tools answer different questions:

| Question | Best tool |
|---|---|
| "Is this class actually slow in production?" | SF Perf Monitor |
| "What does this class depend on?" | SF Graphy |
| "Which classes are most tightly coupled?" | SF Graphy |
| "Does this code have a SOQL injection vulnerability?" | PMD |
| "Are there naming convention violations?" | PMD |
| "Is this class too complex (cyclomatic complexity)?" | PMD |
| "Is there a SOQL inside a loop?" | All three |
| "Is this class well-written? (AI explanation)" | Apex Guru / AI Sidekick |
| "What changed in runtime perf after my deploy?" | SF Perf Monitor |
| "What breaks if I refactor AccountService?" | SF Graphy (impact BFS) |
| "Gate this PR on code quality?" | PMD |

### Recommended workflow

1. **PMD in CI** — enforce naming, security, complexity, and best-practice rules on every PR. Fix regressions before they land.
2. **SF Graphy for architectural review** — before a large refactor, orient yourself in the dependency graph, identify god classes, and scope the blast radius.
3. **SF Perf Monitor for production investigation** — after a deploy or incident, find the runtime hotspots, correlate them with static anti-patterns, and trend them over time.
4. **Apex Guru for per-class deep dive** — once you have identified a specific class worth improving, get deep AI-generated recommendations.

---

## Apex Guru Hallucination Risk

Because Apex Guru is powered by a large language model, it is subject to the same hallucination risks as any AI system. This is a material concern for a tool whose output is used to guide code changes in production Salesforce orgs.

### What hallucination looks like in Apex Guru

| Type | Example |
|---|---|
| **Invented API** | Recommends a method like `Database.rollbackToSavepoint()` that does not exist in the Apex runtime |
| **Wrong governor limit** | States an incorrect SOQL row limit, heap size cap, or CPU budget |
| **Phantom anti-pattern** | Flags a code pattern as dangerous when it is in fact safe and idiomatic in the given context |
| **Incorrect fix** | Suggests a refactor that compiles but changes runtime behaviour — e.g. moving a SOQL outside a loop in a way that breaks bulkification |
| **Outdated advice** | Recommends an approach that was valid in API v48 but is deprecated or unsafe in current API versions |
| **Fabricated Salesforce documentation reference** | Cites a Knowledge Article URL or Trailhead module that does not exist |

### Why LLM-based tools hallucinate

LLMs generate responses by predicting the next token based on training data. They have no live access to the Apex compiler, the Salesforce documentation, or the governor limit tables — they have learned patterns from text. When a question falls outside confident training territory (e.g. an obscure limits interaction, a new API surface added after training cutoff), the model fills the gap with plausible-sounding but incorrect text.

Apex Guru's LLM is Salesforce-trained and does better than a general-purpose model on Apex idioms — but it is not immune. Hallucination is an intrinsic property of current LLM architectures, not a fixable bug.

### Contrast with deterministic tools

PMD and SF Perf Monitor's static rules are fully deterministic:

- PMD's rules are written in XPath or Java and evaluated against the parsed AST. A rule either fires or it does not. There is no generative component, no probability, and no invented output.
- SF Perf Monitor's 8 static rules are regex/AST checks on real source fetched from the org, and its runtime metrics are derived directly from EventLogFile CSV data — the numbers are measurements, not estimates.

Neither tool can hallucinate. Their false-positive rate exists (a heuristic can misfire), but they will never invent a non-existent API or fabricate a documentation reference.

### Human validation is required for Apex Guru output

Because Apex Guru recommendations are AI-generated, every suggestion must be validated by a developer before acting on it. Recommended checks before applying any Apex Guru recommendation:

1. **Verify the API exists** — look up the suggested class or method in the [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/).
2. **Confirm governor limits** — cross-check any stated limit against the current [Apex Governor Limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) reference.
3. **Test the suggested fix** — deploy to a sandbox and run Apex tests; a recommended refactor that changes observable behaviour will show up in test failures.
4. **Cross-check with PMD** — if Apex Guru and PMD disagree, the PMD rule is deterministic and verifiable; the Apex Guru recommendation may be the one that needs scrutiny.
5. **Do not cite Apex Guru output as authoritative in design docs** — treat it as a starting point for investigation, not a source of truth.

### SF Perf Monitor AI Sidekick — same caveat applies

SF Perf Monitor's **AI Sidekick** (Ollama / Claude / OpenAI / xAI / Gemini) is also LLM-based and carries the same hallucination risk. It injects graph context and live metrics into the prompt to ground the model's responses in real data — but the model can still generate incorrect Apex advice. Human review is equally required before applying any AI Sidekick suggestion.

The key difference: the AI Sidekick's *supporting data* (node stats, runtime metrics, anti-pattern flags) comes from deterministic sources (EventLogFile CSV + regex rules), so the factual context fed to the LLM is reliable even when the LLM's interpretation of it may not be.

---

## Summary

| | SF Perf Monitor + SF Graphy | PMD | Apex Guru |
|---|---|---|---|
| **Unique strength** | Runtime evidence + whole-codebase graph | Broadest static rule set; best CI integration | AI per-class recommendations; zero setup |
| **Weakness** | Narrow static rules; no security analysis; AI Sidekick can hallucinate | No runtime data; no architectural view; no UI | No runtime data; no graph; no CI; one class at a time; **LLM hallucination risk — human validation required** |
| **Output reliability** | Metrics: deterministic (EventLogFile CSV). AI Sidekick: requires human review | Fully deterministic — no LLM component | AI-generated — must be verified before acting |
| **Best for** | Performance investigations, architectural reviews, team reporting | CI quality gates, security enforcement, naming/style | Individual class improvement during development |
| **Deployment** | Local Node.js, any OS | CLI / Maven / Gradle, any OS | Salesforce platform only |
