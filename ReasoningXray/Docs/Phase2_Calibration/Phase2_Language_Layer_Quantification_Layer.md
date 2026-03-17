Status: Candidate Canonical (await runtime audit)

🧠 ReasoningXray Phase 2
Epistemic Signal Scoring Model (Language Layer Quantification Layer)
1. Purpose
The scoring model converts linguistic perception risk into measurable structure.
It does NOT score:
grammar correctness
readability
sentiment
style quality
It scores only:
How strongly a sentence alters perceived diagnostic certainty, temporal expectation, authority gradient, and emotional temperature.
This is a clinical perception risk model.
2. The Four Core Epistemic Dimensions
Every rendered sentence must receive four independent scores.
I. Certainty Strength Score (CSS)
What it measures:
How resolved or definitive the reasoning sounds.
Scale (conceptual):
0.00 = fully open uncertainty  
0.25 = exploratory  
0.50 = provisional working clarity  
0.75 = strong likelihood  
1.00 = diagnostic finality
Examples (English baseline intuition)
Phrase    CSS
“may be related to”    0.25
“appears consistent with”    0.45
“likely explanation”    0.65
“this indicates”    0.85
“this confirms”    1.00
II. Temporal Projection Score (TPS)
What it measures:
How predictive or inevitable the future sounds.
Scale:
0.00 = purely observational  
0.30 = conditional possibility  
0.60 = directional expectation  
0.85 = implied trajectory  
1.00 = inevitability
Example Drift Risk
“may become clearer” → TPS ~0.30
literal translation → “will become clear” → TPS ~0.85
This is a high-risk escalation.
III. Authority Gradient Score (AGS)
What it measures:
How much the system sounds like a decision-maker vs observer.
Scale:
0.00 = narrative reporting  
0.30 = structured observation  
0.60 = interpretive framing  
0.85 = directive tone  
1.00 = clinical authority assertion
Example
Phrase    AGS
“the doctor noted that…”    0.20
“this suggests…”    0.45
“this means…”    0.70
“you should…”    0.95
IV. Emotional Temperature Score (ETS)
What it measures:
Psychological activation level induced by wording.
Scale:
0.00 = calm-neutral  
0.30 = engaged clarity  
0.60 = concern activation  
0.85 = alarm tone  
1.00 = fear-inducing
Example
Phrase    ETS
“monitoring continues”    0.20
“needs further checking”    0.40
“this is concerning”    0.70
“urgent risk”    0.95
3. Epistemic Envelope Concept
Each reasoning state from Level 3 defines an allowed score range.
Example:
Trajectory = Narrowing
Allowed envelope:
CSS: 0.35 – 0.55  
TPS: 0.20 – 0.50  
AGS: 0.15 – 0.45  
ETS: 0.10 – 0.40
If translated sentence produces:
CSS 0.70 → violation  
TPS 0.80 → violation  
AGS 0.60 → violation
System must trigger micro-signal rewrite.
4. Composite Perception Risk Index (PRI)
To simplify validation logic, we define:
PRI = weighted sum of envelope violations
Example conceptual:
PRI = (ΔCSS × 0.35)
    + (ΔTPS × 0.30)
    + (ΔAGS × 0.20)
    + (ΔETS × 0.15)
Why weighting?
Certainty escalation = highest medico-legal risk
Temporal promise = second
Authority tone = third
Emotional tone = contextual but still important
PRI threshold determines:
safe
needs soft rewrite
must block render
5. Language Calibration Requirement
Each language must build:
Modal Strength Table
Example conceptual:
Language device    CSS delta
soft modal particle    −0.10
declarative present tense    +0.15
future definite construction    +0.30
Temporal Hardness Table
construction    TPS delta
conditional future    +0.20
definite future    +0.45
temporal adverb (“soon”)    +0.25
Authority Framing Table
pattern    AGS delta
passive evidence framing    −0.10
system declarative verb    +0.25
Emotional Activation Table
lexical group    ETS delta
neutral monitoring verbs    −0.05
risk adjectives    +0.30
6. Calibration Philosophy (Very Important)
We are NOT trying to achieve:
mathematically exact perception prediction
We are trying to achieve:
consistent cross-language epistemic gravity.
Meaning:
A German patient and a Japanese patient should feel
roughly the same level of:
diagnostic openness
trajectory progress
future uncertainty
Even if sentences differ structurally.
7. MVP Practical Scope
For Phase 2 MVP scoring model:
hand-crafted scoring tables
clinician-reviewed perception calibration
small gold sentence test set
manual threshold tuning
NOT:
machine learning
reinforcement tuning
adaptive personalization
Those are Phase 4+.
