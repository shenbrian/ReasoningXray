🧠 ReasoningXray Phase 2
Translation Guardrail Pipeline
(Language Layer Execution Architecture)
1. Mission of the Pipeline
The pipeline exists to ensure that no localized sentence reaches the UI unless it stays inside the intended epistemic envelope.
Its job is not to produce the “best translation.”
Its job is to produce the safest trust-preserving rendering consistent with:
the original reasoning state
the allowed certainty band
the allowed authority gradient
the allowed emotional temperature
the allowed temporal openness
So the operational rule is:
Render only if epistemic fidelity survives language conversion.
2. Pipeline Position in the Full Stack
Level 1–5 Reasoning Engine
        ↓
Case / visit presentation output
        ↓
Epistemic signal extraction
        ↓
Signal carrier creation
        ↓
Candidate language rendering
        ↓
Guardrail scoring + validation
        ↓
Rewrite loop if needed
        ↓
Fallback if still unsafe
        ↓
UI render
This means the Language Layer sits after reasoning is already complete and before any patient-facing text is shown.
That separation is important governance.
Reasoning decides meaning.
Language Layer decides whether that meaning is being transmitted safely.
3. Pipeline Stages
We can define the pipeline as seven sequential stages.
Stage 1 — Source Signal Capture
Input is not raw text alone.
Input must include structured metadata from the reasoning system.
The pipeline receives:
source sentence or presentation segment
signal domain(s) involved
expected certainty envelope
expected temporal openness
expected authority level
expected emotional temperature band
locked trajectory state if relevant
Example:
Segment: "The reasoning appears to be narrowing toward a more focused explanation."
Metadata:
- domain: trajectory + certainty
- trajectory_state: narrowing
- CSS allowed: 0.35–0.55
- TPS allowed: 0.10–0.35
- AGS allowed: 0.15–0.40
- ETS allowed: 0.10–0.30
Without this stage, translation becomes blind and the rest of the pipeline cannot function.
Stage 2 — Candidate Rendering
A language-specific renderer produces an initial candidate sentence.
Important: this is not assumed safe.
It is only the first pass candidate.
At this stage the renderer uses:
target-language micro-signal bank
language-specific templates
signal-carrier constraints
preferred local phrasing patterns
This stage should aim for a good candidate, but it does not get final authority.
The validator does.
Stage 3 — Epistemic Scoring Pass
The candidate sentence is then scored on the four core dimensions:
CSS — Certainty Strength Score
TPS — Temporal Projection Score
AGS — Authority Gradient Score
ETS — Emotional Temperature Score
This scoring is language-specific.
Same meaning, different language, different syntax:
the model must score the perceived effect, not the literal form.
Output of this stage:
Candidate A
CSS: 0.62
TPS: 0.28
AGS: 0.48
ETS: 0.22
Stage 4 — Envelope Validation
Scores are compared against the allowed envelope supplied by the signal carrier.
Three outcomes are possible.
A. Pass
All scores remain within allowed bounds.
Sentence is safe to render.
B. Soft Violation
One or more scores exceed bounds slightly.
Sentence is recoverable through rewrite.
C. Hard Violation
One or more scores exceed bounds materially, or a prohibited expression appears.
Sentence cannot be shown as-is.
Examples of hard-violation conditions:
diagnostic confirmation wording in non-confirmation state
future certainty language where only conditionality is allowed
system voice sounds clinically directive
emotionally escalatory wording in calm informational context
Stage 5 — Rewrite Loop
If validation does not pass, the system enters a constrained rewrite loop.
This is a micro-signal rewrite, not a semantic rewrite.
Allowed operations:
soften modal verb
replace tense structure
reduce declarative force
add evidential framing
shift from active assertion to structured observation
swap emotionally loaded lexical item for neutral equivalent
Not allowed:
adding new medical content
changing clinical implication
introducing explanation not present in source meaning
making text more reassuring than evidence allows
This stage should be limited by strict retry count, for example:
max 2 or 3 rewrite attempts per segment
Reason:
this is safety correction, not open-ended generation.
Stage 6 — Fallback Resolution
If rewrite attempts still fail, the system must use a fallback strategy.
This is critical.
A safe product cannot depend on every sentence always being salvageable.
Fallback hierarchy should look like this:
Fallback 1 — Approved Low-Risk Template
Use a preapproved target-language template with lower epistemic force.
Example pattern:
“The doctor’s thinking is still being clarified.”
“This remains under consideration.”
“More information may still be needed.”
Fallback 2 — Structural Reduction
Reduce sentence complexity while preserving core signal.
Example:
Instead of:
“The reasoning appears to be narrowing toward a more focused explanation.”
Use:
“The doctor’s thinking seems to be becoming more focused.”
Fallback 3 — Signal-Only Safe Rendering
Render only the minimal faithful message.
Example:
“The picture is not final yet.”
“More clarity may come with time.”
This fallback must still preserve neutrality and not sound casual or vague.
Fallback 4 — Render Block
If no safe rendering exists, do not show the high-risk phrasing.
Instead show a controlled neutral substitute or omit that segment.
This is preferable to unsafe certainty inflation.
Stage 7 — Render Logging and Audit Trace
Every final rendered sentence should leave an internal audit trace.
The trace should record:
source segment id
target language
candidate version
scoring results
violations detected
rewrite operations applied
final output class: pass / rewritten / fallback / blocked
This is not just engineering hygiene.
It is governance infrastructure.
It allows later review of:
where trust drift occurs
which languages are fragile
which templates over-escalate certainty
whether legal-risk patterns are emerging
4. Pipeline Decision Logic
A clean decision model would look like this:
1. Capture source signal
2. Render candidate
3. Score candidate
4. Validate against envelope

If pass:
    render
If soft violation:
    rewrite and rescore
If hard violation:
    bypass normal rewrite and move to safer template set
If still unsafe after retries:
    fallback or block
That logic should stay deterministic for MVP.
No open-ended probabilistic behavior yet.
5. Hard Block Rules
Some conditions should bypass ordinary rewrite and trigger immediate hard block behavior.
These are product-law rules.
Hard Block Rule 1
Do not allow finality language unless trajectory state is truly confirmation.
Blocked patterns include equivalents of:
confirms
definitely shows
proves
clearly is
Hard Block Rule 2
Do not allow predictive future if source state is merely conditional.
Blocked patterns include equivalents of:
will become clear
this will resolve
it will improve
this means it is heading toward X
Hard Block Rule 3
Do not allow system authority inflation.
The system must not sound like:
making a diagnosis
instructing the patient medically
replacing clinician judgment
Hard Block Rule 4
Do not allow emotional escalation in neutral summary segments.
Blocked patterns include equivalents of:
worrying
dangerous
serious concern
unless explicitly present in the source reasoning meaning and intended output class.
6. Latency Discipline
This pipeline must be safe, but it also must not become product-friction.
So MVP design should keep latency controlled through:
small handcrafted rule banks
deterministic scoring tables
limited rewrite loops
approved fallback templates
segment-level processing rather than full-page regeneration
The principle is:
Fast enough for real use, strict enough for trust preservation.
7. Recommended MVP Operating Mode
For MVP, the pipeline should operate in a conservative mode.
That means:
prefer under-assertion over over-assertion
prefer neutral wording over elegant wording
prefer fallback templates over risky free phrasing
prefer render block over unsafe translation
This is the right bias for a clinical-adjacent product.
8. What This Pipeline Protects
If implemented correctly, this pipeline protects against five specific failures:
Certainty inflation
A provisional thought sounding like a conclusion
Temporal overpromise
A possibility sounding like a likely future
Authority drift
The product sounding like a doctor
Emotional miscalibration
Calm structure turning into alarm or condescension
Cross-cultural trust fracture
Different languages producing different felt levels of safety
That is the true purpose of the whole Language Layer.
9. Phase 2 Architecture Status So Far
At this point, Phase 2 has a coherent architectural skeleton:
Scope Charter
Signal Taxonomy
Micro-Signal Architecture
Scoring Model
Guardrail Pipeline
This is enough to begin turning the language subsystem into an implementable spec.
But before implementation, one more calm structural step is still needed:
Define the Failure Mode Catalogue
Because the validator and rewrite rules should be built against explicit failure classes, not abstract fear.
That catalogue should enumerate:
certainty inflation failures
authority drift failures
temporal promise failures
tone cooling / tone warming failures
cultural hierarchy failures
ambiguity collapse failures
That is the next correct step.
