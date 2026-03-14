🧠 ReasoningXray Phase 2
Language Layer Failure Mode Catalogue
(Translation Fidelity Risk Map)
1. Purpose
The Failure Mode Catalogue defines how epistemic meaning can be distorted during language rendering.
Each failure mode represents a predictable perception shift that may:
inflate diagnostic certainty
distort reasoning trajectory
create false expectation
alter perceived authority
destabilize emotional trust
These are not grammar mistakes.
They are clinical trust transmission errors.
2. Primary Failure Classes
We define six core failure classes for Phase 2 MVP.
Failure Class A — Certainty Inflation
Definition
Language rendering increases perceived diagnostic resolution beyond the intended reasoning state.
Typical Linguistic Causes
replacing modal verbs with declarative verbs
removing hedging structures
converting probabilistic adjectives into definitive statements
collapsing multi-layer uncertainty into single confident clause
Example Drift
Source meaning:
“This may be one possible explanation.”
Unsafe rendering:
“This is the explanation.”
Risk Impact
medico-legal liability amplification
patient premature belief fixation
reduced openness to follow-up evidence
perceived contradiction in later visits
Detection Signals
CSS exceeds envelope
declarative verb density spike
absence of uncertainty markers
Failure Class B — Temporal Promise Drift
Definition
Future-oriented reasoning becomes interpreted as predicted outcome.
Typical Linguistic Causes
strong future tense constructions
inevitability adverbs
timeline compression
certainty phrasing attached to time expressions
Example Drift
Source meaning:
“Clarity may improve after further testing.”
Unsafe rendering:
“Testing will clarify the problem.”
Risk Impact
false reassurance
expectation misalignment
later trust erosion if clarity does not occur
perceived diagnostic competence distortion
Detection Signals
TPS exceeds envelope
definite future markers
temporal certainty co-occurring with provisional state
Failure Class C — Authority Gradient Distortion
Definition
The system voice shifts from neutral organizer to perceived clinical authority.
Typical Linguistic Causes
replacing narrative framing with system assertion
direct imperative constructions
omission of reference to clinician reasoning
cultural hierarchy encoding via verb placement or honorifics
Example Drift
Source meaning:
“The doctor is considering several possibilities.”
Unsafe rendering:
“This condition is being evaluated.”
Even worse:
“You need evaluation for this condition.”
Risk Impact
product perceived as giving medical judgment
doctor-patient relationship interference
regulatory exposure
ethical boundary violation
Detection Signals
AGS exceeds envelope
directive tone pattern
subject shift from “doctor reasoning” to “system claim”
Failure Class D — Emotional Temperature Shift
Definition
Neutral clinical structure becomes emotionally activating or dismissive.
Two Opposite Directions
D1 — Alarm Escalation
Neutral phrasing becomes worry-inducing.
Example:
“Further monitoring is planned.”
→ “This is concerning and must be watched closely.”
D2 — Over-Reassurance
Provisional reasoning becomes comfort messaging.
Example:
“This remains under consideration.”
→ “This is probably nothing serious.”
Risk Impact
anxiety spikes
false comfort
patient behavior distortion
loss of credibility
Detection Signals
ETS exceeds or drops below expected band
emotionally loaded adjectives
reassurance verbs without evidential support
Failure Class E — Trajectory Meaning Collapse
Definition
Movement of reasoning is misinterpreted as:
confusion
indecision
contradiction
diagnostic reversal
Typical Linguistic Causes
lexical choices implying change of mind
verbs implying uncertainty incompetence
cultural norms where monitoring equals failure
insufficient forward-motion signaling
Example Drift
Source meaning:
“The reasoning is narrowing.”
Unsafe rendering:
“The doctor is still unsure.”
Risk Impact
perceived clinical instability
patient loss of confidence
distrust toward structured reasoning process
Detection Signals
trajectory verbs implying doubt rather than focus
disappearance of directional markers
substitution of monitoring with passive waiting
Failure Class F — Ambiguity Collapse
Definition
Structured medical uncertainty becomes oversimplified binary meaning.
Typical Linguistic Causes
languages with low tolerance for graded probability
omission of layered clauses
cultural pressure for decisiveness
template compression
Example Drift
Source meaning:
“There are several possible explanations.”
Unsafe rendering:
“It might be X.”
Or worse:
“It is probably X.”
Risk Impact
reasoning richness lost
patient belief prematurely anchored
trajectory later feels contradictory
Detection Signals
loss of plural hypothesis framing
reduced clause complexity
certainty term substitution
3. Secondary Failure Patterns (Watchlist)
These are not full classes but important to monitor.
G — Politeness Hierarchy Misfire
Honorific or formal grammar implies authority endorsement.
H — Narrative Distance Loss
Loss of narrative framing makes reasoning sound like system conclusion.
I — Cultural Directness Over-Correction
Attempt to sound clear becomes overly blunt or deterministic.
J — Monitoring Invisibility
Language removes signal that waiting is evidence-driven.
K — Tense Neutralization
Language lacking modal richness forces unsafe structure unless compensated.
4. Failure Severity Levels
Each detected failure should be categorized.
Severity    Meaning    Action
Level 1    Minor perception drift    rewrite
Level 2    Trust-impacting distortion    forced template substitution
Level 3    Medico-legal risk    hard block render
This classification will drive validator decisions.
5. Failure Mode Coverage Philosophy
The catalogue must not attempt to predict all linguistic errors.
It must cover all clinically meaningful perception shifts.
That is the boundary.
6. Why This Catalogue Matters Architecturally
Because now:
scoring model knows what violations represent
rewrite engine knows what pattern to fix
fallback templates know what risk they neutralize
QA can simulate real translation drift
localization teams know what NOT to optimize away
legal review can map product safeguards
Without this catalogue, the Language Layer remains theoretical.
With it, the subsystem becomes testable and governable.
Phase 2 Structural Readiness Status
At this moment you have:
Charter
Signal Taxonomy
Micro-Signal Architecture
Scoring Model
Guardrail Pipeline
Failure Mode Catalogue
This is a complete conceptual architecture for Phase 2.
The next step — if you wish to continue calmly — would be:
👉 Define the MVP Implementation Blueprint
module boundaries
data structures
rule table formats
scoring execution flow
rewrite strategy spec
test harness design
This will convert architecture into buildable spec.
Shall we proceed?
