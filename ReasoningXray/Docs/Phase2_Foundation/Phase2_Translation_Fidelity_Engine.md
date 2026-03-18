Status: Candidate Canonical (await runtime audit)

🧠 ReasoningXray Phase 2
Micro-Signal Architecture (Translation Fidelity Engine)
Position in System
Level 1–5 Reasoning Engine
        ↓
Epistemic Signal Extraction
        ↓
🟡 Micro-Signal Protection Layer  ← (this phase)
        ↓
Language Rendering / Localization
        ↓
UI
This layer is a semantic governor, not a translator.
1. What Is a Micro-Signal?
A micro-signal is the smallest linguistic device that changes perceived epistemic state.
Examples:
modal verb choice
temporal particle
clause softness
passive vs active framing
probability adjective strength
sentence rhythm density
politeness hierarchy marker
These are not “words.”
They are perception levers.
2. Micro-Signal Functional Stack
We define four architectural components.
A. Signal Carrier Layer
(Structural container for reasoning meaning)
This ensures that before any translation happens, the system knows:
what epistemic state must be preserved
what certainty level is allowed
what authority gradient must remain
Conceptual object:
SignalCarrier {
    domain
    state
    certainty_band
    temporal_openness
    authority_level
    tone_temperature
}
This travels with the sentence as metadata.
Without this — translation becomes blind.
B. Micro-Signal Bank (Language-Specific)
Each supported language must have a curated bank containing:
1. Allowed Uncertainty Devices
Examples category types:
soft modal verbs
evidential particles
probability adverbs
conditional constructions
hypothetical framing patterns
2. Forbidden Certainty Escalators
Examples:
diagnostic-sounding verbs
inevitability phrasing
clinical conclusion markers
strong prediction tense
3. Authority Dampeners
Examples:
distancing constructions
framing verbs (“appears”, “suggests”)
narrative referencing (“the doctor noted…”)
4. Emotional Neutralizers
Examples:
non-alarmist verbs
non-comforting reassurance patterns
calm pacing clause templates
This bank is curated medical-communication infrastructure.
Not generic NLP resource.
C. Perception Budget Engine
(Critical new concept)
Every sentence has a certainty budget and authority budget.
Language rendering cannot exceed that budget.
Example:
If trajectory state = Narrowing
Allowed perceived certainty range = 0.35–0.55
Translation candidate evaluated:
modal strength score
temporal hardness score
declarative density score
If total exceeds threshold → rewrite required.
This prevents silent epistemic drift.
D. Pre-Render Guardrail Validator
Before UI output, a validator checks:
Certainty escalation
Temporal projection risk
Authority shift
Emotional temperature spike
Monitoring misinterpretation risk
If violation detected:
→ system triggers micro-signal rewrite pass
Not re-reasoning.
Only linguistic adjustment.
3. Micro-Signal Flow Example
Conceptual flow:
Trajectory State: Narrowing
Certainty Band: Medium-low
Temporal Openness: High
Authority Level: Neutral

↓ Candidate translation produced

Validator detects:
- future tense too strong
- clause too declarative

↓ Rewrite engine adjusts:

adds conditional particle
softens verb
adds evidential framing
Final output stays within epistemic envelope.
4. Language Layer Governance Rules
Rule 1 — No Signal Amplification
Translation must never increase:
diagnostic certainty
doctor authority
temporal promise
emotional reassurance strength
Rule 2 — Structural Meaning Overrides Fluency
If a sentence sounds slightly less elegant
but preserves epistemic neutrality → choose neutrality.
Rule 3 — Monitoring Must Sound Intentional
Some languages interpret waiting as incompetence.
System must inject:
purpose framing
evidence dependency signal
Without sounding defensive.
Rule 4 — Confirmation Is a Locked State
Language must not imply confirmation unless:
Level 3 trajectory = confirmation.
This rule is non-negotiable medico-legal protection.
5. Architecture Insight (Very Important)
This layer is not translation.
It is:
Epistemic Signal Rate Limiting.
Just like network rate limiting prevents overload,
this prevents certainty overload.
6. MVP Boundary for Phase 2
To avoid scope explosion, Phase 2 MVP should:
Support:
English (reference language)
One structurally different language (e.g. Chinese / Japanese / German)
Not:
all languages
full personalization
tone A/B optimization
adaptive emotional tuning
Those belong to later learning phases.

