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
    
    
    func reasoningSignals(for thread: CaseThread) -> [ReasoningSignalPresentation] {
        let posture = reasoningPosture(for: thread)
        let watchpoints = watchpoints(for: thread)

        var signals: [ReasoningSignalPresentation] = []

        if posture.isProvisional {
            signals.append(
                ReasoningSignalPresentation(
                    title: "Reasoning remains provisional",
                    body: "The doctor’s thinking is still being worked through rather than treated as settled.",
                    emphasis: .caution
                )
            )
        }

        if !watchpoints.isEmpty {
            signals.append(
                ReasoningSignalPresentation(
                    title: "Watchpoints remain",
                    body: "Some parts of the reasoning still need careful follow-through across visits.",
                    emphasis: .caution
                )
            )
        }

        let stableText = (posture.title + " " + posture.summary).lowercased()
        if stableText.contains("stable") || stableText.contains("consistent") {
            signals.append(
                ReasoningSignalPresentation(
                    title: "Reasoning stayed broadly stable",
                    body: "The overall line of thinking appears broadly consistent across the visit sequence.",
                    emphasis: .stable
                )
            )
        } else {
            signals.append(
                ReasoningSignalPresentation(
                    title: "Reasoning evolved",
                    body: "The doctor’s line of thinking appears to have developed or shifted across visits.",
                    emphasis: .neutral
                )
            )
        }

        return Array(signals.prefix(4))
    }
    
    func reasoningConsistencySummary(for thread: CaseThread) -> String {
        let posture = reasoningPosture(for: thread)
        let watchpoints = watchpoints(for: thread)

        let text = (posture.title + " " + posture.summary).lowercased()

        if posture.isProvisional {
            return "Across visits, the doctor’s reasoning has remained provisional rather than being presented as settled."
        }

        if text.contains("stable") || text.contains("consistent") {
            return "Across visits, the overall line of reasoning has remained broadly consistent."
        }

        if !watchpoints.isEmpty {
            return "Across visits, some parts of the reasoning have continued to need careful follow-through."
        }

        return "Across visits, the doctor’s reasoning appears to have developed or shifted."
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

        guard !comps.isEmpty else {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "No reasoning pattern has been established yet."
            )
        }

        if comps.count == 1 {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "Only one visit is available, so the reasoning pattern is still early."
            )
        }

        let turningPoints = comps.compactMap(\.turningPoint)

        if !turningPoints.isEmpty {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "The explanation shifted across visits as new information appeared."
            )
        }

        if let trajectory = trajectorySummary(for: thread.id), trajectory.activeUncertainty {
            return ReasoningEvidenceStatus(
                title: "Evidence status",
                body: "The reasoning pattern is visible, but some uncertainty still remains."
            )
        }

        return ReasoningEvidenceStatus(
            title: "Evidence status",
            body: "The reasoning appears to have become more stable across visits."
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

    func watchpointEpistemicStatus(
        for watchpoint: ReasoningWatchpoint
    ) -> EpistemicStatus {
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
                title: "Turning Point",
                body: "The doctor’s reasoning appears to have shifted at this stage."
            )
        }

        if raw.contains("reconsider") || raw.contains("revision") || raw.contains("changed") {
            return WatchpointPresentation(
                title: "Reconsidered Explanation",
                body: "The earlier explanation may have been revised as new information appeared."
            )
        }

        if raw.contains("uncertain") || raw.contains("uncertainty") {
            return WatchpointPresentation(
                title: "Uncertainty Remains",
                body: "Some uncertainty still remains, so the reasoning is not fully settled yet."
            )
        }

        if raw.contains("monitor") || raw.contains("follow") {
            return WatchpointPresentation(
                title: "Monitoring Signal",
                body: "The doctor appears to be watching how things develop before deciding further."
            )
        }

        if raw.contains("test") || raw.contains("investigation") {
            return WatchpointPresentation(
                title: "Further Checking",
                body: "Additional checking appears relevant to make the picture clearer."
            )
        }

        if raw.contains("working") || raw.contains("narrow") {
            return WatchpointPresentation(
                title: "Narrowing Explanation",
                body: "The doctor’s thinking appears to be focusing toward a more specific explanation."
            )
        }

        if raw.contains("confirm") {
            return WatchpointPresentation(
                title: "Growing Confidence",
                body: "The reasoning appears to be moving toward a more confident explanation."
            )
        }

        return WatchpointPresentation(
            title: "Reasoning Signal",
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
    
    func timelineSummary(for thread: CaseThread) -> String {
        let comps = comparisons(for: thread)
        
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
    
    func stageSummary(for thread: CaseThread) -> String {
        let comps = comparisons(for: thread)
        
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
    
    func turningPointSummary(for thread: CaseThread) -> String {
        let comps = comparisons(for: thread)
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

        let items = [
            timelineSummary(for: thread),
            stageSummary(for: thread),
            turningPointSummary(for: thread)
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
}
