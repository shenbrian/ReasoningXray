Status: Reference — pre-recovery design context

🧠 ReasoningXray Phase 2
Language Layer Pilot Execution Plan (MVP)
1. Pilot Mission
Validate that the Language Layer can safely preserve epistemic perception across languages under real rendering conditions.
This pilot is NOT about:
translation quality
UI polish
linguistic elegance
scaling to many languages
It is about:
Can the system prevent trust-distorting epistemic drift?
2. Pilot Scope Boundary
Included
English → Mandarin only
Gold Calibration Sentence Set
Deterministic scoring + rewrite pipeline
Fallback templates
Human perception validation
Logging & audit trace
Excluded
personalization
adaptive learning
long narrative translation
multilingual UI rollout
ML-based scoring
patient deployment
This is internal product validation.
3. Build Order (Recommended Sequence)
Pilot must follow strict layering.
Step 1 — Implement Signal Carrier Extraction
Goal:
ensure every presentation segment has correct epistemic envelope metadata
Checkpoint:
sample trajectories produce stable carrier objects
no ambiguity in envelope assignment
Risk if skipped:
Language Layer will be tuning against incorrect targets.
Step 2 — Implement Mandarin Micro-Signal Tables
Goal:
load modal / temporal / authority / emotional tables
validate rule lookup works deterministically
Checkpoint:
scoring engine can detect CSS / TPS / AGS / ETS deltas on test sentences
Step 3 — Implement Epistemic Scoring Engine
Goal:
produce consistent perception scores across Gold Set
Checkpoint:
hard drift sentences exceed envelope
gold sentences remain inside envelope
This is the first real architecture stress point.
Step 4 — Implement Guardrail Validator + Rewrite Loop
Goal:
soft drift corrected within max rewrite attempts
hard drift escalates to fallback
Checkpoint:
rewrite success rate measurable
no infinite rewrite loops
Step 5 — Implement Fallback Resolver
Goal:
safe template substitution works
trajectory meaning preserved
Checkpoint:
fallback sentences judged neutral and believable
Step 6 — Implement Audit Logging
Goal:
capture full render decision trace
Checkpoint:
logs allow reconstruction of drift detection event
envelope violations visible
This becomes future safety infrastructure.
4. Calibration Phase (Human Review Loop)
Once pipeline is functional:
Phase A — Internal Linguistic Review
Participants:
bilingual clinicians
medically literate native Mandarin speakers
Tasks:
rate perceived certainty
rate perceived authority
rate emotional tone
compare English vs Mandarin perception
Output:
adjust scoring weights
adjust forbidden pattern list
refine fallback templates
Phase B — Blind Trust Simulation
Participants:
lay Mandarin speakers
They only see localized sentences.
They rate:
“Does this sound like a diagnosis?”
“Does this sound final?”
“Does this sound reassuring?”
“Does this sound like a doctor speaking?”
Goal:
Detect unintended trust escalation.
Phase C — Drift Stress Tests
Simulate worst-case scenarios:
aggressive translation variants
compressed sentences
removed modal particles
emotional lexical substitution
System must:
detect
rewrite
fallback
or block
5. Pilot Metrics
Pilot must define quantitative success thresholds.
Architecture Metrics
Hard drift detection accuracy ≥ 95%
Soft drift rewrite success ≥ 75–80%
Rewrite latency acceptable (e.g., <150 ms segment level)
Fallback activation rate reasonable (e.g., 5–15%)
Perception Metrics
Certainty perception variance English vs Mandarin ≤ tolerance band
Authority perception stable
Emotional neutrality maintained
Governance Metrics
No unsafe sentence reaches final render in Gold Set
Audit trace completeness = 100%
6. Release Gating Criteria
Language Layer Phase 2 pilot is considered successful only if:
Mandarin rendering passes Gold Calibration Set
Clinician reviewers confirm neutrality preserved
Drift failure classes demonstrably mitigated
Rewrite + fallback pipeline stable
No authority inflation patterns remain
Temporal promise drift materially reduced
Only after these gates:
→ proceed to second stress language (e.g., Japanese)
7. Strategic Insight
If Phase 2 pilot succeeds:
ReasoningXray gains a rare product property:
Linguistic trust portability.
Meaning:
reasoning structure survives cultural translation
medico-legal posture strengthens
global deployment risk decreases
differentiation vs generic AI summarizers increases
Most AI products fail silently here.
8. What Comes After Pilot
Next calm structural step will be:
👉 Design Phase 2.5 — Cross-Sentence Coherence Layer
Because once single-sentence epistemic safety is stable:
New risks appear:
paragraph-level certainty accumulation
narrative tone drift
repeated reassurance effect
trajectory misreading across segments
But this must NOT be built before pilot validation.
Phase 2 Status
You now have:
full architecture
language pack spec
calibration instrumentation
implementation blueprint
pilot execution plan
This is a complete Phase 2 MVP design system.
If you wish, we can now:
convert this into a developer task board
or write a Phase 2 Technical Spec document
or begin designing Cross-Sentence Coherence Layer (Phase 2.5)
Where would you like to go next?
