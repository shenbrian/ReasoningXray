Status: Candidate Canonical (await runtime audit)

🧠 ReasoningXray Phase 2
Epistemic Signal Taxonomy (Language Layer Foundation)
Purpose
The Epistemic Signal Taxonomy defines the minimal set of reasoning states whose perceived meaning must remain invariant across languages.
This is the atomic layer of trust preservation.
If these signals drift →
trajectory credibility collapses →
patient expectation destabilizes →
clinical neutrality is compromised.
1. The Four Epistemic Signal Domains
Language Layer must protect four signal families.
These are not UI labels.
They are perception states.
I. Certainty State Signals
(How resolved the reasoning feels)





4
Core Signals
Active Uncertainty
Meaning: reasoning is still open
Risk if mistranslated: appears negligent or confused
Emerging Clarity
Meaning: pattern beginning to form
Risk if mistranslated: sounds like near-diagnosis
Working Explanation
Meaning: current best framing, still provisional
Risk if mistranslated: perceived as conclusion
Stabilizing Understanding
Meaning: fewer competing explanations
Risk if mistranslated: perceived as confirmation
Invariant Requirement
Across languages, the patient must perceive:
“The doctor is thinking forward — but not finished thinking.”
Not:
“The answer is known”
“The doctor is unsure what to do”
“A diagnosis has been given”
II. Trajectory Movement Signals
(How reasoning is progressing)






4
Core Signals
Exploring
Wide hypothesis space
Narrowing
Reducing plausible explanations
Advancing
Meaningful forward reasoning movement
Pausing / Monitoring
Deliberate wait for evidence
Invariant Requirement
Patient must perceive:
“Movement is intentional — not delay.”
Risk drift patterns:
Narrowing → “doctor changed mind”
Monitoring → “nothing is happening”
Exploring → “doctor is guessing”
III. Expectation Horizon Signals
(What the patient should psychologically expect next)






4
Core Signals
Clarity May Increase
Soft temporal openness
More Information Needed
Evidence dependency
Follow-up Matters
Time-linked reasoning
No Immediate Resolution Expected
Realistic pacing
Invariant Requirement
Future framing must remain:
possible
conditional
non-predictive
non-reassuring beyond evidence
Key risk:
Future tense in some languages becomes implicit promise.
IV. Authority & Ownership Signals
(Who is deciding / interpreting)






4
Core Signals
Doctor Reasoning Ownership
AI is not diagnosing
Patient Understanding Ownership
Patient is interpreter of trajectory
System Neutrality
ReasoningXray organizes — does not judge
Provisional Framing
Nothing presented as final truth
Invariant Requirement
Across languages the system must never sound like:
issuing clinical judgment
validating or rejecting doctor decisions
instructing patient medically
2. Signal Hierarchy (Critical Structural Insight)
These signals are not equal.
They form a stability stack:
Authority Signals  → must be most stable
Certainty Signals  → second most stable
Trajectory Signals → flexible but must remain directional
Expectation Signals → most linguistically sensitive
Meaning:
If translation budget is limited —
protect Authority + Certainty first.
3. Signal Compression Rules
Language Layer must detect and prevent:
A. Certainty Compression
Multiple uncertainty markers → reduced to one → perceived clarity increases.
B. Temporal Hardening
“may” → “will”
“could” → “will likely”
C. Authority Inflation
Passive → active voice
Soft framing → declarative statement
D. Emotional Temperature Shift
Neutral verbs → emotionally loaded verbs
4. Minimal Signal Encoding Schema (Conceptual)
Before implementation we already know the system will need something like:
EpistemicSignal {
    domain: certainty | trajectory | expectation | authority
    state: enum
    perceived_certainty_weight
    temporal_softness_weight
    authority_gradient_level
    emotional_temperature_band
}
This is NOT engineering yet —
this is conceptual necessity mapping.
5. Validation Philosophy
Language Layer testing must ask:
Not:
“Is the translation accurate?”
But:
“Does the translated sentence create the same felt level of diagnostic resolution?”
This is a perceptual metric.
