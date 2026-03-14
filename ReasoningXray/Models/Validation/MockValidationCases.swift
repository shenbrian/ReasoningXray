import Foundation

enum MockValidationCases {

    static let starterCases: [ValidationCase] = [
        coughMonitoringCase,
        urinaryInfectionCase,
        treatmentResponseCase,
        noResponseAfterTreatmentCase,
        negativeTestingRevisionCase,
        repeatedMonitoringBeforeClarityCase,
        responseSupportStabilityCase,
        escalationAfterWatchfulWaitingCase
    ]

    private static let coughThreadID = UUID()
    private static let urinaryThreadID = UUID()
    private static let responseThreadID = UUID()
    private static let noResponseThreadID = UUID()
    private static let negativeTestingThreadID = UUID()
    private static let delayedClarityThreadID = UUID()
    private static let responseStabilityThreadID = UUID()
    private static let escalationThreadID = UUID()

    static let coughMonitoringCase = ValidationCase(
        title: "Persistent Cough — Monitoring to Testing",
        threadTitle: "Persistent cough",
        visits: [
            Visit(
                caseThreadId: coughThreadID,
                visitDate: date(2026, 1, 10),
                doctorName: "Dr Smith",
                clinicName: "Harbour Family Clinic",
                visitType: .gp,
                reasonForVisit: "Cough for two weeks",
                doctorExplanation: "This may be a viral cough and may settle with time.",
                evidence: ["Cough for two weeks", "No fever", "Chest sounds clear"],
                decision: "Monitor symptoms for now.",
                nextSteps: ["Return if not improving", "Follow up in one week if persistent"],
                whatMightBeHappening: "The doctor thinks this may still be a viral cough.",
                howSeriousItAppears: "It does not sound severe right now.",
                whatTheDoctorIsDoing: "The doctor is watching how this develops before escalating.",
                whatHappensNext: "You should monitor the cough and come back if it continues.",
                questionsForNextVisit: ["Has the cough improved?", "Have any new symptoms appeared?"],
                oneLineVisitSummary: "Initial review of a persistent cough.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will the cough settle without further action?",
                whatToWatchBeforeNextVisit: "Worsening cough, fever, shortness of breath.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Viral cough"]
            ),
            Visit(
                caseThreadId: coughThreadID,
                visitDate: date(2026, 1, 18),
                doctorName: "Dr Smith",
                clinicName: "Harbour Family Clinic",
                visitType: .gp,
                reasonForVisit: "Cough still present",
                doctorExplanation: "Because the cough is persisting, a chest X-ray may help rule out other causes.",
                evidence: ["Cough still present", "Symptoms persistent despite time", "No clear improvement"],
                decision: "Order a chest X-ray.",
                nextSteps: ["Chest X-ray", "Review results after imaging"],
                whatMightBeHappening: "The doctor now thinks the persistent cough needs more investigation.",
                howSeriousItAppears: "It still may not be severe, but it now needs checking.",
                whatTheDoctorIsDoing: "The doctor is moving from observation to testing.",
                whatHappensNext: "You will have imaging and then review the result.",
                questionsForNextVisit: ["What did the X-ray show?", "What explanation now seems most likely?"],
                oneLineVisitSummary: "Persistent cough moved the reasoning toward testing.",
                mainChangeSinceLastVisit: "The doctor moved from monitoring to testing.",
                biggestOpenQuestion: "What is causing the cough to continue?",
                whatToWatchBeforeNextVisit: "Any worsening breathing symptoms.",
                symptomsMentioned: ["Cough"],
                testsOrdered: ["Chest X-ray"],
                diagnosesConsidered: ["Viral cough", "Other chest cause"]
            )
        ],
        expectedStages: [.exploration, .narrowing],
        expectedChangeKinds: [
            [],
            [.continuedMonitoring, .reconsideredExplanation, .orderedTesting, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .movedToTesting],
        notes: "Checks monitoring-to-testing transition."
    )

    static let urinaryInfectionCase = ValidationCase(
        title: "Urinary Symptoms — Initial Treatment Trial",
        threadTitle: "Urinary symptoms",
        visits: [
            Visit(
                caseThreadId: urinaryThreadID,
                visitDate: date(2026, 2, 3),
                doctorName: "Dr Patel",
                clinicName: "Riverside Medical",
                visitType: .gp,
                reasonForVisit: "Burning urinary symptoms for three days",
                doctorExplanation: "This most likely sounds like a urinary tract infection.",
                evidence: ["Burning when passing urine", "Urinary frequency", "Symptoms for three days"],
                decision: "Start antibiotics.",
                nextSteps: ["Begin antibiotics today", "Return if not improving"],
                whatMightBeHappening: "The doctor thinks this is most likely a urine infection.",
                howSeriousItAppears: "It appears treatable and not severe right now.",
                whatTheDoctorIsDoing: "The doctor is starting treatment based on the current pattern.",
                whatHappensNext: "You start antibiotics and monitor for improvement.",
                questionsForNextVisit: ["Did the symptoms improve?", "Did anything worsen?"],
                oneLineVisitSummary: "Likely urinary infection with treatment started.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will symptoms improve with treatment?",
                whatToWatchBeforeNextVisit: "Fever, worsening pain, no improvement.",
                symptomsMentioned: ["Burning urination", "Frequency"],
                testsOrdered: [],
                diagnosesConsidered: ["Urinary tract infection"]
            )
        ],
        expectedStages: [.exploration],
        expectedChangeKinds: [[]],
        expectedTurningPoints: [.initialFrame],
        notes: "Single-visit case for initial frame only."
    )

    static let treatmentResponseCase = ValidationCase(
        title: "Airway Inflammation — Treatment Response Confirmation",
        threadTitle: "Persistent cough with inhaler trial",
        visits: [
            Visit(
                caseThreadId: responseThreadID,
                visitDate: date(2026, 1, 5),
                doctorName: "Dr Wong",
                clinicName: "City GP Centre",
                visitType: .gp,
                reasonForVisit: "Persistent cough after viral illness",
                doctorExplanation: "This may be airway inflammation after infection.",
                evidence: ["Persistent cough", "Started after viral illness", "No red-flag signs"],
                decision: "Start a trial inhaler.",
                nextSteps: ["Trial inhaler for two weeks", "Review response"],
                whatMightBeHappening: "The doctor thinks the airways may still be irritated.",
                howSeriousItAppears: "It does not appear dangerous, but it needs treatment review.",
                whatTheDoctorIsDoing: "The doctor is trying treatment to test the explanation.",
                whatHappensNext: "You use the inhaler and then review whether it helped.",
                questionsForNextVisit: ["Did the inhaler help?", "Is the cough still present?"],
                oneLineVisitSummary: "Treatment trial started for suspected airway inflammation.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will treatment response support the explanation?",
                whatToWatchBeforeNextVisit: "Any worsening symptoms or no response.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Airway inflammation"]
            ),
            Visit(
                caseThreadId: responseThreadID,
                visitDate: date(2026, 1, 20),
                doctorName: "Dr Wong",
                clinicName: "City GP Centre",
                visitType: .gp,
                reasonForVisit: "Review after inhaler trial",
                doctorExplanation: "The improvement with the inhaler supports airway inflammation as the working explanation.",
                evidence: ["Cough improved", "Partial response to inhaler", "Less frequent symptoms"],
                decision: "Continue inhaler treatment.",
                nextSteps: ["Continue inhaler", "Review again if symptoms return"],
                whatMightBeHappening: "The doctor now has more confidence in the airway inflammation explanation.",
                howSeriousItAppears: "It appears to be improving.",
                whatTheDoctorIsDoing: "The doctor is using treatment response as evidence.",
                whatHappensNext: "You continue treatment and monitor ongoing improvement.",
                questionsForNextVisit: ["Has improvement continued?", "Do symptoms return if treatment stops?"],
                oneLineVisitSummary: "Improvement after treatment supported the explanation.",
                mainChangeSinceLastVisit: "The doctor gained confidence because treatment helped.",
                biggestOpenQuestion: "Will the improvement continue?",
                whatToWatchBeforeNextVisit: "Return of cough or loss of benefit.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Airway inflammation"]
            )
        ],
        expectedStages: [.exploration, .confirmation],
        expectedChangeKinds: [
            [],
            [.reconsideredExplanation, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .responseShift],
        notes: "Checks treatment-response confirmation logic."
    )

    static let noResponseAfterTreatmentCase = ValidationCase(
        title: "Reflux Treatment — No Response Then Reconsideration",
        threadTitle: "Persistent throat clearing",
        visits: [
            Visit(
                caseThreadId: noResponseThreadID,
                visitDate: date(2026, 2, 1),
                doctorName: "Dr Green",
                clinicName: "Northside Clinic",
                visitType: .gp,
                reasonForVisit: "Throat clearing and cough after meals",
                doctorExplanation: "This may be reflux-related irritation.",
                evidence: ["Cough after meals", "Throat clearing", "No fever"],
                decision: "Start reflux medication.",
                nextSteps: ["Begin reflux treatment", "Review in two weeks"],
                whatMightBeHappening: "The doctor thinks reflux may be irritating the throat.",
                howSeriousItAppears: "It does not sound dangerous, but it may need treatment.",
                whatTheDoctorIsDoing: "The doctor is starting a treatment trial to see if reflux fits.",
                whatHappensNext: "You start treatment and then review whether it helps.",
                questionsForNextVisit: ["Did the treatment help?", "Are symptoms still linked to meals?"],
                oneLineVisitSummary: "Treatment trial started for suspected reflux.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will treatment response support reflux as the cause?",
                whatToWatchBeforeNextVisit: "No improvement or worsening symptoms.",
                symptomsMentioned: ["Cough", "Throat clearing"],
                testsOrdered: [],
                diagnosesConsidered: ["Reflux"]
            ),
            Visit(
                caseThreadId: noResponseThreadID,
                visitDate: date(2026, 2, 16),
                doctorName: "Dr Green",
                clinicName: "Northside Clinic",
                visitType: .gp,
                reasonForVisit: "Review after reflux treatment",
                doctorExplanation: "Because there has been no improvement, reflux now seems less likely.",
                evidence: ["No improvement", "Symptoms unchanged after treatment"],
                decision: "Order spirometry.",
                nextSteps: ["Spirometry test", "Review breathing pattern"],
                whatMightBeHappening: "The earlier reflux explanation is now less convincing.",
                howSeriousItAppears: "The cause is still uncertain.",
                whatTheDoctorIsDoing: "The doctor is reconsidering the explanation and moving to testing.",
                whatHappensNext: "You will have breathing tests and then review the result.",
                questionsForNextVisit: ["Did the test suggest another cause?", "What explanation now seems more likely?"],
                oneLineVisitSummary: "No response led to reconsideration and testing.",
                mainChangeSinceLastVisit: "The earlier explanation became less likely after no response.",
                biggestOpenQuestion: "What is causing the symptoms if not reflux?",
                whatToWatchBeforeNextVisit: "Breathlessness, worsening cough.",
                symptomsMentioned: ["Cough", "Throat clearing"],
                testsOrdered: ["Spirometry"],
                diagnosesConsidered: ["Reflux", "Airway cause"]
            )
        ],
        expectedStages: [.exploration, .narrowing],
        expectedChangeKinds: [
            [],
            [.reconsideredExplanation, .orderedTesting, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .movedToTesting],
        notes: "Checks that failed treatment does not falsely become confirmation."
    )

    static let negativeTestingRevisionCase = ValidationCase(
        title: "Chest Testing Negative — Explanation Revised",
        threadTitle: "Persistent cough after infection",
        visits: [
            Visit(
                caseThreadId: negativeTestingThreadID,
                visitDate: date(2026, 3, 2),
                doctorName: "Dr White",
                clinicName: "South Medical Centre",
                visitType: .gp,
                reasonForVisit: "Cough after viral illness",
                doctorExplanation: "This may be a chest infection.",
                evidence: ["Persistent cough", "Mild sputum", "Recent viral illness"],
                decision: "Order chest X-ray.",
                nextSteps: ["Chest X-ray", "Review result next visit"],
                whatMightBeHappening: "The doctor thinks infection is one possible cause.",
                howSeriousItAppears: "It needs checking but may still be straightforward.",
                whatTheDoctorIsDoing: "The doctor is using testing to narrow the cause.",
                whatHappensNext: "You will have imaging and then review the result.",
                questionsForNextVisit: ["Was the X-ray clear?", "What explanation now fits best?"],
                oneLineVisitSummary: "Testing ordered for suspected chest infection.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Does the cough reflect infection or something else?",
                whatToWatchBeforeNextVisit: "Worsening breathing symptoms.",
                symptomsMentioned: ["Cough"],
                testsOrdered: ["Chest X-ray"],
                diagnosesConsidered: ["Chest infection"]
            ),
            Visit(
                caseThreadId: negativeTestingThreadID,
                visitDate: date(2026, 3, 10),
                doctorName: "Dr White",
                clinicName: "South Medical Centre",
                visitType: .gp,
                reasonForVisit: "Review after X-ray",
                doctorExplanation: "Because the X-ray is clear, post-viral airway inflammation now seems more likely than infection.",
                evidence: ["Chest X-ray clear", "No fever", "Persistent dry cough"],
                decision: "Start a trial inhaler.",
                nextSteps: ["Trial inhaler", "Review response in two weeks"],
                whatMightBeHappening: "The doctor now thinks airway inflammation is more likely than infection.",
                howSeriousItAppears: "The cause still needs follow-up, but a serious chest infection looks less likely.",
                whatTheDoctorIsDoing: "The doctor is revising the explanation and testing it with treatment.",
                whatHappensNext: "You will try treatment and then review whether it helps.",
                questionsForNextVisit: ["Did the inhaler help?", "Does airway irritation now fit best?"],
                oneLineVisitSummary: "Clear testing shifted the explanation toward airway inflammation.",
                mainChangeSinceLastVisit: "A clear X-ray made infection less likely and shifted the reasoning.",
                biggestOpenQuestion: "Will treatment response support airway inflammation?",
                whatToWatchBeforeNextVisit: "No improvement or worsening cough.",
                symptomsMentioned: ["Cough"],
                testsOrdered: ["Chest X-ray"],
                diagnosesConsidered: ["Chest infection", "Airway inflammation"]
            )
        ],
        expectedStages: [.exploration, .workingExplanation],
        expectedChangeKinds: [
            [],
            [.reconsideredExplanation, .startedTreatmentTrial, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .movedToTreatmentTrial],
        notes: "Checks that negative testing can drive explanation revision without false confirmation."
    )

    static let repeatedMonitoringBeforeClarityCase = ValidationCase(
        title: "Fatigue — Repeated Monitoring Before Clearer Explanation",
        threadTitle: "Persistent fatigue",
        visits: [
            Visit(
                caseThreadId: delayedClarityThreadID,
                visitDate: date(2026, 1, 6),
                doctorName: "Dr Brown",
                clinicName: "Westside Health",
                visitType: .gp,
                reasonForVisit: "Fatigue for several weeks",
                doctorExplanation: "The cause is not yet clear and may settle or need more information.",
                evidence: ["Fatigue", "No focal symptoms", "Still functioning day to day"],
                decision: "Monitor symptoms.",
                nextSteps: ["Monitor for now", "Return if persistent"],
                whatMightBeHappening: "The doctor does not yet have a clear explanation.",
                howSeriousItAppears: "The cause is uncertain but does not sound urgent yet.",
                whatTheDoctorIsDoing: "The doctor is watching how the symptoms develop.",
                whatHappensNext: "You monitor symptoms and return if they continue.",
                questionsForNextVisit: ["Is the fatigue improving?", "Have any new symptoms appeared?"],
                oneLineVisitSummary: "Initial monitoring for unexplained fatigue.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will the cause become clearer over time?",
                whatToWatchBeforeNextVisit: "Worsening fatigue or new symptoms.",
                symptomsMentioned: ["Fatigue"],
                testsOrdered: [],
                diagnosesConsidered: []
            ),
            Visit(
                caseThreadId: delayedClarityThreadID,
                visitDate: date(2026, 1, 20),
                doctorName: "Dr Brown",
                clinicName: "Westside Health",
                visitType: .gp,
                reasonForVisit: "Fatigue still present",
                doctorExplanation: "The cause is still not clear, so continued monitoring is reasonable.",
                evidence: ["Fatigue still present", "No major new symptoms"],
                decision: "Continue monitoring.",
                nextSteps: ["Follow up again", "Keep symptom diary"],
                whatMightBeHappening: "The cause remains uncertain.",
                howSeriousItAppears: "It is still unclear rather than alarming.",
                whatTheDoctorIsDoing: "The doctor is continuing to monitor for a clearer pattern.",
                whatHappensNext: "You continue monitoring and return again.",
                questionsForNextVisit: ["Is there any pattern to the fatigue?", "Are there any new symptoms?"],
                oneLineVisitSummary: "Monitoring continued because the pattern stayed unclear.",
                mainChangeSinceLastVisit: "The explanation still remained unclear.",
                biggestOpenQuestion: "Will a clearer pattern emerge?",
                whatToWatchBeforeNextVisit: "Any change in symptoms.",
                symptomsMentioned: ["Fatigue"],
                testsOrdered: [],
                diagnosesConsidered: []
            ),
            Visit(
                caseThreadId: delayedClarityThreadID,
                visitDate: date(2026, 2, 4),
                doctorName: "Dr Brown",
                clinicName: "Westside Health",
                visitType: .gp,
                reasonForVisit: "Fatigue ongoing",
                doctorExplanation: "Because the fatigue is ongoing, blood testing may help identify a cause.",
                evidence: ["Fatigue ongoing", "Persisting symptoms over several visits"],
                decision: "Order blood tests.",
                nextSteps: ["Blood test", "Review results"],
                whatMightBeHappening: "The doctor now thinks more information is needed to narrow the cause.",
                howSeriousItAppears: "It still may not be serious, but it needs more investigation.",
                whatTheDoctorIsDoing: "The doctor is moving from monitoring to testing.",
                whatHappensNext: "You will have blood tests and then review the result.",
                questionsForNextVisit: ["Did the blood test show a cause?", "What explanation now seems more likely?"],
                oneLineVisitSummary: "Persistent uncertainty led to blood testing.",
                mainChangeSinceLastVisit: "The doctor moved from monitoring to testing after repeated uncertainty.",
                biggestOpenQuestion: "Will testing reveal the cause?",
                whatToWatchBeforeNextVisit: "Worsening fatigue or new symptoms.",
                symptomsMentioned: ["Fatigue"],
                testsOrdered: ["Blood test"],
                diagnosesConsidered: []
            ),
            Visit(
                caseThreadId: delayedClarityThreadID,
                visitDate: date(2026, 2, 12),
                doctorName: "Dr Brown",
                clinicName: "Westside Health",
                visitType: .gp,
                reasonForVisit: "Review blood results",
                doctorExplanation: "The blood results suggest iron deficiency is the most likely explanation.",
                evidence: ["Low iron studies", "Persistent fatigue"],
                decision: "Start iron treatment.",
                nextSteps: ["Begin iron tablets", "Review energy improvement"],
                whatMightBeHappening: "The doctor now thinks iron deficiency is the most likely cause.",
                howSeriousItAppears: "The cause is becoming clearer and appears treatable.",
                whatTheDoctorIsDoing: "The doctor is acting on a clearer explanation.",
                whatHappensNext: "You start treatment and then review whether your energy improves.",
                questionsForNextVisit: ["Does energy improve with treatment?", "Does iron deficiency fully explain the fatigue?"],
                oneLineVisitSummary: "Testing made iron deficiency the leading explanation.",
                mainChangeSinceLastVisit: "Testing made the likely cause clearer.",
                biggestOpenQuestion: "Will treatment improve symptoms?",
                whatToWatchBeforeNextVisit: "No improvement with treatment.",
                symptomsMentioned: ["Fatigue"],
                testsOrdered: ["Blood test"],
                diagnosesConsidered: ["Iron deficiency"]
            )
        ],
        expectedStages: [.exploration, .narrowing, .narrowing, .workingExplanation],
        expectedChangeKinds: [
            [],
            [.continuedMonitoring, .newEvidenceInfluencedReasoning],
            [.orderedTesting, .newEvidenceInfluencedReasoning],
            [.reconsideredExplanation, .startedTreatmentTrial, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .movedToTesting, .movedToTreatmentTrial],
    )

    static let responseSupportStabilityCase = ValidationCase(
        title: "Inhaler Response — Improvement Becomes Stable",
        threadTitle: "Cough with inhaler response",
        visits: [
            Visit(
                caseThreadId: responseStabilityThreadID,
                visitDate: date(2026, 2, 8),
                doctorName: "Dr Young",
                clinicName: "Inner City Practice",
                visitType: .gp,
                reasonForVisit: "Persistent dry cough",
                doctorExplanation: "This may reflect airway irritation.",
                evidence: ["Dry cough", "No fever", "No major chest findings"],
                decision: "Start trial inhaler.",
                nextSteps: ["Trial inhaler", "Review in ten days"],
                whatMightBeHappening: "The doctor thinks airway irritation may explain the cough.",
                howSeriousItAppears: "It does not sound severe, but it needs follow-up.",
                whatTheDoctorIsDoing: "The doctor is testing an explanation with treatment.",
                whatHappensNext: "You try the inhaler and then review the response.",
                questionsForNextVisit: ["Did the inhaler help?", "Is the cough less frequent?"],
                oneLineVisitSummary: "Treatment trial started for suspected airway irritation.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will the response support the explanation?",
                whatToWatchBeforeNextVisit: "No benefit from treatment.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Airway irritation"]
            ),
            Visit(
                caseThreadId: responseStabilityThreadID,
                visitDate: date(2026, 2, 19),
                doctorName: "Dr Young",
                clinicName: "Inner City Practice",
                visitType: .gp,
                reasonForVisit: "Review after inhaler trial",
                doctorExplanation: "The improvement with the inhaler supports airway irritation as the explanation.",
                evidence: ["Cough improved", "Less frequent symptoms", "Some response to inhaler"],
                decision: "Continue inhaler.",
                nextSteps: ["Continue inhaler", "Review in two weeks"],
                whatMightBeHappening: "The doctor now has more confidence in the airway irritation explanation.",
                howSeriousItAppears: "It appears to be improving.",
                whatTheDoctorIsDoing: "The doctor is using improvement as evidence.",
                whatHappensNext: "You continue treatment and keep monitoring improvement.",
                questionsForNextVisit: ["Has improvement continued?", "Do symptoms return?"],
                oneLineVisitSummary: "Early improvement supported the explanation.",
                mainChangeSinceLastVisit: "The doctor gained confidence because treatment helped.",
                biggestOpenQuestion: "Will the improvement continue?",
                whatToWatchBeforeNextVisit: "Symptoms returning.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Airway irritation"]
            ),
            Visit(
                caseThreadId: responseStabilityThreadID,
                visitDate: date(2026, 3, 3),
                doctorName: "Dr Young",
                clinicName: "Inner City Practice",
                visitType: .gp,
                reasonForVisit: "Further review after continued treatment",
                doctorExplanation: "Continued improvement makes airway irritation the stable working explanation.",
                evidence: ["Ongoing improvement", "Minimal remaining cough"],
                decision: "Continue current treatment.",
                nextSteps: ["Continue treatment", "Return only if symptoms recur"],
                whatMightBeHappening: "The doctor thinks the explanation is now fairly stable.",
                howSeriousItAppears: "It appears to be settling well.",
                whatTheDoctorIsDoing: "The doctor is confirming the explanation through continued improvement.",
                whatHappensNext: "You continue the current plan unless symptoms return.",
                questionsForNextVisit: ["Do symptoms return later?"],
                oneLineVisitSummary: "Continued improvement made the explanation more stable.",
                mainChangeSinceLastVisit: "The explanation became more stable over time.",
                biggestOpenQuestion: "Will symptoms stay settled?",
                whatToWatchBeforeNextVisit: "Return of cough.",
                symptomsMentioned: ["Cough"],
                testsOrdered: [],
                diagnosesConsidered: ["Airway irritation"]
            )
        ],
        expectedStages: [.exploration, .confirmation, .confirmation],
        expectedChangeKinds: [
            [],
            [.reconsideredExplanation, .newEvidenceInfluencedReasoning],
            [.reconsideredExplanation, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .responseShift],
        notes: "Checks that improvement over time increases stability without needing new testing."
    )

    static let escalationAfterWatchfulWaitingCase = ValidationCase(
        title: "Abdominal Pain — Escalation After Watchful Waiting",
        threadTitle: "Persistent abdominal pain",
        visits: [
            Visit(
                caseThreadId: escalationThreadID,
                visitDate: date(2026, 1, 14),
                doctorName: "Dr Lee",
                clinicName: "Riverside Medical",
                visitType: .gp,
                reasonForVisit: "Intermittent abdominal pain",
                doctorExplanation: "This may settle, so watchful waiting is reasonable at this stage.",
                evidence: ["Intermittent pain", "No red-flag features", "Eating and drinking normally"],
                decision: "Monitor symptoms.",
                nextSteps: ["Watch symptoms", "Return if ongoing"],
                whatMightBeHappening: "The cause is not clear yet.",
                howSeriousItAppears: "It does not sound urgent right now.",
                whatTheDoctorIsDoing: "The doctor is watching the pattern before escalating.",
                whatHappensNext: "You monitor symptoms and return if they continue.",
                questionsForNextVisit: ["Is the pain still happening?", "Has the pattern changed?"],
                oneLineVisitSummary: "Initial watchful waiting for abdominal pain.",
                mainChangeSinceLastVisit: "First recorded visit.",
                biggestOpenQuestion: "Will the pain settle or persist?",
                whatToWatchBeforeNextVisit: "Worsening pain or new symptoms.",
                symptomsMentioned: ["Abdominal pain"],
                testsOrdered: [],
                diagnosesConsidered: []
            ),
            Visit(
                caseThreadId: escalationThreadID,
                visitDate: date(2026, 1, 28),
                doctorName: "Dr Lee",
                clinicName: "Riverside Medical",
                visitType: .gp,
                reasonForVisit: "Pain still recurring",
                doctorExplanation: "Because the pain is still recurring, more investigation is now appropriate.",
                evidence: ["Pain still recurring", "Symptoms not settling"],
                decision: "Order abdominal ultrasound.",
                nextSteps: ["Abdominal ultrasound", "Review scan result"],
                whatMightBeHappening: "The doctor now thinks more testing is needed to narrow the cause.",
                howSeriousItAppears: "The cause still may not be serious, but it now needs checking.",
                whatTheDoctorIsDoing: "The doctor is moving from watchful waiting to testing.",
                whatHappensNext: "You will have an ultrasound and then review the result.",
                questionsForNextVisit: ["Did the scan show a cause?", "What is now more likely?"],
                oneLineVisitSummary: "Persistent symptoms led to escalation into testing.",
                mainChangeSinceLastVisit: "The doctor escalated from monitoring to testing.",
                biggestOpenQuestion: "What is causing the ongoing pain?",
                whatToWatchBeforeNextVisit: "Worsening pain or new symptoms.",
                symptomsMentioned: ["Abdominal pain"],
                testsOrdered: ["Abdominal ultrasound"],
                diagnosesConsidered: []
            )
        ],
        expectedStages: [.exploration, .narrowing],
        expectedChangeKinds: [
            [],
            [.continuedMonitoring, .reconsideredExplanation, .orderedTesting, .newEvidenceInfluencedReasoning]
        ],
        expectedTurningPoints: [.initialFrame, .movedToTesting],
        notes: "Checks escalation after watchful waiting."
    )

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
