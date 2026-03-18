ReasoningXray Level 6 — Implementation Mapping Note
1. Purpose
This document translates the frozen Level 6 concept layer into an implementation-ready Swift integration plan.
Its purpose is to define:
what new model types are needed
what minimal store/state additions are needed
where inference should happen
how render decisions should be made
how Level 6 integrates without disturbing Levels 1–5
This is not yet the final code.
It is the bridge from charter to implementation.
2. Implementation Principle
Level 6 should be implemented as a thin deterministic layer on top of existing trajectory logic.
It must:
reuse Level 2, 3, and 5 outputs
avoid new clinical interpretation
avoid new panel hierarchy
emit at most one patient-visible temporal micro-signal
remain easy to disable or freeze independently
So implementation should be:
small
explicit
composable
thread-based
testable in isolation
3. Proposed New Swift Types
A. TemporalPhenomenon
Represents the dominant temporal pattern inferred from existing reasoning/trajectory signals.
Suggested enum:
enum TemporalPhenomenon: String, Codable {
    case stabilization
    case narrowing
    case oscillation
    case consolidation
    case monitoringPlateau
    case accelerationWindow
    case reExplorationLoop
}
B. TemporalSignalState
Represents the Level 6 visibility/governance state.
Suggested enum:
enum TemporalSignalState: String, Codable {
    case silent
    case candidate
    case active
    case bufferedTransition
    case suppressed
}
C. TemporalMicroSignal
Represents one renderable patient-facing signal.
Suggested struct:
struct TemporalMicroSignal: Identifiable, Codable, Equatable {
    let id: String
    let phenomenon: TemporalPhenomenon
    let phrase: String
}
id should be stable enough to support anti-repetition logic.
D. TemporalSignalContext
A compact internal input bundle assembled from existing Levels 2–5 outputs.
Suggested struct:
struct TemporalSignalContext {
    let threadID: UUID
    let trajectoryPath: CaseTrajectoryPath?
    let certaintyTrend: CertaintyTrend?
    let momentum: TrajectoryMomentum?
    let activeUncertainty: Bool
    let epistemicStatus: TrajectoryEpistemicStatus?
    let hasTurningPoint: Bool
    let reasoningChangeCount: Int
    let visitIntervals: [TimeInterval]
}
Exact type names should match your current codebase.
E. TemporalSignalMemory
This is the persistence tracker for one thread.
Suggested struct:
struct TemporalSignalMemory: Codable {
    let lastPhenomenon: TemporalPhenomenon?
    let lastSignalID: String?
    let state: TemporalSignalState
    let stabilityCount: Int
    let activeRenderCount: Int
    let bufferRemaining: Int
}
This is critical for damping and transition control.
4. Suggested New Helper Components
To keep Level 6 clean, implementation should likely be split into four small helpers.
A. TemporalPhenomenonDetector
Responsibility:
read Level 2–5 outputs
infer candidate phenomena
resolve dominant phenomenon
Suggested methods:
struct TemporalPhenomenonDetector {
    func detect(from context: TemporalSignalContext) -> TemporalPhenomenon?
}
Internally this can call smaller rule helpers such as:
isStabilization(...)
isNarrowing(...)
isOscillation(...)
This logic should mirror the frozen signal extraction rules.
B. TemporalSignalStateMachine
Responsibility:
apply state transitions
persistence thresholds
buffer logic
suppression logic
Suggested interface:
struct TemporalSignalStateMachine {
    func nextMemory(
        current memory: TemporalSignalMemory?,
        dominantPhenomenon: TemporalPhenomenon?,
        context: TemporalSignalContext
    ) -> TemporalSignalMemory
}
This helper should not choose phrases.
It only decides visibility behavior.
C. TemporalMicroSignalSelector
Responsibility:
select a phrase for the active phenomenon
rotate phrases slowly
avoid exact repetition
Suggested interface:
struct TemporalMicroSignalSelector {
    func selectSignal(
        for phenomenon: TemporalPhenomenon,
        previousSignalID: String?
    ) -> TemporalMicroSignal?
}
Phrase banks should be static and minimal.
D. TemporalSignalRendererAdapter
Responsibility:
expose a lightweight view-facing API
return the optional signal to the UI layer
Suggested interface:
struct TemporalSignalRendererAdapter {
    func visibleSignal(
        memory: TemporalSignalMemory,
        phenomenon: TemporalPhenomenon?,
        previousSignalID: String?
    ) -> TemporalMicroSignal?
}
Depending on your existing store structure, this adapter may be unnecessary if handled directly in the store.
5. Best Integration Point in Existing Architecture
The cleanest place is likely inside ReasoningHistoryStore.
Why:
thread-level trajectory information already lives there
Level 3 and Level 5 outputs are already being assembled there
Level 6 depends on cross-visit state, which belongs in the store rather than the view
Recommended additions:
@Published private var temporalSignalMemoryByThread: [UUID: TemporalSignalMemory] = [:]
@Published private var temporalSignalByThread: [UUID: TemporalMicroSignal] = [:]
These should remain private unless view access requires exposure helpers.
6. Suggested Store-Level API
Add small read APIs similar to your existing trajectory/trust methods.
Examples:
func temporalMicroSignal(for threadID: UUID) -> TemporalMicroSignal?
func temporalSignalState(for threadID: UUID) -> TemporalSignalState?
func temporalPhenomenon(for threadID: UUID) -> TemporalPhenomenon?
For UI use, the first method may be enough initially.
7. Suggested Evaluation Flow
For each thread:
Step 1 — Build context
Assemble TemporalSignalContext from existing Level 2–5 data.
Step 2 — Detect dominant phenomenon
Run detector to get TemporalPhenomenon?.
Step 3 — Advance state machine
Read prior memory for the thread and compute updated memory.
Step 4 — Select visible signal
Only if new memory state is .active.
Step 5 — Store result
Persist updated memory and current visible signal.
This may happen:
lazily on access
or eagerly when threads/visits refresh
Given your architecture, eager recomputation inside store refresh/update is probably cleaner.
8. Minimal View Integration Strategy
Do not create a new panel.
Inject the signal exactly where the Level 6 charter specified:
Primary target:
existing trajectory presentation panel footer
Suggested pattern inside the relevant SwiftUI view:
if let signal = store.temporalMicroSignal(for: thread.id) {
    Text(signal.phrase)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.top, 4)
}
This is intentionally light.
No icon.
No divider required unless visual testing proves necessary.
No header label.
9. Recommended Phrase Bank Structure
Keep phrase bank static and code-local at first.
Example:
private let phraseBank: [TemporalPhenomenon: [TemporalMicroSignal]] = [
    .stabilization: [
        TemporalMicroSignal(id: "stab_1", phenomenon: .stabilization, phrase: "Reasoning is being observed over time."),
        TemporalMicroSignal(id: "stab_2", phenomenon: .stabilization, phrase: "Consistency is being checked."),
        TemporalMicroSignal(id: "stab_3", phenomenon: .stabilization, phrase: "Less visible change can still be meaningful.")
    ],
    ...
]
Do not externalize to JSON yet.
This layer is still trust-sensitive and easier to govern in code during initial freeze.
10. State Machine Defaults
Recommended initial defaults:
candidate stability threshold: 2
active minimum persistence: 2
transition buffer: 1
acceleration window fast-path threshold: 1
suppression on high volatility: true
These should be constants, not runtime-configurable, during initial implementation.
Example:
enum TemporalSignalConfig {
    static let stabilityThreshold = 2
    static let minimumActivePersistence = 2
    static let transitionBufferLength = 1
    static let accelerationFastPathThreshold = 1
}
11. Suggested Storage Semantics
Level 6 memory should be thread-scoped, not visit-scoped.
Why:
the layer is about trajectory rhythm, not single-visit description
persistence and transition require historical continuity
So the primary key should be:
thread.id
not individual visit IDs.
12. Test Scenario Requirements
Before UI testing, create deterministic test cases for at least these scenarios:
A. Stabilization activation
narrowing / working diagnosis
mild certainty increase
low change density across two visits
signal enters after threshold
B. Oscillation suppression
competing fluctuating signals
dominance instability
output remains silent
C. Acceleration fast-path
turning point spike
rapid certainty increase
acceleration signal appears without waiting two visits
D. Transition buffering
active stabilization
then dominant shift to consolidation
one render silent buffer
then consolidation appears
E. Stable confirmation silence
high clarity
low uncertainty
strong trust signal
no temporal output rendered
These tests matter more than visual polish.
13. Recommended File-Level Placement
A clean initial placement could be:
Models/TemporalPhenomenon.swift
Models/TemporalSignalState.swift
Models/TemporalMicroSignal.swift
Models/TemporalSignalMemory.swift
Reasoning/TemporalPhenomenonDetector.swift
Reasoning/TemporalSignalStateMachine.swift
Reasoning/TemporalMicroSignalSelector.swift
Or, if the project is still small, these can temporarily live under the same reasoning/engine folder as Level 2–5 logic.
The key rule is:
keep Level 6 logic out of SwiftUI views except final rendering.
14. Non-Goals for First Implementation Pass
Do not add, in the first pass:
animations
patient personalization
hover/tap reveal expansions
timeline node captions
adaptive phrase sentiment
analytics-driven tuning
localization complexity beyond current app baseline
First pass goal:
one calm footer signal, deterministic and sparse.
15. Safe Implementation Order
Recommended coding order:
Phase 1
Create model enums/structs.
Phase 2
Implement TemporalPhenomenonDetector.
Phase 3
Implement TemporalSignalStateMachine.
Phase 4
Implement TemporalMicroSignalSelector.
Phase 5
Wire Level 6 into ReasoningHistoryStore.
Phase 6
Expose temporalMicroSignal(for:).
Phase 7
Inject single footer text into trajectory panel.
Phase 8
Run deterministic scenario testing.
This order minimizes UI confusion.
16. Done Condition
Level 6 implementation mapping is complete when the team can answer all of the following unambiguously:
what data Level 6 reads
what new types exist
where memory is stored
how dominant phenomenon is inferred
how visibility is governed
where one signal appears in UI
what first-pass tests prove correctness
This document now defines those answers.
17. Status
Level 6 is now ready for code implementation planning.
The next clean move is:
👉 convert this mapping into a step-by-step coding plan tied to your actual files and current Swift type names.
