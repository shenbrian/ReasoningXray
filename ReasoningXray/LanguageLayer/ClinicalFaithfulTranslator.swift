import Foundation

final class ClinicalFaithfulTranslator {

    private let bank: [String: String] = [
        // Existing cough / X-ray flow
        "Persistent cough with limited improvement": "持续咳嗽，改善有限",
        "The doctor thinks there may be another reason for the cough besides a normal recovery after infection.": "医生认为，除感染后正常恢复外，咳嗽可能还有其他原因。",
        "Still not presented as an emergency, but enough to justify further testing.": "目前尚未表现为紧急情况，但已足以支持进一步检查。",
        "The doctor is ordering a chest X-ray to look for other causes.": "医生正在安排胸部X光检查，以寻找其他可能原因。",
        "Test results will help decide the next step.": "检查结果将有助于决定下一步处理。",
        "What did the X-ray show?": "X光结果显示了什么？",
        "Is asthma becoming more likely?": "哮喘的可能性是否正在增加？",
        "The doctor became more concerned that the cough might not be purely post-viral and ordered imaging to rule out other causes.": "医生更加担心咳嗽不只是病毒感染后的恢复，因此安排影像检查以排除其他原因。",
        "Persistence over several weeks": "已持续数周",
        "Poor improvement": "改善不明显",
        "Repeat presentation": "再次就诊",
        "Order chest X-ray": "安排胸部X光检查",
        "Complete chest X-ray": "完成胸部X光检查",
        "Review results at next visit": "下次就诊时查看检查结果",
        "Reasoning shifted from watchful waiting to further investigation.": "医生的判断已从继续观察转向进一步检查。",

        // Strings visible in the current visit-detail screen
        "Review chest X-ray and ongoing cough": "复查胸部X光结果及持续咳嗽情况",
        "The doctor now seems to think the cough may be related to irritated airways or possible asthma.": "医生现在倾向于认为，咳嗽可能与气道受刺激或可能的哮喘有关。",
        "Still under active management, but not described as dangerous right now.": "目前仍在积极处理中，但暂未被描述为危险情况。",
        "The doctor reconsidered the earlier explanation, The doctor started a treatment trial, and New information affected the doctor's thinking.": "医生重新考虑了先前的解释，开始了治疗性试验，并且新的信息影响了医生的判断。",
        "The doctor reconsidered the earlier explanation, the doctor started a treatment trial, and new information affected the doctor's thinking.": "医生重新考虑了先前的解释，开始了治疗性试验，并且新的信息影响了医生的判断。",

        // Common visit-detail phrases
        "The doctor now seems to think the cough may be related to irritated airways or possible asthma": "医生现在倾向于认为，咳嗽可能与气道受刺激或可能的哮喘有关。",
        "Still under active management, but not described as dangerous right now": "目前仍在积极处理中，但暂未被描述为危险情况。",
        "Reasoning shifted from further investigation toward treatment trial.": "医生的判断已从进一步检查转向治疗性试验。",
        "The doctor is now considering irritated airways or asthma as a more likely explanation.": "医生现在更倾向于考虑气道受刺激或哮喘作为较可能的解释。",
        "Treatment response will help clarify the next step.": "对治疗的反应将有助于明确下一步处理。",
        "Did the treatment help?": "治疗是否有帮助？",
        "Is asthma now more likely?": "现在哮喘是否更可能？",
        
        "Review inhaler response": "复查吸入治疗反应",
        "The cough now seems more likely related to inflamed or sensitive airways.": "咳嗽现在看起来更可能与气道发炎或敏感有关。",
        "The recent response to treatment makes this explanation more plausible, though the cause is still being confirmed.": "近期对治疗的反应使这一解释更为可信，不过病因仍在进一步确认中。",
        "The doctor is continuing treatment while checking how much benefit it is providing.": "医生正在继续治疗，同时观察这种治疗带来了多大改善。",
        "Our next review will check whether the response continues and whether this explanation still fits best.": "下次复查将观察这种反应是否持续，并判断这一解释是否仍然最符合情况。",
        "Did the inhaler help?": "吸入治疗是否有帮助？",
        "Is airway irritation now the leading explanation?": "气道刺激现在是否是最主要的解释？",
        "The doctor reconsidered the earlier explanation and new information affected the doctor's thinking.": "医生重新考虑了先前的解释，并且新的信息影响了医生的判断。",
        "The doctor reconsidered the earlier explanation, and new information affected the doctor's thinking.": "医生重新考虑了先前的解释，并且新的信息影响了医生的判断。",
        "Review response to treatment": "复查治疗反应",
        "Treatment response is now influencing the doctor's reasoning.": "治疗反应现在正在影响医生的判断。",
        "Improvement after treatment": "治疗后有所改善",
        "Inhaler trial": "吸入治疗试验",
        "Continue inhaler and review response": "继续吸入治疗并复查反应"
    ]

    func translate(_ text: String) -> String {
        let normalized = normalize(text)

        if let exact = bank[text] {
            return exact
        }

        if let normalizedMatch = bank.first(where: { normalize($0.key) == normalized })?.value {
            return normalizedMatch
        }

        return text
    }

    private func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
