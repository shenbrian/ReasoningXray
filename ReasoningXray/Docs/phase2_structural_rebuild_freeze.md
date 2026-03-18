# ReasoningXray — Phase 2 Structural Rebuild Freeze
**Date:** 2026-03-18  
**Status:** Frozen  
**Scope:** English-only runtime stabilisation + structural reasoning visibility upgrade

---

## 1. Why this freeze exists

Phase 2 drifted into unstable peripheral work and lost alignment with ReasoningXray’s core purpose.

This freeze locks the recovery work that restored the app to the correct path:
- stable runtime
- cleaner reasoning presentation
- stronger separation between doctor reasoning and patient understanding
- reduced view-level guesswork
- no active bilingual interference in the main flow

---

## 2. Core product promise (locked)

ReasoningXray exists to:

1. record doctor reasoning
2. render it into:
   - **Doctor Reasoning Mirror**
   - **Patient Understanding structure**
3. without changing clinical meaning

This promise overrides peripheral feature work.

---

## 3. What is now frozen

### 3.1 Runtime posture
- Runtime target is effectively **English-only**
- Active bilingual behavior is paused
- `ClinicalFaithfulTranslator` is inert passthrough only
- No phrase-bank runtime logic may be reintroduced into active screens

### 3.2 Doctor Reasoning Mirror
The detail screen now includes a structured Doctor Reasoning Mirror showing:
- Current Path
- Reasoning Movement
- Certainty Trend
- Uncertainty vs stabilising state
- Working Explanation
- Recent Turning Point
- Reasoning Course So Far

### 3.3 Patient Understanding structure
Patient-facing meaning remains structured into:
- What This Means For You
- Reassurance
- What To Expect Next
- Decision Safety

### 3.4 Watchpoint rendering
Watchpoint meaning is now store-driven rather than view-guessed.

### 3.5 Thread list signal
Thread cards now expose compact structural reasoning signals.

---

## 4. Files frozen in this block

- `ReasoningXray/Views/ThreadDetailView.swift`
- `ReasoningXray/Views/ThreadCardView.swift`
- `ReasoningXray/Stores/ReasoningHistoryStore.swift`
- `ReasoningXray/Language/ClinicalFaithfulTranslator.swift`

---

## 5. What must not happen next

The following are explicitly blocked unless a later phase is opened deliberately:

### Blocked
- reintroducing active Chinese or bilingual runtime paths into current main screens
- restoring dictionary-based runtime translation banks
- view-level language branching for core reasoning panels
- speculative redesign of store / trajectory architecture
- adding cosmetic UI work that weakens reasoning visibility
- mixing patient-facing simplification into doctor-facing reasoning mirror

### Also blocked
- any feature work that dilutes the distinction between:
  - doctor reasoning evolution
  - patient understanding structure

---

## 6. What this phase achieved

This rebuild restored ReasoningXray to the correct product identity:

- not a generic summary app
- not a translation experiment
- not a note beautifier

But a:
- **reasoning visibility instrument**
- showing how clinical thinking evolves across visits
- while preserving a separate patient-understanding layer

This is the main source of product effectiveness, uniqueness, and defensibility.

---

## 7. Engineering doctrine for this freeze

This block follows the **principle of least action**:

- minimal change surface
- no unnecessary architecture rewrite
- maximum recovery of core product value
- reduced runtime complexity
- reduced UI noise
- direct reinforcement of reasoning structure

Future work should preserve this discipline.

---

## 8. Next-phase entry rule

Any next phase after this freeze must satisfy both:

1. it strengthens the core promise of ReasoningXray  
2. it does not reintroduce unstable peripheral complexity into the active runtime path

If a proposed change does not clearly improve reasoning visibility or patient-understanding fidelity, it should be deferred.

---

## 9. Freeze judgment

Phase 2 Structural Rebuild is accepted as complete when:
- build is clean
- main screens are stable
- Doctor Reasoning Mirror is structurally readable
- Patient Understanding structure remains intact
- watchpoints are store-driven
- no active bilingual runtime interference remains on the repaired path

**Judgment:** Accepted and frozen.
