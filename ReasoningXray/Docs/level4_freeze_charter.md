🧊 ReasoningXray — Level 4 Freeze Charter

Presentation Structuring Layer

Date: 2026-03-12
Status: Frozen
Scope: Patient-facing reasoning presentation architecture

1. Purpose of Level 4

Level 4 establishes the stable presentation contract that converts structured reasoning outputs (Levels 1–3) into:

readable

calm

clinically believable

non-repetitive

non-diagnostic

trust-preserving

patient-facing understanding panels.

Level 4 does not introduce new reasoning.
Level 4 does not modify clinical meaning.

It governs how reasoning is shown.

2. Frozen Architectural Components
2.1 Panel hierarchy (final order)

Quick Summary

Doctor’s Current View

Current Understanding / Still Uncertain / Next Likely Step

Reasoning Watchpoints (prioritized)

Turning Points (compressed narrative form)

Reasoning Timeline (progressive disclosure)

This ordering is now structurally fixed.

2.2 Trajectory presentation compaction rules

Trajectory panel visibility and section density are governed by:

duplication suppression via normalized semantic comparison

implication suppression when informational gain is low

certainty section suppression

full panel suppression when trajectory adds no new signal beyond summary + confidence

These rules form the TrajectoryPresentationPolicy contract.

2.3 Confidence signal placement

Confidence trajectory is:

no longer an independent panel

integrated into Doctor’s Current View

expressed in compressed declarative phrasing
(e.g., “Confidence increasing.”)

This decision is frozen.

2.4 Watchpoints density governance

Watchpoints presentation contract:

surface only top-priority reasoning signals

collapse secondary signals into summary line

preserve full detail only in timeline expansion

This establishes the Interpretation Density Governance rule.

2.5 Turning-points narrative compression

Turning-points panel now shows:

factual turning-point chain

one synthesized reasoning trajectory narrative

Removal of stacked meta-interpretation layers is intentional and frozen.

2.6 Timeline progressive disclosure model

Timeline cards default state:

date

stage pill

turning-point badge

one-line visit summary

decision

Expanded state reveals:

reasoning movement explanation

pivot banner

turning-point reasoning explanation

Expansion state governed by:

expandedVisitIDs

This establishes the Reasoning Discoverability Interaction Model.

2.7 Typography hierarchy

Final typography contract:

Panel titles → .headline

Section titles → .subheadline.weight(.semibold)

Explanatory body → .subheadline + .secondary

Trust / meta signals → .caption / .footnote

Typography rhythm is now frozen as part of cognitive pacing design.

3. Design Principles Locked at Level 4

Level 4 presentation must remain:

selective rather than exhaustive

narrative rather than analytic

calm rather than assertive

structured rather than conversational

explanatory rather than advisory

ReasoningXray organizes thinking.
It does not replace medical authority.

4. What Level 4 Freeze Means

After this freeze:

No new panels

No major section reorder

No new reasoning interpretations

No layout redesign

No trajectory logic changes

Only allowed:

micro-trust signalling

epistemic clarity cues

interaction refinement

uncertainty visualization

behavioural guidance framing

These belong to Level 5.

5. Transition to Level 5

Level 5 focuses on:

signalling what is observed vs inferred

making provisional reasoning visible but non-alarming

guiding user expectations about reasoning evolution

strengthening credibility without increasing cognitive load

Level 5 builds on top of Level 4 structure
—not inside it.

✅ Level 4 Freeze Confirmation

Level 4 Presentation Structuring Layer is considered:

Architecturally stable
UX-coherent
Clinically credible
Ready for trust-layer expansion
