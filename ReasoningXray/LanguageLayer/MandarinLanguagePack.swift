import Foundation

struct MandarinLanguagePack {
    let languageCode = "zh-Hans"

    let certaintyAdjustments: [String: Double] = [
        "似乎": -0.10,
        "看起来": -0.10,
        "可能": -0.15,
        "已经": 0.20,
        "确定": 0.40,
        "是": 0.25
    ]

    let temporalAdjustments: [String: Double] = [
        "逐渐": -0.05,
        "还需要时间": -0.10,
        "可能会": 0.10,
        "将会": 0.35,
        "很快": 0.25
    ]

    let authorityAdjustments: [String: Double] = [
        "目前": 0.05,
        "医生": -0.05,
        "思路": -0.02,
        "需要": 0.25,
        "应该": 0.40
    ]

    let emotionalAdjustments: [String: Double] = [
        "观察": -0.05,
        "评估": -0.05,
        "担心": 0.25,
        "严重": 0.35,
        "危险": 0.50
    ]

    let forbiddenPatterns: [String] = [
        "可以确定",
        "已经证明",
        "一定是",
        "会解决",
        "你应该",
        "你需要"
    ]

    let approvedFallbacks: [TrajectoryState: String] = [
        .narrowing: "医生仍在进一步观察情况。"
    ]

    func initialCandidate(for carrier: SignalCarrier) -> String {
        switch carrier.trajectoryState {
        case .narrowing:
            return "医生的思路似乎正在逐渐聚焦到一个更具体的解释上。"
        case .exploring:
            return "医生仍在考虑几种可能性。"
        case .workingExplanation:
            return "目前有一个较为集中的解释方向，但还不是最终结论。"
        case .confirmation:
            return "目前的判断已经比之前更明确。"
        }
    }
}
