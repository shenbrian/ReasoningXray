import Foundation

private let monitoringLoopThreadID = UUID()

enum MockReasoningData {
    static let coughThreadId = UUID()
    static let bloodPressureThreadId = UUID()

    static let coughVisit1Id = UUID()
    static let coughVisit2Id = UUID()
    static let coughVisit3Id = UUID()
    static let coughVisit4Id = UUID()
    static let coughVisit5Id = UUID()

    static let bpVisit1Id = UUID()
    static let bpVisit2Id = UUID()
    static let bpVisit3Id = UUID()
    
    static let utiThreadId = UUID()

    static let utiVisit1Id = UUID()
    
    static let utiVisit2Id = UUID()
    static let utiVisit3Id = UUID()
    
    static let monitoringVisit1Id = UUID()
    static let monitoringVisit2Id = UUID()
    static let monitoringVisit3Id = UUID()

    static let threads: [CaseThread] = [
        CaseThread(
            id: coughThreadId,
            title: "Persistent cough",
            primaryConcern: "Ongoing cough lasting several weeks",
            status: CaseThreadStatus.monitoring,
            currentUnderstanding: "The doctor currently seems to think the cough is more likely related to airway irritation or asthma than a short viral infection.",
            stillUncertain: "The exact cause is not yet confirmed.",
            nextLikelyStep: "Review inhaler response and decide whether further testing is needed.",
            visitIds: [coughVisit1Id, coughVisit2Id, coughVisit3Id, coughVisit4Id, coughVisit5Id]
        ),
        CaseThread(
            id: bloodPressureThreadId,
            title: "Blood pressure review",
            primaryConcern: "Monitoring elevated blood pressure readings",
            status: .open,
            currentUnderstanding: "Blood pressure appears persistently elevated and may require ongoing monitoring or treatment adjustment.",
            stillUncertain: "It is still unclear whether readings are consistently high enough for long-term medication.",
            nextLikelyStep: "Continue home readings and reassess trend at the next visit.",
            visitIds: [bpVisit1Id, bpVisit2Id, bpVisit3Id]
        ),
        CaseThread(
            id: utiThreadId,
            title: "Urinary symptoms",
            primaryConcern: "Burning urination and frequency",
            status: .open,
            currentUnderstanding: "The doctor currently seems to think the symptoms were most likely due to a urinary infection that improved with treatment.",
            stillUncertain: "It is still important to confirm symptoms fully settle and do not return.",
            nextLikelyStep: "Review whether symptoms fully resolved after antibiotics.",
            visitIds: [utiVisit1Id, utiVisit2Id, utiVisit3Id]
        ),
        CaseThread(
            id: monitoringLoopThreadID,
            title: "Monitoring loop stress test",
            primaryConcern: "Mild chest tightness and intermittent cough without clear progression",
            status: .monitoring,
            currentUnderstanding: "The doctor has not yet identified a single explanation and is continuing observation.",
            stillUncertain: "The symptoms remain unresolved and have not yet declared a clearer pattern.",
            nextLikelyStep: "Continue monitoring unless symptoms worsen or become more specific.",
            visitIds: [monitoringVisit1Id, monitoringVisit2Id, monitoringVisit3Id]
        )
    ]

    static let visits: [Visit] = [
        Visit(
            id: coughVisit1Id,
            caseThreadId: coughThreadId,
            visitDate: date(2026, 1, 10),
            doctorName: "Dr. Wong",
            clinicName: "Harbour Medical",
            visitType: .gp,
            reasonForVisit: "Cough after recent cold",
            doctorExplanation: "The doctor thought this was most likely a post-viral cough following a recent upper respiratory infection.",
            evidence: ["Recent cold", "No red flags mentioned", "Symptoms only present for a short time"],
            decision: "Watch and monitor for now",
            nextSteps: ["Return if symptoms persist", "Monitor for fever or worsening breathing"],
            whatMightBeHappening: "This may be a cough that is lingering after a recent cold.",
            howSeriousItAppears: "It does not sound serious right now.",
            whatTheDoctorIsDoing: "The doctor is monitoring the situation rather than testing immediately.",
            whatHappensNext: "You should wait and see whether the cough settles.",
            questionsForNextVisit: ["Has the cough improved?", "Has anything new appeared?"],
            oneLineVisitSummary: "Doctor thought the cough was probably a temporary post-viral cough.",
            mainChangeSinceLastVisit: "Initial visit — no prior comparison available.",
            biggestOpenQuestion: "Will the cough settle on its own?",
            whatToWatchBeforeNextVisit: "Persistent cough, fever, breathlessness",
            symptomsMentioned: ["Cough"],
            testsOrdered: [],
            diagnosesConsidered: ["Post-viral cough", "Upper respiratory infection"]
        ),

        Visit(
            id: coughVisit2Id,
            caseThreadId: coughThreadId,
            visitDate: date(2026, 1, 24),
            doctorName: "Dr. Wong",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Cough continuing longer than expected",
            doctorExplanation: "The doctor noted that the cough had persisted beyond the expected recovery window, so the earlier viral explanation was less certain.",
            evidence: ["Cough still present", "Sleep affected", "No major improvement"],
            decision: "Continue monitoring, consider inhaler if ongoing",
            nextSteps: ["Return again if not improving", "Monitor response over the next two weeks"],
            whatMightBeHappening: "The cough may still be from the original illness, but it is lasting longer than expected.",
            howSeriousItAppears: "Still not immediately alarming, but less straightforward than before.",
            whatTheDoctorIsDoing: "The doctor is reassessing because the original explanation no longer fully fits.",
            whatHappensNext: "Another review may be needed if the cough continues.",
            questionsForNextVisit: ["Is there wheeze?", "Is the cough worse at night?"],
            oneLineVisitSummary: "Doctor became less confident that this was just a short-lived viral cough.",
            mainChangeSinceLastVisit: "Symptoms persisted longer than expected, making the original explanation less secure.",
            biggestOpenQuestion: "Why is the cough not settling?",
            whatToWatchBeforeNextVisit: "Night cough, wheeze, worsening symptoms",
            symptomsMentioned: ["Cough", "Sleep disturbance"],
            testsOrdered: [],
            diagnosesConsidered: ["Post-viral cough", "Airway irritation"]
        ),

        Visit(
            id: coughVisit3Id,
            caseThreadId: coughThreadId,
            visitDate: date(2026, 2, 12),
            doctorName: "Dr. Wong",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Persistent cough with limited improvement",
            doctorExplanation: "The doctor became more concerned that the cough might not be purely post-viral and ordered imaging to rule out other causes.",
            evidence: ["Persistence over several weeks", "Poor improvement", "Repeat presentation"],
            decision: "Order chest X-ray",
            nextSteps: ["Complete chest X-ray", "Review results at next visit"],
            whatMightBeHappening: "The doctor thinks there may be another reason for the cough besides a normal recovery after infection.",
            howSeriousItAppears: "Still not presented as an emergency, but enough to justify further testing.",
            whatTheDoctorIsDoing: "The doctor is ordering a chest X-ray to look for other causes.",
            whatHappensNext: "Test results will help decide the next step.",
            questionsForNextVisit: ["What did the X-ray show?", "Is asthma becoming more likely?"],
            oneLineVisitSummary: "Doctor ordered a chest X-ray because the cough was not improving as expected.",
            mainChangeSinceLastVisit: "Reasoning shifted from watchful waiting to further investigation.",
            biggestOpenQuestion: "What is causing the cough if it is not just post-viral?",
            whatToWatchBeforeNextVisit: "Worsening cough, shortness of breath, new symptoms",
            symptomsMentioned: ["Cough"],
            testsOrdered: ["Chest X-ray"],
            diagnosesConsidered: ["Airway irritation", "Asthma", "Persistent post-viral cough"]
        ),

        Visit(
            id: coughVisit4Id,
            caseThreadId: coughThreadId,
            visitDate: date(2026, 2, 28),
            doctorName: "Dr. Wong",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Review chest X-ray and ongoing cough",
            doctorExplanation: "The doctor thought the pattern now fit airway irritation or possible asthma more than infection.",
            evidence: ["Symptoms ongoing", "No major finding on X-ray", "Pattern suggested airway involvement"],
            decision: "Trial inhaler",
            nextSteps: ["Use inhaler", "Monitor symptom response"],
            whatMightBeHappening: "The doctor now seems to think the cough may be related to irritated airways or possible asthma.",
            howSeriousItAppears: "Still under active management, but not described as dangerous right now.",
            whatTheDoctorIsDoing: "The doctor is trying treatment to see whether symptoms respond.",
            whatHappensNext: "Your response to the inhaler may help clarify the cause.",
            questionsForNextVisit: ["Did the inhaler help?", "Does this now look more like asthma?"],
            oneLineVisitSummary: "Doctor is now leaning more toward airway irritation or possible asthma.",
            mainChangeSinceLastVisit: "Reasoning narrowed from broad investigation toward airway-related causes.",
            biggestOpenQuestion: "Will inhaler response support the asthma hypothesis?",
            whatToWatchBeforeNextVisit: "Symptom response to inhaler, wheeze, nighttime coughing",
            symptomsMentioned: ["Cough"],
            testsOrdered: [],
            diagnosesConsidered: ["Asthma", "Airway irritation"]
        ),

        Visit(
            id: coughVisit5Id,
            caseThreadId: coughThreadId,
            visitDate: date(2026, 3, 10),
            doctorName: "Dr. Wong",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Review inhaler response",
            doctorExplanation: "The doctor thought the partial response to inhaler made airway inflammation more plausible, though the diagnosis was still not fully confirmed.",
            evidence: ["Some improvement with inhaler", "Symptoms not fully resolved"],
            decision: "Continue inhaler and review again",
            nextSteps: ["Continue treatment", "Follow up if symptoms persist"],
            whatMightBeHappening: "The cough now seems more likely related to inflamed or sensitive airways.",
            howSeriousItAppears: "The recent response to treatment makes this explanation more plausible, though the cause is still being confirmed.",
            whatTheDoctorIsDoing: "The doctor is continuing treatment because the response gave useful clues.",
            whatHappensNext: "Your next review will check whether the improvement continues.",
            questionsForNextVisit: ["Is the cough fully resolving?", "Is long-term management needed?"],
            oneLineVisitSummary: "Doctor confidence increased after some improvement with inhaler.",
            mainChangeSinceLastVisit: "Treatment response strengthened the airway-inflammation explanation.",
            biggestOpenQuestion: "Will symptoms fully settle or need longer-term management?",
            whatToWatchBeforeNextVisit: "Return of cough, incomplete improvement, breathlessness",
            symptomsMentioned: ["Cough", "Partial improvement"],
            testsOrdered: [],
            diagnosesConsidered: ["Asthma", "Airway inflammation"]
        ),

        Visit(
            id: bpVisit1Id,
            caseThreadId: bloodPressureThreadId,
            visitDate: date(2026, 1, 18),
            doctorName: "Dr. Patel",
            clinicName: "City Family Practice",
            visitType: .gp,
            reasonForVisit: "Elevated blood pressure reading",
            doctorExplanation: "The doctor noted a raised reading but did not want to diagnose persistent hypertension from one measurement alone.",
            evidence: ["Single elevated reading"],
            decision: "Monitor blood pressure at home",
            nextSteps: ["Record home readings"],
            whatMightBeHappening: "Your blood pressure may be elevated, but one reading is not enough to confirm a pattern.",
            howSeriousItAppears: "Important to monitor, but not yet a confirmed long-term issue.",
            whatTheDoctorIsDoing: "The doctor is gathering more information before deciding.",
            whatHappensNext: "You will monitor your readings at home.",
            questionsForNextVisit: ["Are home readings also high?"],
            oneLineVisitSummary: "Doctor wants more readings before concluding blood pressure is persistently high.",
            mainChangeSinceLastVisit: "Initial visit — no prior comparison available.",
            biggestOpenQuestion: "Is this a one-off reading or a real pattern?",
            whatToWatchBeforeNextVisit: "Repeated high readings",
            symptomsMentioned: [],
            testsOrdered: [],
            diagnosesConsidered: ["Possible hypertension"]
        ),

        Visit(
            id: bpVisit2Id,
            caseThreadId: bloodPressureThreadId,
            visitDate: date(2026, 2, 8),
            doctorName: "Dr. Patel",
            clinicName: "City Family Practice",
            visitType: .followUp,
            reasonForVisit: "Review home blood pressure readings",
            doctorExplanation: "The doctor saw repeated elevated home readings, making persistent high blood pressure more plausible.",
            evidence: ["Repeated elevated home readings"],
            decision: "Continue monitoring and discuss lifestyle measures",
            nextSteps: ["Reduce salt", "Exercise", "Continue home readings"],
            whatMightBeHappening: "The readings now suggest this may be a real blood pressure pattern rather than a one-off result.",
            howSeriousItAppears: "This is becoming more important to monitor closely.",
            whatTheDoctorIsDoing: "The doctor is looking for a sustained pattern before making a longer-term decision.",
            whatHappensNext: "You will continue monitoring and review the trend.",
            questionsForNextVisit: ["Are the readings still elevated despite changes?"],
            oneLineVisitSummary: "Repeated high readings made persistent blood pressure elevation more likely.",
            mainChangeSinceLastVisit: "Concern increased because high readings were repeated.",
            biggestOpenQuestion: "Will the trend persist over time?",
            whatToWatchBeforeNextVisit: "Ongoing high home readings",
            symptomsMentioned: [],
            testsOrdered: [],
            diagnosesConsidered: ["Hypertension"]
        ),

        Visit(
            id: bpVisit3Id,
            caseThreadId: bloodPressureThreadId,
            visitDate: date(2026, 3, 2),
            doctorName: "Dr. Patel",
            clinicName: "City Family Practice",
            visitType: .followUp,
            reasonForVisit: "Further review of blood pressure trend",
            doctorExplanation: "The doctor remained concerned that the readings were persistently high and discussed whether medication might be needed.",
            evidence: ["Persistent elevated readings over time"],
            decision: "Continue monitoring and consider medication if trend continues",
            nextSteps: ["Bring more readings", "Reassess treatment threshold"],
            whatMightBeHappening: "Your blood pressure may be persistently elevated enough to need treatment if it continues.",
            howSeriousItAppears: "This remains important but is being managed in a measured way.",
            whatTheDoctorIsDoing: "The doctor is preparing for a treatment decision if the pattern continues.",
            whatHappensNext: "More readings will help decide whether medication is needed.",
            questionsForNextVisit: ["Has the pattern remained high enough to start treatment?"],
            oneLineVisitSummary: "Doctor is now considering whether medication may be needed if the high readings continue.",
            mainChangeSinceLastVisit: "The discussion moved closer to possible treatment.",
            biggestOpenQuestion: "Is the pressure consistently high enough to justify medication?",
            whatToWatchBeforeNextVisit: "Continued elevated readings",
            symptomsMentioned: [],
            testsOrdered: [],
            diagnosesConsidered: ["Hypertension"]
        ),
        
        Visit(
            id: utiVisit1Id,
            caseThreadId: utiThreadId,
            visitDate: date(2026, 1, 5),
            doctorName: "Dr. Green",
            clinicName: "Harbour Medical",
            visitType: .gp,
            reasonForVisit: "Burning urination and urinary frequency",
            doctorExplanation: "The doctor thought the symptoms were likely caused by a urinary infection.",
            evidence: ["Burning urination", "Urinary frequency"],
            decision: "Start antibiotics",
            nextSteps: ["Take antibiotics", "Return if symptoms persist"],
            whatMightBeHappening: "The symptoms may be due to a urinary infection.",
            howSeriousItAppears: "The problem seems treatable, but the doctor wants to make sure it improves.",
            whatTheDoctorIsDoing: "The doctor is starting treatment for a likely infection.",
            whatHappensNext: "You should monitor whether symptoms improve after treatment.",
            questionsForNextVisit: ["Have the symptoms settled?", "Did the antibiotics help?"],
            oneLineVisitSummary: "Doctor thought the urinary symptoms were most likely due to an infection.",
            mainChangeSinceLastVisit: "Initial visit — no prior comparison available.",
            biggestOpenQuestion: "Will treatment quickly settle the symptoms?",
            whatToWatchBeforeNextVisit: "Persistent burning, fever, worsening symptoms",
            symptomsMentioned: ["Burning urination", "Urinary frequency"],
            testsOrdered: [],
            diagnosesConsidered: ["Urinary infection"]
        ),

        Visit(
            id: utiVisit2Id,
            caseThreadId: utiThreadId,
            visitDate: date(2026, 1, 12),
            doctorName: "Dr. Green",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Review response to antibiotics",
            doctorExplanation: "The doctor noted symptoms were improving, which supported the infection explanation.",
            evidence: ["Symptoms improved after antibiotics"],
            decision: "Continue antibiotics and review if needed",
            nextSteps: ["Finish antibiotics", "Return if symptoms return"],
            whatMightBeHappening: "The improvement makes the infection explanation more likely.",
            howSeriousItAppears: "The response is reassuring, though the doctor still wants symptoms to fully settle.",
            whatTheDoctorIsDoing: "The doctor is using the response to treatment to confirm the likely cause.",
            whatHappensNext: "You should finish treatment and monitor whether symptoms fully resolve.",
            questionsForNextVisit: ["Did symptoms fully resolve?", "Did anything return after treatment?"],
            oneLineVisitSummary: "Improvement after antibiotics supported the infection explanation.",
            mainChangeSinceLastVisit: "Treatment response strengthened the infection explanation.",
            biggestOpenQuestion: "Will the symptoms fully settle?",
            whatToWatchBeforeNextVisit: "Return of symptoms, fever, worsening pain",
            symptomsMentioned: ["Improving urinary symptoms"],
            testsOrdered: [],
            diagnosesConsidered: ["Urinary infection"]
        ),

        Visit(
            id: utiVisit3Id,
            caseThreadId: utiThreadId,
            visitDate: date(2026, 1, 25),
            doctorName: "Dr. Green",
            clinicName: "Harbour Medical",
            visitType: .followUp,
            reasonForVisit: "Final review after treatment",
            doctorExplanation: "The doctor noted the symptoms had settled, confirming the earlier explanation was most likely correct.",
            evidence: ["Symptoms resolved", "No recurrence reported"],
            decision: "No further treatment needed unless symptoms return",
            nextSteps: ["Return only if symptoms recur"],
            whatMightBeHappening: "The symptoms appear to have been caused by an infection that has now resolved.",
            howSeriousItAppears: "This appears settled for now.",
            whatTheDoctorIsDoing: "The doctor is confirming the explanation based on symptom resolution.",
            whatHappensNext: "No further action is needed unless symptoms return.",
            questionsForNextVisit: [],
            oneLineVisitSummary: "Resolution of symptoms confirmed the infection explanation.",
            mainChangeSinceLastVisit: "Symptom resolution confirmed the earlier explanation.",
            biggestOpenQuestion: "Will the symptoms stay settled?",
            whatToWatchBeforeNextVisit: "Any return of symptoms",
            symptomsMentioned: [],
            testsOrdered: [],
            diagnosesConsidered: ["Urinary infection"]
        ),
        
        Visit(
            id: monitoringVisit1Id,
            caseThreadId: monitoringLoopThreadID,
            visitDate: date(2026, 1, 10),
            doctorName: "Dr. Lee",
            clinicName: "Riverside Family Clinic",
            visitType: .gp,
            reasonForVisit: "Ongoing mild chest tightness and intermittent cough",
            doctorExplanation: "At this stage the symptoms are not pointing clearly to a specific cause. We should monitor how things evolve.",
            evidence: [
                "Symptoms remain mild",
                "No major worsening reported",
                "No clear red flags identified today"
            ],
            decision: "Monitor symptoms and review again if they continue.",
            nextSteps: [
                "Follow up in two weeks.",
                "Watch for any worsening."
            ],
            whatMightBeHappening: "The doctor does not yet think there is enough evidence to settle on one explanation.",
            howSeriousItAppears: "It does not appear urgent right now, but it is still unresolved.",
            whatTheDoctorIsDoing: "The doctor is monitoring the pattern rather than moving to a more active step yet.",
            whatHappensNext: "The next step is to keep watching symptoms and reassess.",
            questionsForNextVisit: [
                "Have the symptoms become more frequent?",
                "Is anything making them better or worse?"
            ],
            oneLineVisitSummary: "Initial review with a monitoring plan.",
            mainChangeSinceLastVisit: "Initial visit — no prior comparison available.",
            biggestOpenQuestion: "Whether the symptoms will settle or declare a clearer pattern.",
            whatToWatchBeforeNextVisit: "Any worsening, increased frequency, or new symptoms.",
            symptomsMentioned: [
                "Mild chest tightness",
                "Intermittent cough"
            ],
            testsOrdered: [],
            diagnosesConsidered: [
                "Viral irritation",
                "Non-specific chest symptoms"
            ]
        ),

        Visit(
            id: monitoringVisit2Id,
            caseThreadId: monitoringLoopThreadID,
            visitDate: date(2026, 1, 24),
            doctorName: "Dr. Lee",
            clinicName: "Riverside Family Clinic",
            visitType: .followUp,
            reasonForVisit: "Follow-up for ongoing mild chest tightness and cough",
            doctorExplanation: "At this stage the symptoms are not pointing clearly to a specific cause. We should monitor how things evolve.",
            evidence: [
                "Symptoms remain mild.",
                "No major worsening reported.",
                "No clear red flags identified today."
            ],
            decision: "Monitor symptoms and review again if they continue.",
            nextSteps: [
                "Follow up in two weeks.",
                "Watch for any worsening."
            ],
            whatMightBeHappening: "The doctor does not yet think there is enough evidence to settle on one explanation.",
            howSeriousItAppears: "Still not appearing urgent, but still not fully explained.",
            whatTheDoctorIsDoing: "The doctor is continuing observation rather than escalating.",
            whatHappensNext: "The plan remains follow-up and symptom monitoring.",
            questionsForNextVisit: [
                "Has the tightness changed in intensity?",
                "Has the cough become more frequent?"
            ],
            oneLineVisitSummary: "Symptoms unchanged; monitoring continues.",
            mainChangeSinceLastVisit: "No major change since the previous visit.",
            biggestOpenQuestion: "Why the symptoms are persisting without becoming clearer.",
            whatToWatchBeforeNextVisit: "Any progression, new symptoms, or worsening pattern.",
            symptomsMentioned: [
                "Mild chest tightness",
                "Intermittent cough"
            ],
            testsOrdered: [],
            diagnosesConsidered: [
                "Non-specific chest symptoms",
                "Mild airway irritation"
            ]
        ),

        Visit(
            id: monitoringVisit3Id,
            caseThreadId: monitoringLoopThreadID,
            visitDate: date(2026, 2, 7),
            doctorName: "Dr. Lee",
            clinicName: "Riverside Family Clinic",
            visitType: .followUp,
            reasonForVisit: "Third review for mild chest tightness and intermittent cough",
            doctorExplanation: "At this stage the symptoms are not pointing clearly to a specific cause. We should monitor how things evolve.",
            evidence: [
                "Symptoms remain mild.",
                "No major worsening reported.",
                "No clear red flags identified today."
            ],
            decision: "Monitor symptoms and review again if they continue.",
            nextSteps: [
                "Follow up in two weeks.",
                "Watch for any worsening."
            ],
            whatMightBeHappening: "The doctor does not yet think there is enough evidence to settle on one explanation.",
            howSeriousItAppears: "It still appears low urgency, but the question remains open.",
            whatTheDoctorIsDoing: "The doctor is continuing a watchful approach rather than escalating to testing or treatment.",
            whatHappensNext: "The next step is still observation unless something changes.",
            questionsForNextVisit: [
                "Have any new symptoms appeared?",
                "Has the pattern become more frequent or limiting?"
            ],
            oneLineVisitSummary: "Ongoing mild symptoms with another monitoring review.",
            mainChangeSinceLastVisit: "No major change or clarifying development since the previous review.",
            biggestOpenQuestion: "Whether the pattern will resolve on its own or eventually clarify.",
            whatToWatchBeforeNextVisit: "Any worsening, spread of symptoms, or new warning signs.",
            symptomsMentioned: [
                "Mild chest tightness",
                "Intermittent cough"
            ],
            testsOrdered: [],
            diagnosesConsidered: [
                "Non-specific chest symptoms"
            ]
        )
    ]

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
