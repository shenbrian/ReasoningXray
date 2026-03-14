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

final class ReasoningHistoryStore: ObservableObject {
    
    struct State: Codable {
        let threads: [CaseThread]
        let visits: [Visit]
    }
    
    @Published var visits: [Visit]
    @Published var threads: [CaseThread]
    @Published var renderPreferences: ReasoningRenderPreferences = .englishDefault
    
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
    
    func renderedVisitReasoning(for visit: Visit) -> RenderedVisitReasoning {
        renderer.renderVisit(from: visit, preferences: renderPreferences)
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
    }
    
    func watchpoints(for thread: CaseThread) -> [ReasoningWatchpoint] {
        let comps = comparisons(for: thread)
        return watchpointDetector.detect(for: comps, thread: thread)
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

    func trajectoryPresentation(for threadID: UUID) -> CaseTrajectoryPresentation? {
        caseTrajectoryPresentations.first { $0.technical.threadID == threadID }
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
