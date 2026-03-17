Status: Superseded — Level6 temporal signal system abandoned

ReasoningXray Level 6 — Temporal Signal State Machine Charter
1. Purpose

This file defines the behavioral control logic for Level 6 temporal micro-signals.

Its role is to ensure temporal guidance is:

stable

minimal

non-reactive

clinically believable

deterministic

This state machine does not detect clinical meaning.
It only governs how an already-detected temporal phenomenon becomes a patient-visible micro-signal.

Level 6 therefore remains:

perception-shaping, not predictive

structurally grounded, not expressive

calm, not dynamic

2. Architectural Position

The Level 6 state machine sits after:

temporal phenomenon detection

dominance resolution

injection eligibility check

and before:

micro-signal phrase selection

patient-visible rendering

So the sequence is:

read Level 1–5 signals

infer candidate temporal phenomena

resolve dominant phenomenon

pass dominant phenomenon into Level 6 state machine

decide whether to show / persist / suppress / transition

emit at most one micro-signal

3. Core Design Principle

Temporal signals should behave more slowly than the underlying reasoning data.

Reasoning may fluctuate.
The temporal layer must not mirror every fluctuation.

Therefore the state machine exists to create:

persistence

damping

silence when needed

gradual transitions

This prevents the system from appearing jumpy, overconfident, or emotionally manipulative.

4. State Model

Level 6 uses five high-level states:

A. silent

No temporal micro-signal is shown.

Used when:

no phenomenon has reached eligibility

confidence in dominance is insufficient

volatility is too high

case is already calm and self-explanatory

a transition buffer is active

B. candidate

A temporal phenomenon has been detected but is not yet eligible for display.

Used when:

a dominant phenomenon is newly detected

persistence threshold not yet met

state machine is observing stability

This is an internal holding state only.

C. active

A temporal micro-signal is currently eligible and visible.

Used when:

one dominant temporal phenomenon is stable

suppression rules are not triggered

signal frequency rules allow rendering

Only one active signal may exist.

D. buffered_transition

A previous active signal has ended, but the next one should not appear immediately.

Used when:

dominant phenomenon changed materially

oscillation risk is present

silence is preferable before new framing appears

This creates a deliberate quiet gap.

E. suppressed

A signal could be inferred, but Level 6 intentionally withholds it.

Used when:

trajectory already feels sufficiently clear

trust layer already carries enough epistemic framing

confirmation or closure states make temporal commentary unnecessary

volatility is too high for patient-facing temporal framing

Suppressed differs from silent because the system has something it could say, but chooses not to.

5. Inputs to the State Machine

The state machine may read only:

dominant temporal phenomenon

phenomenon stability count

prior visible phenomenon

prior rendered signal id

trajectory path

certainty trend

momentum

active uncertainty flag

epistemic status

volatility / stability semantics from Level 5

turning point presence

visit spacing pattern

current render count or visit index

It must not read:

symptoms

diagnoses

tests

treatments

freeform medical content

6. Eligibility Rules

A candidate phenomenon becomes eligible for activation only if all conditions hold:

Eligibility Gate 1 — Dominance Stability

Dominant phenomenon remains unchanged for at least 2 consecutive visits

Exception:

accelerationWindow may activate after 1 visit if tied to a clear turning point spike

Eligibility Gate 2 — Volatility Check

Do not activate if:

epistemic state is highly volatile

dominance has flipped recently

multiple competing phenomena are near-equal

Eligibility Gate 3 — Suppression Check

Do not activate if:

case is in calm stable confirmation

uncertainty is minimal and trajectory already self-explanatory

a strong Level 5 trust signal already adequately frames the case

a recent signal was just removed and buffer is active

Eligibility Gate 4 — Frequency Check

Do not activate if:

identical phenomenon was just shown in the immediately previous render without sufficient spacing

phrase repetition would feel mechanical

7. Entry Rules
silent → candidate

Enter when a dominant temporal phenomenon first appears.

candidate → active

Enter when:

stability threshold met

no suppression condition present

no transition buffer active

candidate → silent

Return when:

dominance disappears

competing signals destabilize the candidate

case becomes too clear to require temporal cueing

active → buffered_transition

Enter when:

dominant phenomenon materially changes

existing signal should retire

immediate replacement would feel abrupt

active → suppressed

Enter when:

clarity rises enough that temporal framing becomes unnecessary

trust/trajectory layer already does sufficient work

case enters stable calm confirmation / closure pattern

buffered_transition → candidate

Enter when new dominant phenomenon remains stable during buffer window.

buffered_transition → silent

Enter when no stable replacement emerges.

suppressed → candidate

Enter when a new temporal phenomenon later becomes relevant again.

8. Persistence Rules

Once a signal becomes active, it should persist longer than the raw inputs.

Default persistence rule:

retain the active phenomenon for at least 2 renders / visits

unless a hard interruption occurs

This prevents rapid micro-shifts in wording.

Hard interruption conditions

Active signal may terminate early only if:

strong turning point detected

re-exploration loop triggered

acceleration window emerges

case moves into suppression-worthy clarity

9. Transition Buffer Rule

When moving from one active phenomenon to another, apply a silence buffer.

Default:

1 render / visit buffer

Purpose:

avoid “now this, now that” feeling

preserve calmness

reduce interpretive noise

Exception:
No buffer required when moving into accelerationWindow after a clear turning point spike.

10. Suppression Rules

The state machine must suppress visible temporal signals under these conditions:

A. Stable Confirmation Suppression

If the case is in stable confirmation with low uncertainty and low volatility, do not show temporal cue.

Reason:
The trajectory already communicates sufficient coherence.

B. Redundant Trust Framing Suppression

If the Level 5 trust signal is already strong, calm, and semantically sufficient, avoid adding a temporal cue unless it adds distinct value.

C. High Noise Suppression

If oscillation is too unstable to frame responsibly, prefer silence over rapidly changing temporal guidance.

D. Closure-Like Calm Suppression

If the case appears settled and no longer benefits from expectation framing, withhold signal.

11. Silence Doctrine

Silence is a valid output.

Level 6 should not attempt to explain every temporal pattern.

Silence is preferred when:

interpretation would be weak

patient benefit is marginal

the signal would be repetitive

the case already feels temporally legible

Design principle:

A missing signal should feel natural, not absent.

12. Dominance Arbitration Rule

If multiple phenomena are inferred, the state machine receives one dominant phenomenon from the dominance resolver.

Default hierarchy:

accelerationWindow

reExplorationLoop

oscillation

consolidation

narrowing

stabilization

monitoringPlateau

However, the state machine may still refuse display if the dominant phenomenon fails eligibility or suppression checks.

So:

dominance does not guarantee visibility

visibility is governed by state discipline

13. Phrase Rotation Rule

When a state is active, the emitted micro-signal phrase must rotate slowly.

Rules:

do not repeat the exact same phrase in consecutive renders

keep phrasing within the same phenomenon family

preserve semantic continuity

avoid sounding dynamic or personalized

Rotation should feel like mild variation, not novelty.

14. Oscillation Protection Rule

If underlying phenomenon candidates are changing too often, the state machine must dampen output.

Default protection:

if dominant phenomenon changes across consecutive visits more than once in a short window, enter silent or suppressed

do not alternate patient-visible signals rapidly

This is critical.

The app must never appear to be “changing its mind” about time-sense.

15. Output Contract

At each render, Level 6 may emit exactly one of the following:

no signal

one temporal micro-signal phrase tied to one active phenomenon

It may never emit:

multiple temporal signals

explanation paragraphs

future-oriented claims

timeline predictions

action advice

16. Success Criteria

This state machine is successful if:

temporal signals appear rarely but meaningfully

they persist long enough to feel intentional

they disappear when unnecessary

they do not flip rapidly with trajectory noise

they never imply forecasting

silence feels disciplined rather than incomplete

17. Freeze Standard for Concept Layer

Level 6 conceptual design is ready for implementation only when all seven documents now cohere:

temporal phenomena taxonomy

signal extraction rules

micro-signals vocabulary

discipline rules

injection strategy

temporal signal state machine

later: implementation mapping note

Once this file is added, the conceptual charter for Level 6 is effectively complete.

18. Implementation Note

When implementation begins, the Swift layer should likely model this with:

a small enum for temporal phenomenon

a small enum for signal state

a persistence tracker per thread

last-rendered phenomenon memory

last-rendered phrase id memory

suppression helper rules

But implementation should come only after this charter is accepted as frozen.

This is the last major concept file before coding. The next clean step is to produce a Level 6 freeze charter once you save this and confirm the doc pack is complete.
