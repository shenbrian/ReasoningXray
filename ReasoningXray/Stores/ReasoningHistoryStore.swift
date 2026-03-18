import Foundation
import Combine

struct VisitReasoningComparison: Identifiable {
    let id = UUID()
    let previousVisit: Visit?
    let currentVisit: Visit
    let changes: [ReasoningChange]
    let movement: ReasoningMovement
    let stage: ReasoningStage
    let turningPoint: ReasoningTurningPoint?
}

struct WatchpointPresentation {
    let title: String
    let body: String
}

struct ReasoningSignalPresentation: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let emphasis: ReasoningSignalEmphasis
}

struct EvidenceDependencePresentation {
    let title: String
    let summary: String
    let acrossVisits: String
    let nextEvidence: String
    let emphasis: ReasoningSignalEmphasis
}

struct TrajectorySummaryPresentation {
    let title: String
    let summary: String
    let readingNote: String
    let emphasis: ReasoningSignalEmphasis
}

struct LongitudinalContinuityPresentation {
    let title: String
    let summary: String
    let stabilityAnchor: String
    let recentMovement: String
    let nextMeaningfulShift: String
    let steps: [ContinuityStepPresentation]
}

struct ContinuityStepPresentation: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let emphasis: ReasoningSignalEmphasis
}

enum ReasoningSignalEmphasis {
    case neutral
    case caution
    case stable
}

final class ReasoningHistoryStore: ObservableObject {
    
    struct State: Codable {
        let threads: [CaseThread]
        let visits: [Visit]
    }
    
    @Published var visits: [Visit]
    @Published var threads: [CaseThread]
    
    @Published var displayLanguage: DisplayLanguage = .english
    @Published var mirrorLanguageMode: MirrorLanguageMode = .sourceOnly
    
    var renderPreferences: ReasoningRenderPreferences {
        get {
            ReasoningRenderPreferences(
                displayLanguage: .english,
                mirrorLanguageMode: mirrorLanguageMode
            )
        }
        set {
            displayLanguage = .english
            mirrorLanguageMode = newValue.mirrorLanguageMode
        }
    }
    
    private let renderer = ReasoningRenderer()
    private let detector = ReasoningChangeDetector()
    private let movementMapper = ReasoningMovementMapper()
    private let stageDetector = ReasoningStageDetector()
    private let turningPointDetector = ReasoningTurningPointDetector()
    private let workingExplanationDetector = WorkingExplanationDetector()
    private let confidenceDetector = ConfidenceTrajectoryDetector()
    private let shiftDetector = ReasoningShiftDetector()
    private let watchpointDetector = ReasoningWatchpointDetector()
    private let trajectoryEngine = CaseTrajectoryEngine()
    private let patientTrajectoryTranslator = PatientTrajectoryTranslator()
    private let trustSignalMapper = TrustSignalMapper()
    
    init() {
        if let saved = ReasoningPersistence.load() {
            self.threads = saved.threads
            self.visits = saved.visits
        } else {
            self.visits = MockReasoningData.visits
            self.threads = MockReasoningData.threads
        }
        
        self.displayLanguage = .english
        self.mirrorLanguageMode = .sourceOnly
    }
    
    func longitudinalContinuityPresentation(for thread: CaseThread) -> LongitudinalContinuityPresentation? {
        guard let latestComparison = comparisons(for: thread).last else {
            return nil
        }
        
        let signals = reasoningSignals(for: thread)
        let stabilityAnchor = continuityAnchor(for: latestComparison)
        let recentMovement = continuityMovement(for: latestComparison)
        let nextMeaningfulShift = nextEvidenceStep(for: latestComparison)
        
        let steps: [ContinuityStepPresentation] = Array(signals.prefix(3)).enumerated().map { offset, signal in
            ContinuityStepPresentation(
                title: "Progression step \(offset + 1)",
                body: signal.body,
                emphasis: signal.emphasis
            )
        }
        
        return LongitudinalContinuityPresentation(
            title: "Reasoning continuity",
            summary: continuitySummary(for: latestComparison),
            stabilityAnchor: stabilityAnchor,
            recentMovement: recentMovement,
            nextMeaningfulShift: nextMeaningfulShift,
            steps: steps
        )
    }
    
    func trajectorySummary(for thread: CaseThread) -> TrajectorySummaryPresentation {
        let comparisons = comparisons(for: thread)
        
        guard let latest = comparisons.last else {
            return TrajectorySummaryPresentation(
                title: "Reasoning trajectory",
                summary: "Only one visit is available, so there is not yet a visible reasoning path across time.",
                readingNote: "This section becomes more useful when there are multiple visits to compare.",
                emphasis: .neutral
            )
        }
        
        return TrajectorySummaryPresentation(
            title: "Trajectory snapshot",
            summary: patientTrajectorySummary(for: latest),
            readingNote: patientTrajectoryReadingNote(for: latest),
            emphasis: emphasis(for: latest)
        )
    }
    
    func reasoningSignals(for thread: CaseThread) -> [ReasoningSignalPresentation] {
        guard let comparison = latestComparison(for: thread) else {
            return []
        }
        
        var items: [ReasoningSignalPresentation] = []
        
        if let turningPoint = comparison.turningPoint {
            items.append(
                ReasoningSignalPresentation(
                    title: "Recent change in direction",
                    body: readableTurningPointSummary(for: turningPoint),
                    emphasis: .caution
                )
            )
        }
        
        switch comparison.stage {
        case .exploration:
            items.append(
                ReasoningSignalPresentation(
                    title: "Reasoning still early",
                    body: "The picture is still forming, so later information may change how today’s reasoning is interpreted.",
                    emphasis: .neutral
                )
            )
        case .narrowing:
            items.append(
                ReasoningSignalPresentation(
                    title: "Reasoning is narrowing",
                    body: "The reasoning is becoming more focused, though it is still being read as provisional rather than final.",
                    emphasis: .neutral
                )
            )
        case .workingExplanation:
            items.append(
                ReasoningSignalPresentation(
                    title: "Working explanation is taking shape",
                    body: "A clearer line of interpretation is visible across visits, but it still depends on how later evidence fits.",
                    emphasis: .stable
                )
            )
        case .confirmation:
            items.append(
                ReasoningSignalPresentation(
                    title: "Reasoning is becoming more settled",
                    body: "The line of reasoning appears more internally consistent across visits, while still remaining open to revision if new evidence appears.",
                    emphasis: .stable
                )
            )
        }
        
        if comparison.changes.contains(where: { "\($0.kind)".lowercased().contains("evidence") }) {
            items.append(
                ReasoningSignalPresentation(
                    title: "Current reading depends on available evidence",
                    body: "The present interpretation may shift if new test results, follow-up findings, or response over time changes the evidence picture.",
                    emphasis: .neutral
                )
            )
        }
        
        if watchpoints(for: thread).isEmpty == false {
            items.append(
                ReasoningSignalPresentation(
                    title: "Open watchpoints remain",
                    body: "Some parts of the case still need careful follow-through before the current reading can feel more settled.",
                    emphasis: .neutral
                )
            )
        }
        
        return Array(deduplicatedReasoningSignals(items).prefix(4))
    }
    
    func reasoningConsistencySummary(for thread: CaseThread) -> String {
        guard let comparison = latestComparison(for: thread) else {
            return "There is not yet enough visit-to-visit information to describe a reasoning pattern."
        }
        
        return continuitySummary(for: comparison)
    }
    
    func visitCountSummary(for thread: CaseThread) -> String {
        let count = visits.filter { $0.caseThreadId == thread.id }.count
        
        switch count {
        case 0:
            return "This thread does not yet show linked clinical visits."
        case 1:
            return "This reasoning view reflects 1 clinical visit."
        default:
            return "This reasoning view reflects \(count) clinical visits."
        }
    }
    
    func reasoningEvidenceStatus(for thread: CaseThread) -> ReasoningEvidenceStatus {
        let comps = comparisons(for: thread)
        
        guard let latest = comps.last else {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "No reasoning pattern has been established yet."
            )
        }
        
        if comps.count == 1 {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "Only one visit is available, so the reasoning picture is still early."
            )
        }
        
        if latest.turningPoint != nil {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "The interpretation has shifted across visits as new information appeared."
            )
        }
        
        if latest.changes.isEmpty {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "The reasoning looks relatively steady across recent visits."
            )
        }
        
        return ReasoningEvidenceStatus(
            title: "Evidence status",
            body: "The overall direction is becoming clearer, but it still depends on how later evidence fits."
        )
    }
    
    func evidenceDependence(for thread: CaseThread) -> EvidenceDependencePresentation {
        guard let comparison = latestComparison(for: thread) else {
            return EvidenceDependencePresentation(
                title: "Reasoning is still forming",
                summary: "This view reflects an early working interpretation. With limited history, the picture may change as more evidence becomes available.",
                acrossVisits: "There is not yet enough cross-visit history to judge whether the reasoning is stabilising or still shifting.",
                nextEvidence: "Future visits, test results, symptom evolution, or response to treatment may materially change the reasoning.",
                emphasis: .caution
            )
        }
        
        return EvidenceDependencePresentation(
            title: "Evidence dependence",
            summary: evidenceSummary(for: comparison),
            acrossVisits: evidenceAcrossVisits(for: comparison),
            nextEvidence: nextEvidenceStep(for: comparison),
            emphasis: evidenceEmphasis(for: comparison)
        )
    }
    
    func reasoningPosture(for thread: CaseThread) -> ReasoningPosture {
        let threadVisits = visits(for: thread)
        
        if threadVisits.count <= 1 {
            return ReasoningPosture(
                title: "Early hypothesis",
                summary: "The doctor’s explanation is still being formed from the available information.",
                isProvisional: true
            )
        }
        
        return ReasoningPosture(
            title: "Working explanation",
            summary: "This shows the doctor’s current leading explanation across visits. It should be read as evolving clinical reasoning, not a final conclusion.",
            isProvisional: true
        )
    }
    
    func reasoningUncertaintyNote(for thread: CaseThread) -> ReasoningUncertaintyNote? {
        let threadVisits = visits(for: thread)
        let trajectory = trajectorySummary(for: thread.id)
        let hasTurningPoint = !comparisons(for: thread).compactMap(\.turningPoint).isEmpty
        
        if threadVisits.count <= 1 {
            return ReasoningUncertaintyNote(
                title: "Uncertainty remains",
                body: "This is still an early stage explanation, so the clinical picture may become clearer over time."
            )
        }
        
        if let trajectory, trajectory.activeUncertainty {
            return ReasoningUncertaintyNote(
                title: "Uncertainty remains",
                body: "Some uncertainty still remains in how the reasoning fits together, so this should not be read as fully settled."
            )
        }
        
        if hasTurningPoint {
            return ReasoningUncertaintyNote(
                title: "Reasoning is still evolving",
                body: "The explanation appears to have shifted across visits, which means the reasoning may still be developing."
            )
        }
        
        return ReasoningUncertaintyNote(
            title: "Clinical interpretation remains provisional",
            body: "This reflects the doctor’s current reasoning across visits, but some uncertainty may still remain until follow-up is complete."
        )
    }
    
    func workingExplanationSummary(for threadID: UUID) -> String? {
        guard let thread = threads.first(where: { $0.id == threadID }) else {
            return nil
        }
        
        guard let explanation = workingExplanation(for: thread) else {
            return nil
        }
        
        let raw = String(describing: explanation).lowercased()
        
        if raw.contains("airway") || raw.contains("asthma") {
            return "The current working explanation appears to be leaning toward an airway-related cause."
        }
        
        if raw.contains("infection") || raw.contains("viral") || raw.contains("bacterial") {
            return "The current working explanation still appears to include an infection-related cause."
        }
        
        if raw.contains("blood pressure") || raw.contains("hypertension") {
            return "The current working explanation appears to remain focused on blood pressure."
        }
        
        if raw.contains("urinary") || raw.contains("uti") || raw.contains("bladder") {
            return "The current working explanation appears to remain focused on a urinary cause."
        }
        
        return "A working explanation appears to be forming, but it is not yet fully settled."
    }
    
    func recentTurningPointSummary(for threadID: UUID) -> String? {
        guard let thread = threads.first(where: { $0.id == threadID }) else {
            return nil
        }
        
        let comps = comparisons(for: thread)
        
        guard let turningPoint = comps.compactMap(\.turningPoint).last else {
            return nil
        }
        
        return readableTurningPointSummary(for: turningPoint)
    }
    
    private func humanReadableValue<T>(_ value: T) -> String {
        let raw = String(describing: value)
        
        if raw.isEmpty {
            return raw
        }
        
        let withSpaces = raw
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "_", with: " ")
        
        return withSpaces.prefix(1).uppercased() + withSpaces.dropFirst()
    }
    
    private func calmStageLabel(from raw: String) -> String {
        let value = raw.lowercased()
        
        if value.contains("early") {
            return "Early reasoning stage"
        } else if value.contains("develop") {
            return "Developing reasoning stage"
        } else if value.contains("refin") {
            return "Refining reasoning stage"
        } else if value.contains("advanc") {
            return "Advanced reasoning stage"
        } else {
            return "Current reasoning stage"
        }
    }
    
    private func calmMovementSummary(from raw: String) -> String {
        let value = raw.lowercased()
        
        if value.contains("strength") || value.contains("settl") {
            return "Reasoning is becoming more settled."
        } else if value.contains("shift") || value.contains("change") {
            return "Reasoning is shifting as the interpretation evolves."
        } else if value.contains("narrow") || value.contains("focus") {
            return "Reasoning is narrowing toward fewer possibilities."
        } else if value.contains("widen") || value.contains("broad") {
            return "Reasoning is keeping alternatives in view."
        } else if value.contains("stable") {
            return "Reasoning is relatively stable across recent visits."
        } else {
            return "The overall direction remains provisional."
        }
    }
    
    private func calmMovementEmphasis(from raw: String) -> ReasoningSignalEmphasis {
        let value = raw.lowercased()
        
        if value.contains("stable") || value.contains("strength") || value.contains("settl") {
            return .stable
        } else if value.contains("shift") || value.contains("change") || value.contains("widen") || value.contains("broad") {
            return .caution
        } else {
            return .neutral
        }
    }
    
    private func readableTurningPointSummary(for turningPoint: ReasoningTurningPoint) -> String {
        let raw = String(describing: turningPoint).lowercased()
        
        if raw.contains("hypothesis") || raw.contains("reconsider") || raw.contains("revision") {
            return "The doctor appears to have reconsidered the earlier explanation."
        }
        
        if raw.contains("test") || raw.contains("result") || raw.contains("investigation") {
            return "New test information appears to have shifted the reasoning."
        }
        
        if raw.contains("narrow") || raw.contains("focus") {
            return "The reasoning appears to have narrowed toward a more specific explanation."
        }
        
        if raw.contains("confirm") || raw.contains("confidence") {
            return "The reasoning appears to have moved toward a more confident explanation."
        }
        
        if raw.contains("monitor") || raw.contains("follow") {
            return "The doctor’s reasoning appears to have shifted into closer monitoring."
        }
        
        return "The doctor’s reasoning appears to have shifted at this stage."
    }
    
    func setDisplayLanguage(_ language: DisplayLanguage) {
        displayLanguage = .english
    }
    
    func setMirrorLanguageMode(_ mode: MirrorLanguageMode) {
        mirrorLanguageMode = mode
    }
    
    func epistemicStatus(for comparison: VisitReasoningComparison) -> EpistemicStatus {
        trustSignalMapper.visitStatus(for: comparison)
    }
    
    func trajectoryEpistemicStatus(for threadID: UUID) -> EpistemicStatus? {
        guard let summary = trajectorySummary(for: threadID) else {
            return nil
        }
        
        return trustSignalMapper.trajectoryStatus(for: summary)
    }
    
    func watchpointEpistemicStatus(for watchpoint: ReasoningWatchpoint) -> EpistemicStatus {
        trustSignalMapper.watchpointStatus(for: watchpoint)
    }
    
    func debugPrintComparisons(for threadID: UUID) {
        guard let thread = threads.first(where: { $0.id == threadID }) else {
            print("No thread found for \(threadID)")
            return
        }
        
        let comparisons = buildComparisons(for: thread)
        
        print("")
        print("===== LEVEL 2 COMPARISONS FOR THREAD \(threadID) =====")
        
        for (index, comparison) in comparisons.enumerated() {
            print("Visit \(index + 1): \(comparison.currentVisit.oneLineVisitSummary)")
            print("movement: \(comparison.movement)")
            print("stage: \(comparison.stage)")
            print("turningPoint: \(String(describing: comparison.turningPoint))")
            
            let changeKinds = comparison.changes.map { "\($0.kind)" }.joined(separator: ", ")
            print("changes: \(changeKinds)")
            print("--------------------------------------")
        }
        
        print("===== END LEVEL 2 COMPARISONS =====")
        print("")
    }
    
    func debugPrintTrajectorySummaries() {
        for summary in caseTrajectorySummaries {
            print("----- Level 3 Trajectory Summary -----")
            print("threadID: \(summary.threadID)")
            print("overallPath: \(summary.overallPath.rawValue)")
            print("certaintyTrend: \(summary.certaintyTrend.rawValue)")
            print("momentum: \(summary.momentum.rawValue)")
            print("activeUncertainty: \(summary.activeUncertainty)")
            print("summary: \(summary.summary)")
            print("")
        }
    }
    
    func debugPrintTrajectoryPresentations() {
        for presentation in caseTrajectoryPresentations {
            let technical = presentation.technical
            let patient = presentation.patient
            
            print("----- Level 3 Trajectory Presentation -----")
            print("threadID: \(technical.threadID)")
            print("overallPath: \(technical.overallPath.rawValue)")
            print("certaintyTrend: \(technical.certaintyTrend.rawValue)")
            print("momentum: \(technical.momentum.rawValue)")
            print("activeUncertainty: \(technical.activeUncertainty)")
            print("summary: \(technical.summary)")
            print("narrativeMeaning: \(patient.narrativeMeaning)")
            print("reassuranceFraming: \(patient.reassuranceFraming)")
            print("forwardExpectation: \(patient.forwardExpectation)")
            print("decisionSafetyFraming: \(patient.decisionSafetyFraming)")
            print("")
        }
    }
    
    func trajectorySummary(for threadID: UUID) -> CaseTrajectorySummary? {
        caseTrajectorySummaries.first { $0.threadID == threadID }
    }
    
    func trajectoryPresentation(for threadID: UUID) -> CaseTrajectoryPresentation? {
        caseTrajectoryPresentations.first { $0.technical.threadID == threadID }
    }
    
    func compressedVisits(for thread: CaseThread, limit: Int = 2) -> (recent: [Visit], earlierCount: Int) {
        let threadVisits = visits
            .filter { $0.caseThreadId == thread.id }
            .sorted { $0.visitDate < $1.visitDate }
        
        guard threadVisits.count > limit else {
            return (threadVisits, 0)
        }
        
        let recent = Array(threadVisits.suffix(limit))
        let earlierCount = threadVisits.count - limit
        
        return (recent, earlierCount)
    }
    
    func reasoningSignalSummary(for threadID: UUID) -> String? {
        guard let presentation = trajectoryPresentation(for: threadID) else {
            return nil
        }
        
        return "\(presentation.technical.overallPath.rawValue) • \(presentation.technical.certaintyTrend.rawValue)"
    }
    
    func renderedVisitReasoning(for visit: Visit) -> RenderedVisitReasoning {
        renderer.renderVisit(
            from: visit,
            threadID: visit.caseThreadId,
            preferences: renderPreferences
        )
    }
    
    func exportState() -> State {
        State(
            threads: threads,
            visits: visits
        )
    }
    
    func importState(_ state: State) {
        threads = state.threads
        visits = state.visits
        displayLanguage = .english
        mirrorLanguageMode = .sourceOnly
    }
    
    func watchpoints(for thread: CaseThread) -> [ReasoningWatchpoint] {
        let comps = comparisons(for: thread)
        return watchpointDetector.detect(for: comps, thread: thread)
    }
    
    func watchpointPresentation(for watchpoint: ReasoningWatchpoint) -> WatchpointPresentation {
        let raw = String(describing: watchpoint).lowercased()
        
        if raw.contains("turning") {
            return WatchpointPresentation(
                title: "Recent change in direction",
                body: "The doctor’s reasoning appears to have shifted at this stage."
            )
        }
        
        if raw.contains("reconsider") || raw.contains("revision") || raw.contains("changed") {
            return WatchpointPresentation(
                title: "Reconsidered explanation",
                body: "The earlier explanation may have been revised as new information appeared."
            )
        }
        
        if raw.contains("uncertain") || raw.contains("uncertainty") {
            return WatchpointPresentation(
                title: "Uncertainty remains",
                body: "Some uncertainty still remains, so the reasoning should not yet be read as fully settled."
            )
        }
        
        if raw.contains("monitor") || raw.contains("follow") {
            return WatchpointPresentation(
                title: "Monitoring signal",
                body: "The doctor appears to be watching how things develop before deciding further."
            )
        }
        
        if raw.contains("test") || raw.contains("investigation") {
            return WatchpointPresentation(
                title: "Further checking",
                body: "Additional checking appears relevant to make the picture clearer."
            )
        }
        
        if raw.contains("working") || raw.contains("narrow") {
            return WatchpointPresentation(
                title: "Narrowing explanation",
                body: "The doctor’s thinking appears to be focusing toward a more specific explanation."
            )
        }
        
        if raw.contains("confirm") {
            return WatchpointPresentation(
                title: "Growing confidence",
                body: "The reasoning appears to be moving toward a more confident explanation."
            )
        }
        
        return WatchpointPresentation(
            title: "Reasoning signal",
            body: "This part of the case drew closer reasoning attention from the doctor."
        )
    }
    
    func reasoningShift(for thread: CaseThread) -> ReasoningShift? {
        shiftDetector.detect(for: visits(for: thread))
    }
    
    func confidenceTrajectory(for thread: CaseThread) -> ConfidenceTrajectory {
        let threadVisits = visits(for: thread)
        return confidenceDetector.detect(visits: threadVisits)
    }
    
    func workingExplanation(for thread: CaseThread) -> WorkingExplanation? {
        let threadVisits = visits(for: thread)
        return workingExplanationDetector.detect(for: threadVisits)
    }
    
    func visits(for thread: CaseThread) -> [Visit] {
        visits
            .filter { $0.caseThreadId == thread.id }
            .sorted { $0.visitDate > $1.visitDate }
    }
    
    func thread(for visit: Visit) -> CaseThread? {
        threads.first { $0.id == visit.caseThreadId }
    }
    
    func allVisitsSorted() -> [Visit] {
        visits.sorted { $0.visitDate > $1.visitDate }
    }
    
    func comparisons(for thread: CaseThread) -> [VisitReasoningComparison] {
        let orderedVisits = visits(for: thread)
            .sorted { $0.visitDate < $1.visitDate }
        
        var results: [VisitReasoningComparison] = []
        
        for (index, current) in orderedVisits.enumerated() {
            let previous = index > 0 ? orderedVisits[index - 1] : nil
            let changes = detector.detectChanges(from: previous, to: current)
            
            let movement = movementMapper.movement(
                previousVisit: previous,
                currentVisit: current,
                changes: changes
            )
            
            let stage = stageDetector.stage(for: movement)
            let previousMovement = results.last?.movement
            
            let turningPoint = turningPointDetector.detectTurningPoint(
                previousVisit: previous,
                currentVisit: current,
                previousMovement: previousMovement,
                currentMovement: movement,
                changes: changes
            )
            
            results.append(
                VisitReasoningComparison(
                    previousVisit: previous,
                    currentVisit: current,
                    changes: changes,
                    movement: movement,
                    stage: stage,
                    turningPoint: turningPoint
                )
            )
        }
        
        return results
    }
    
    func reasoningDelta(for visit: Visit, in thread: CaseThread) -> VisitReasoningDelta {
        let threadVisits = visits(for: thread)
            .sorted { $0.visitDate < $1.visitDate }
        
        guard let currentIndex = threadVisits.firstIndex(where: { $0.id == visit.id }) else {
            return VisitReasoningDelta(
                currentVisitId: visit.id,
                previousVisitId: nil,
                changeType: .initial,
                title: "Visit not found in timeline",
                summary: "This visit could not be compared with previous visits in the same issue thread."
            )
        }
        
        guard currentIndex > 0 else {
            return VisitReasoningDelta(
                currentVisitId: visit.id,
                previousVisitId: nil,
                changeType: .initial,
                title: "Doctor gave a first explanation",
                summary: "This was the doctor's first recorded explanation for what might be happening."
            )
        }
        
        let previous = threadVisits[currentIndex - 1]
        return compare(previous: previous, current: visit)
    }
    
    func addVisit(_ visit: Visit) {
        visits.append(visit)
        visits.sort { $0.visitDate > $1.visitDate }
        ReasoningPersistence.save(self)
    }
    
    func threadForNewVisit(_ visit: Visit) -> CaseThread? {
        threads.first { $0.id == visit.caseThreadId }
    }
    
    func threadIDForExtractedReasoning(_ extracted: ExtractedReasoning) -> UUID? {
        let source = [
            extracted.reasonForVisit,
            extracted.doctorExplanation,
            extracted.whatMightBeHappening,
            extracted.decision
        ]
        .joined(separator: " ")
        .lowercased()
        
        if source.contains("cough") || source.contains("airway") || source.contains("asthma") || source.contains("inhaler") {
            return threads.first(where: { $0.title.lowercased() == "persistent cough" })?.id
        }
        
        if source.contains("blood pressure") || source.contains("hypertension") {
            return threads.first(where: { $0.title.lowercased() == "blood pressure review" })?.id
        }
        
        if source.contains("urinary") || source.contains("urination") || source.contains("uti") {
            return threads.first(where: { $0.title.lowercased() == "urinary symptoms" })?.id
        }
        
        return nil
    }
    
    func addExtractedReasoningAsVisit(_ extracted: ExtractedReasoning) -> Visit? {
        guard let caseThreadId = threadIDForExtractedReasoning(extracted) else {
            return nil
        }
        
        let visit = TranscriptVisitBuilder.buildVisit(
            from: extracted,
            caseThreadId: caseThreadId
        )
        
        addVisit(visit)
        return visit
    }
    
    func timelineSummary(for thread: CaseThread, visits: [Visit]) -> String {
        let comps = comparisons(for: visits)
        
        guard !comps.isEmpty else {
            return "No visits recorded yet."
        }
        
        var collapsed: [ReasoningMovement] = []
        
        for comp in comps {
            let movement = comp.movement
            
            guard let last = collapsed.last else {
                collapsed.append(movement)
                continue
            }
            
            if movement == last { continue }
            if movement.progressionRank < last.progressionRank { continue }
            
            collapsed.append(movement)
        }
        
        return collapsed
            .map(\.timelineLabel)
            .joined(separator: " → ")
    }
    
    func stageSummary(for thread: CaseThread, visits: [Visit]) -> String {
        let comps = comparisons(for: visits)
        
        guard !comps.isEmpty else {
            return "No visits recorded yet."
        }
        
        var stages: [ReasoningStage] = []
        
        for comp in comps {
            let stage = comp.stage
            
            if stages.isEmpty {
                stages.append(stage)
                continue
            }
            
            let last = stages.last!
            
            if stageProgress(stage) >= stageProgress(last), stage != last {
                stages.append(stage)
            }
        }
        
        return stages
            .map(\.timelineLabel)
            .joined(separator: " → ")
    }
    
    func turningPointSummary(for thread: CaseThread, visits: [Visit]) -> String {
        let comps = comparisons(for: visits)
        let points = comps.compactMap(\.turningPoint)
        
        guard !points.isEmpty else {
            return "No major reasoning pivots detected yet."
        }
        
        var labels: [String] = []
        
        for point in points {
            let label = point.kind.timelineLabel
            if labels.last != label {
                labels.append(label)
            }
        }
        
        return labels.joined(separator: " → ")
    }
    
    func reasoningTimelineStrip(for threadID: UUID) -> [String] {
        guard let thread = threads.first(where: { $0.id == threadID }) else {
            return []
        }
        
        let recentVisits = compressedVisits(for: thread).recent
        
        let items = [
            timelineSummary(for: thread, visits: recentVisits),
            stageSummary(for: thread, visits: recentVisits),
            turningPointSummary(for: thread, visits: recentVisits)
        ]
        
        return items.filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var caseTrajectorySummaries: [CaseTrajectorySummary] {
        threads.compactMap { thread -> CaseTrajectorySummary? in
            let comparisons = buildComparisons(for: thread)
            guard !comparisons.isEmpty else { return nil }
            
            return trajectoryEngine.summarizeThread(
                thread: thread,
                comparisons: comparisons
            )
        }
    }
    
    var caseTrajectoryPresentations: [CaseTrajectoryPresentation] {
        caseTrajectorySummaries.map { trajectory in
            let patientTranslation = patientTrajectoryTranslator.translate(
                overallPath: trajectory.overallPath,
                certaintyTrend: trajectory.certaintyTrend,
                momentum: trajectory.momentum,
                activeUncertainty: trajectory.activeUncertainty
            )
            
            return CaseTrajectoryPresentation(
                technical: trajectory,
                patient: patientTranslation,
                epistemicStatus: trustSignalMapper.trajectoryStatus(for: trajectory)
            )
        }
    }
    
    private func stageProgress(_ stage: ReasoningStage) -> Int {
        switch stage {
        case .exploration: return 0
        case .narrowing: return 1
        case .workingExplanation: return 2
        case .confirmation: return 3
        }
    }
    
    private func compare(previous: Visit, current: Visit) -> VisitReasoningDelta {
        let prevHypothesis = previous.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines)
        let currHypothesis = current.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prevDecision = previous.decision.trimmingCharacters(in: .whitespacesAndNewlines)
        let currDecision = current.decision.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let decisionHeadline = eventHeadline(from: currDecision)
        
        if prevDecision != currDecision {
            return VisitReasoningDelta(
                currentVisitId: current.id,
                previousVisitId: previous.id,
                changeType: .decisionChanged,
                title: decisionHeadline ?? "Doctor changed the next step",
                summary: decisionMeaning(from: currDecision)
            )
        }
        
        if prevHypothesis != currHypothesis {
            return VisitReasoningDelta(
                currentVisitId: current.id,
                previousVisitId: previous.id,
                changeType: .hypothesisShift,
                title: decisionHeadline ?? "Doctor reconsidered the earlier explanation",
                summary: hypothesisMeaning(from: current)
            )
        }
        
        if Set(previous.evidence) != Set(current.evidence) {
            return VisitReasoningDelta(
                currentVisitId: current.id,
                previousVisitId: previous.id,
                changeType: .evidenceAdded,
                title: "Doctor used new information",
                summary: "New observations or results appear to have influenced the doctor's thinking."
            )
        }
        
        return VisitReasoningDelta(
            currentVisitId: current.id,
            previousVisitId: previous.id,
            changeType: .noMajorChange,
            title: decisionHeadline ?? "Doctor stayed with a similar plan",
            summary: "The doctor's explanation and next step appear broadly similar to the previous visit."
        )
    }
    
    private func eventHeadline(from decision: String) -> String? {
        let text = decision.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if text.contains("x-ray") || text.contains("xray") { return "Doctor ordered a chest X-ray" }
        if text.contains("inhaler") && text.contains("trial") { return "Doctor started an inhaler trial" }
        if text.contains("continue inhaler") || text.contains("continue treatment") { return "Doctor continued treatment" }
        if text.contains("monitor") || text.contains("watch") { return "Doctor continued monitoring" }
        if text.contains("antibiotic") { return "Doctor prescribed antibiotics" }
        if text.contains("blood test") { return "Doctor ordered a blood test" }
        if text.contains("scan") { return "Doctor ordered a scan" }
        if text.contains("refer") || text.contains("referral") { return "Doctor arranged further specialist review" }
        
        return nil
    }
    
    private func decisionMeaning(from decision: String) -> String {
        let text = decision.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if text.contains("x-ray") || text.contains("xray") {
            return "Because the symptoms were not improving as expected, the doctor needed more information."
        }
        
        if text.contains("inhaler") && text.contains("trial") {
            return "This suggests the doctor is considering airway irritation or asthma as a possible explanation."
        }
        
        if text.contains("continue inhaler") || text.contains("continue treatment") {
            return "This suggests the doctor thinks the current treatment is helping and should continue."
        }
        
        if text.contains("monitor") || text.contains("watch") {
            return "This suggests the doctor is not ready to make a stronger conclusion yet."
        }
        
        if text.contains("antibiotic") {
            return "This suggests the doctor thinks an infection is likely enough to treat."
        }
        
        if text.contains("blood test") || text.contains("scan") {
            return "This suggests the doctor needed more evidence before deciding the next step."
        }
        
        if text.contains("refer") || text.contains("referral") {
            return "This suggests the doctor thinks more specialised assessment is needed."
        }
        
        return "The doctor decided on a different treatment, test, or follow-up plan compared with the previous visit."
    }
    
    private func hypothesisMeaning(from visit: Visit) -> String {
        let text = visit.whatMightBeHappening.lowercased()
        
        if text.contains("asthma") || text.contains("airway") {
            return "The doctor is now leaning more toward an airway-related explanation."
        }
        
        if text.contains("infection") || text.contains("viral") {
            return "The doctor still seems to be considering an infection-related explanation."
        }
        
        if text.contains("blood pressure") || text.contains("hypertension") {
            return "The doctor is focusing more clearly on blood pressure as the main issue."
        }
        
        return "The doctor now seems to be describing a different explanation for what might be happening."
    }
    
    private func buildComparisons(for thread: CaseThread) -> [VisitReasoningComparison] {
        let threadVisits = visits.filter { $0.caseThreadId == thread.id }
        let sortedVisits = threadVisits.sorted { lhs, rhs in
            lhs.visitDate < rhs.visitDate
        }
        
        var comparisons: [VisitReasoningComparison] = []
        
        for currentVisit in sortedVisits {
            let previousVisit = comparisons.last?.currentVisit
            let previousMovement = comparisons.last?.movement
            
            let changes = detector.detectChanges(
                from: previousVisit,
                to: currentVisit
            )
            
            let movement = movementMapper.movement(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                changes: changes
            )
            
            let stage = stageDetector.stage(for: movement)
            
            let turningPoint = turningPointDetector.detectTurningPoint(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                previousMovement: previousMovement,
                currentMovement: movement,
                changes: changes
            )
            
            let comparison = VisitReasoningComparison(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                changes: changes,
                movement: movement,
                stage: stage,
                turningPoint: turningPoint
            )
            
            comparisons.append(comparison)
        }
        
        return comparisons
    }
    
    private func comparisons(for visits: [Visit]) -> [VisitReasoningComparison] {
        let sortedVisits = visits.sorted { $0.visitDate < $1.visitDate }
        
        var comparisons: [VisitReasoningComparison] = []
        
        for currentVisit in sortedVisits {
            let previousVisit = comparisons.last?.currentVisit
            let previousMovement = comparisons.last?.movement
            
            let changes = detector.detectChanges(
                from: previousVisit,
                to: currentVisit
            )
            
            let movement = movementMapper.movement(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                changes: changes
            )
            
            let stage = stageDetector.stage(for: movement)
            
            let turningPoint = turningPointDetector.detectTurningPoint(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                previousMovement: previousMovement,
                currentMovement: movement,
                changes: changes
            )
            
            let comparison = VisitReasoningComparison(
                previousVisit: previousVisit,
                currentVisit: currentVisit,
                changes: changes,
                movement: movement,
                stage: stage,
                turningPoint: turningPoint
            )
            
            comparisons.append(comparison)
        }
        
        return comparisons
    }
    
    private func shortStageLabel(for visit: Visit, isFirst: Bool) -> String {
        let decision = visit.decision.lowercased()
        let explanation = visit.whatMightBeHappening.lowercased()
        let summary = visit.oneLineVisitSummary.lowercased()
        
        if isFirst {
            if explanation.contains("viral") || summary.contains("viral") { return "Started as viral cough" }
            if explanation.contains("infection") || summary.contains("infection") { return "Started as suspected infection" }
            if explanation.contains("blood pressure") || summary.contains("blood pressure") { return "Started with blood pressure concern" }
            return "Initial explanation recorded"
        }
        
        if decision.contains("x-ray") || decision.contains("xray") { return "Testing ordered" }
        if decision.contains("inhaler") && decision.contains("trial") { return "Inhaler trial started" }
        if decision.contains("continue inhaler") || decision.contains("continue treatment") { return "Treatment continued" }
        if decision.contains("monitor") || decision.contains("watch") { return "Still being monitored" }
        if explanation.contains("asthma") || explanation.contains("airway") { return "Airway irritation more likely" }
        if explanation.contains("infection") || explanation.contains("viral") { return "Infection still considered" }
        if explanation.contains("blood pressure") || explanation.contains("hypertension") { return "Blood pressure remains the focus" }
        
        return "Reasoning evolved"
    }
    
    private func comparisonsFallbackMovement() -> ReasoningMovement {
        fatalError("Replace comparisonsFallbackMovement() with a real ReasoningMovement case after checking the enum definition.")
    }
    
    private func latestComparison(for thread: CaseThread) -> VisitReasoningComparison? {
        comparisons(for: thread).last
    }
    
    private func patientTrajectorySummary(for comparison: VisitReasoningComparison) -> String {
        let movement = String(describing: comparison.movement).lowercased()

        if movement.contains("stable") || movement.contains("steady") {
            return "Across recent visits, the reasoning appears broadly steady rather than sharply changing."
        }

        if movement.contains("refin") || movement.contains("narrow") || movement.contains("focus") {
            return "Across recent visits, the reasoning appears to be refining rather than reversing."
        }

        if movement.contains("diverg") || movement.contains("broad") || movement.contains("widen") {
            return "Across recent visits, the reasoning appears to be keeping more than one explanation open."
        }

        if movement.contains("redirect") || movement.contains("shift") || movement.contains("change") {
            return "Across recent visits, the reasoning appears to be shifting direction in a meaningful way."
        }

        return "Across recent visits, the reasoning appears to be developing, though the overall direction is still provisional."
    }
    
    private func patientTrajectoryReadingNote(for comparison: VisitReasoningComparison) -> String {
        switch comparison.stage {
        case .exploration:
            return "Because the reasoning is still early, later information may still change the overall picture."
        case .narrowing:
            return "The reasoning is becoming more organized, but it should still be read as provisional."
        case .workingExplanation:
            return "A clearer working explanation is visible, though it still does not by itself confirm a final conclusion."
        case .confirmation:
            return "The reasoning is showing more internal consistency, though it still does not by itself confirm a final conclusion."
        }
    }
    
    private func continuitySummary(for comparison: VisitReasoningComparison) -> String {
        let movement = String(describing: comparison.movement).lowercased()

        if movement.contains("stable") || movement.contains("steady") {
            return "The line of reasoning is carrying forward with relatively little change."
        }

        if movement.contains("refin") || movement.contains("narrow") || movement.contains("focus") {
            return "The line of reasoning is carrying forward, but with clearer narrowing or sharpening."
        }

        if movement.contains("diverg") || movement.contains("broad") || movement.contains("widen") {
            return "The line of reasoning is carrying forward while still holding multiple possibilities open."
        }

        if movement.contains("redirect") || movement.contains("shift") || movement.contains("change") {
            return "The line of reasoning is not simply continuing forward; it is being reoriented."
        }

        return "The line of reasoning is still developing across visits."
    }
    
    private func continuityAnchor(for comparison: VisitReasoningComparison) -> String {
        if let previousVisit = comparison.previousVisit {
            return "Some core reasoning from the prior visit remains present in the current assessment of \(formattedVisitDate(previousVisit.visitDate))."
        } else {
            return "There is not yet enough prior visit history to describe a strong continuity anchor."
        }
    }
    
    private func continuityMovement(for comparison: VisitReasoningComparison) -> String {
        if let turningPoint = comparison.turningPoint {
            return readableTurningPointSummary(for: turningPoint)
        }

        let movement = String(describing: comparison.movement).lowercased()

        if movement.contains("stable") || movement.contains("steady") {
            return "No major directional shift stands out across the most recent visits."
        }

        if movement.contains("refin") || movement.contains("narrow") || movement.contains("focus") {
            return "The reasoning has become more focused without clearly breaking from the earlier line."
        }

        if movement.contains("diverg") || movement.contains("broad") || movement.contains("widen") {
            return "The reasoning remains open enough that more than one path is still being considered."
        }

        if movement.contains("redirect") || movement.contains("shift") || movement.contains("change") {
            return "The reasoning appears to have moved toward a different interpretive direction."
        }

        return "The reasoning is still developing across visits."
    }
    
    private func evidenceSummary(for comparison: VisitReasoningComparison) -> String {
        if comparison.changes.contains(where: { "\($0.kind)".lowercased().contains("evidence") }) {
            return "The current reasoning depends meaningfully on the evidence available so far."
        } else {
            return "The current reasoning is not resting on one isolated data point alone."
        }
    }
    
    private func evidenceAcrossVisits(for comparison: VisitReasoningComparison) -> String {
        switch comparison.stage {
        case .exploration:
            return "There has not yet been enough time or repeated evidence to treat the current picture as settled."
        case .narrowing:
            return "The evidence is beginning to connect across visits, but it still needs continued follow-up."
        case .workingExplanation:
            return "The evidence is lining up more consistently across visits, though ongoing confirmation still matters."
        case .confirmation:
            return "The evidence is lining up more consistently across visits, and the overall pattern appears calmer than before."
        }
    }
    
    private func nextEvidenceStep(for comparison: VisitReasoningComparison) -> String {
        switch comparison.stage {
        case .exploration:
            return "The next useful step is more follow-up evidence over time before reading too much into the current picture."
        case .narrowing:
            return "The next useful step is evidence that helps distinguish between the remaining live explanations."
        case .workingExplanation:
            return "The next useful step is confirming that the current direction continues to hold rather than assuming it is final."
        case .confirmation:
            return "The next useful step is confirming that the current direction continues to hold without introducing new contradictions."
        }
    }
    
    private func emphasis(for comparison: VisitReasoningComparison) -> ReasoningSignalEmphasis {
        let movement = String(describing: comparison.movement).lowercased()

        if movement.contains("stable") || movement.contains("steady") {
            return .stable
        }

        if movement.contains("redirect") || movement.contains("shift") || movement.contains("change") ||
            movement.contains("diverg") || movement.contains("broad") || movement.contains("widen") {
            return .caution
        }

        return .neutral
    }
    
    private func evidenceEmphasis(for comparison: VisitReasoningComparison) -> ReasoningSignalEmphasis {
        if comparison.turningPoint != nil {
            return .caution
        }
        
        switch comparison.stage {
        case .exploration:
            return .caution
        case .narrowing, .workingExplanation:
            return .neutral
        case .confirmation:
            return .stable
        }
    }
    
    private func deduplicatedReasoningSignals(_ items: [ReasoningSignalPresentation]) -> [ReasoningSignalPresentation] {
        var seen: Set<String> = []
        var result: [ReasoningSignalPresentation] = []
        
        for item in items {
            let key = "\(item.title)|\(item.body)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(item)
            }
        }
        
        return result
    }
    
    private func formattedVisitDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
