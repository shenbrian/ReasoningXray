# Phase 2 — Language Layer Runtime Freeze Charter

Status: **Frozen Runtime Contract**  
Date: 2026-03-16  

---

## Purpose

Phase 2 establishes a **Translation Fidelity Layer**, not a reasoning layer.

Its responsibility is:

> Preserve clinical epistemic intent while rendering language across cultures.

It must NOT:
- infer new medical meaning
- reinterpret doctor reasoning
- simulate empathy beyond transcript implication
- predict outcomes
- introduce advisory tone

---

## Architectural Position

Clinical Transcript
↓
Reasoning Structure Engine (Phase I)
↓
Language Guardrail Pipeline (Phase II)
↓
Localized Patient Rendering


Language Layer is:

- downstream of reasoning detection  
- upstream of UI presentation  
- stateless across visits  
- session-coherent within rendering pass  

---

## Runtime Components (Current Canonical)

### 1. ReasoningRenderer

Responsibilities:

- creates SignalCarrier
- assigns epistemic domain
- assigns semanticRole
- infers trajectoryState (light heuristic)
- generates score envelopes
- invokes LanguageGuardrailPipeline

Renderer does NOT:
- perform linguistic transformation itself
- store long-term linguistic memory
- modify reasoning trajectory logic

---

### 2. SignalCarrier

SignalCarrier is the **atomic translation unit**.

It contains:

- sourceText  
- domains  
- semanticRole  
- trajectoryState  
- certaintyEnvelope  
- temporalEnvelope  
- authorityEnvelope  
- emotionalEnvelope  

This ensures translation decisions are:

> Epistemically conditioned — not purely lexical.

---

### 3. LanguageGuardrailPipeline

Pipeline responsibilities:

- Mandarin rendering discipline  
- uncertainty tone preservation  
- temporal expectation softening  
- authority calibration  
- emotional neutrality guardrail  

Pipeline must remain:

- deterministic  
- inspectable  
- modular  
- language-pack driven  

---

### 4. LanguageRenderSessionContext

Session provides:

- duplicate phrasing suppression  
- coherence across multiple fields  
- short-range tone stability  

Session must NOT:

- persist beyond single renderVisit call  
- influence reasoning interpretation  

---

## Epistemic Domains (Frozen Set)

- trajectory  
- certainty  
- authority  
- expectation  
- emotionalTone  

No new domains without charter update.

---

## Semantic Roles (Frozen Set)

- summary  
- explanation  
- evidence  
- decision  
- nextStep  
- expectation  

These roles drive tone modulation.

---

## Trajectory States (Language-visible abstraction)

- exploring  
- narrowing  
- workingExplanation  
- confirmation  

Trajectory inference is heuristic and **non-clinical**.

---

## Guardrail Philosophy

Language Layer must:

> Reduce epistemic distortion introduced by translation.

It must NOT:

- optimize reassurance
- optimize persuasion
- optimize compliance
- optimize satisfaction metrics

Clarity > Comfort.

---

## Scope Limits

Phase 2 does NOT include:

- multilingual reasoning comparison  
- cultural behavioral modeling  
- conversational agent responses  
- adaptive tone learning  
- patient personality adaptation  

These are future research directions.

---

## Success Definition

Language layer is successful when:

- translated output preserves uncertainty gradient  
- authority tone matches reasoning stage  
- temporal expectations remain open-ended  
- emotional signal remains neutral-calm  
- no additional clinical meaning is introduced  

---

## Governance Rule

If runtime behavior conflicts with this charter:

> Runtime wins.  
> Charter must be updated.

If docs conflict with runtime:

> Docs are non-canonical until audited.

---

END
