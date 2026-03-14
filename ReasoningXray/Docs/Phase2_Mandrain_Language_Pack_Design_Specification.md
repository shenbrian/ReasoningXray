🧠 ReasoningXray Phase 2
Mandarin Language Pack — Design Specification (MVP)
1. Role of the Mandarin Pack
The Mandarin pack must:
preserve epistemic uncertainty without heavy modal verbs
avoid temporal inevitability implication
prevent authority inflation in concise sentence structures
maintain calm clinical neutrality (not cold, not alarmist)
compensate for ambiguity collapse risk
Mandarin will be the architecture stress language.
Therefore the pack must be intentionally conservative.
2. Mandarin Epistemic Style Principles (Non-Negotiable)
Principle 1 — Prefer “seems / appears” framing over direct state verbs
Safer patterns:
看起来…
目前看来…
似乎…
可能与…有关
Avoid:
是…
表明…
说明…
可以确定…
Reason:
Mandarin declarative verbs sound more final than English equivalents.
Principle 2 — Use temporal openness markers explicitly
Safer patterns:
还需要时间观察
随着进一步检查，情况可能会更清楚
目前还不能完全确定
Avoid:
会变清楚
很快就能知道
最终会…
Reason:
Future tense in Mandarin often implies inevitability even without “will.”
Principle 3 — Maintain narrative reference to doctor reasoning
Safer patterns:
医生正在考虑…
医生目前的判断是…
医生的思路正在逐渐聚焦
Avoid:
这种情况是…
需要…
应该…
Reason:
Dropping subject shifts authority from clinician → system.
Principle 4 — Avoid emotional lexical activation
Safer neutral verbs:
需要进一步观察
仍在评估
正在收集更多信息
Avoid:
值得担心
严重
风险很高
Unless explicitly present in reasoning meaning.
3. Modal Strength Table (Mandarin MVP)
Conceptual CSS delta table:
可能          -0.15
似乎          -0.10
看起来        -0.10
目前看来      -0.08
也许          -0.18
是            +0.25
表明          +0.30
说明          +0.28
可以确定      +0.40
Important:
Mandarin often omits modal words →
system must insert them deliberately.
4. Temporal Hardness Table (Mandarin MVP)
TPS delta examples:
还需要时间      -0.10
可能会          +0.10
将会            +0.35
很快会          +0.45
最终会          +0.50
Rule:
Prefer time-open constructions over predictive constructions.
5. Authority Gradient Table (Mandarin MVP)
AGS delta examples:
医生正在考虑      -0.15
医生的思路是      -0.10
目前判断为        +0.05
这是…            +0.20
需要…            +0.25
应该…            +0.40
Mandarin imperative softness is limited —
therefore narrative anchoring is critical.
6. Emotional Temperature Table (Mandarin MVP)
ETS delta examples:
观察            -0.05
评估            -0.05
进一步了解        -0.03
担心            +0.25
严重            +0.35
危险            +0.50
Mandarin emotional adjectives are stronger than English equivalents.
7. Forbidden Pattern List (Mandarin MVP)
Hard block expressions unless trajectory state = confirmation or high-risk signal is explicitly present:
可以确定
已经证明
一定是
会解决
很严重
必须马上
Also block system voice imperatives like:
你应该…
你需要…
ReasoningXray must never instruct medically.
8. Approved Low-Risk Template Set (Mandarin)
These are fallback-safe structures.
Template Class A — Uncertainty Preservation
目前来看，这种情况还需要进一步观察。
医生仍在考虑不同的可能性。
情况可能会随着时间逐渐变得更清楚。
Template Class B — Trajectory Forward Signal
医生的思路正在逐渐聚焦。
目前的判断还在持续调整中。
诊断方向正在慢慢收窄。
Template Class C — Monitoring Intentionality
接下来的观察有助于更好地理解情况。
进一步检查可能提供更多线索。
9. Structural Compensation Strategy (Very Important)
Because Mandarin lacks rich modal grammar:
System must compensate by:
adding narrative framing clauses
using temporal openness phrases
maintaining clause layering
avoiding ultra-short declarative sentences
Example:
Unsafe short sentence:
情况正在变清楚。
Safer compensated structure:
随着进一步观察，情况可能会逐渐变得更清楚。
10. Example End-to-End Safe Rendering
English source:
“The reasoning appears to be narrowing toward a more focused explanation.”
Mandarin candidate unsafe:
医生已经找到更可能的原因。
Problems:
CSS too high
authority inflation
trajectory misrepresented
Safe rendering:
医生的思路似乎正在逐渐聚焦到一个更具体的解释上。
Why safe:
“似乎” softens certainty
“逐渐” maintains temporal openness
“思路” preserves narrative reasoning ownership
11. MVP Mandarin Pack Completion Criteria
Mandarin pack is considered ready when:
CSS scoring variance across test sentences < acceptable threshold
rewrite loop success rate > ~80%
fallback usage < ~15%
no hard-block failures in gold test set
clinician reviewers judge perceived certainty consistent with English baseline
12. What Comes Next (Critical)
Now that Mandarin pack spec exists, the next correct move is:
👉 Design the Gold Calibration Sentence Set
Because without controlled test sentences:
scoring tables cannot be tuned
validator cannot be validated
rewrite success cannot be measured
pilot language cannot truly stress the system
This sentence set becomes the epistemic wind tunnel for Phase 2.
Shall we build that now?
