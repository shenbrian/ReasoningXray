ReasoningXray — Level 3 Freeze Charter

Trajectory Engine + Patient Translation Layer

1. Freeze Declaration

Level 3 of ReasoningXray is hereby declared functionally complete and frozen.

Level 3 defines the case-level reasoning trajectory layer, converting longitudinal clinical reasoning signals into:

structured technical trajectory understanding

deterministic patient-facing meaning translation

No further logic expansion or behavioral change is permitted under Level 3 after this freeze.

Only presentation refinements and non-semantic UI adjustments are allowed in subsequent stages.

2. Scope of Level 3

Level 3 includes the full pipeline from visit-level reasoning outputs → case trajectory synthesis → patient understanding translation.

2.1 Technical Trajectory Engine

Core responsibilities:

Detect overall reasoning path across visits

exploration

narrowing

working explanation

confirmation

monitoring

reopened

mixed

Detect certainty trend

Detect reasoning momentum

Detect active uncertainty state

Output artifact:

CaseTrajectorySummary

This artifact is considered architecturally stable.

2.2 Patient Translation Layer

Deterministic transformation of technical trajectory into:

narrative meaning

reassurance framing

forward expectation

decision safety framing

Output artifact:

PatientTrajectoryTranslation

Principles locked:

No invention of clinical facts

No diagnosis generation

No advice generation

Language reflects reasoning movement — not medical correctness

Translation must remain structurally faithful to trajectory state

2.3 Combined Presentation Wrapper

Level 3 introduces a unified presentation contract:

CaseTrajectoryPresentation
{
    technical: CaseTrajectorySummary
    patient: PatientTrajectoryTranslation
}

This wrapper is now the canonical trajectory interface for UI consumption.

2.4 Validator Contract

Level3TrajectoryValidator is frozen as:

structural sanity checker

translation coherence checker

trajectory pattern consistency checker

Validator output defines expected behavioral envelope for Level 3.

Any future logic change that alters validator output constitutes a freeze violation.

3. UX Integration Status at Freeze

Level 3 trajectory information is now surfaced in:

Thread List (Condensed Signal)

Each thread card displays:

compact reasoning path label

condensed patient narrative meaning

condensed forward expectation

Goal achieved:

Patient can scan “how this issue is evolving” without opening details.

Thread Detail (Full Trust Panel)

Trajectory presentation panel includes:

Technical trajectory summary

What this means for you

Reassurance

What to expect next

How settled this seems

Goal achieved:

Patient understands reasoning direction + stability + expectation.

4. Non-Goals Locked at Freeze

Level 3 does NOT:

predict outcomes

recommend treatments

judge doctor correctness

simulate future reasoning

compare doctors

generate probabilistic advice

adapt wording using LLM inference

Level 3 is:

A structural reasoning mirror, not a medical intelligence engine.

5. Change Control After Freeze

Allowed changes:

typography

spacing

section ordering

label wording refinement

redundancy reduction

card hierarchy tuning

scanning ergonomics

trust-tone calibration

Not allowed:

new trajectory states

altered trajectory classification logic

altered certainty logic

altered uncertainty detection

altered translation semantic mapping

validator weakening

probabilistic language injection

AI summarization replacing deterministic mapping

6. Strategic Meaning of Level 3

Level 3 establishes:

ReasoningXray’s core differentiator —
transforming longitudinal clinical reasoning into patient-level cognitive clarity.

This is the first layer where the product becomes:

psychologically useful

clinically respectful

legally safer

structurally scalable

Level 4 onward must improve trust and readability — not change reasoning truth representation.
