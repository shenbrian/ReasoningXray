import Foundation

struct EpistemicPhraseBank {

    static func certaintyLow() -> [String] {
        [
            "目前仍存在一定不确定性。",
            "现在还不能完全确定原因。",
            "情况还在观察阶段。",
            "解释仍属于初步判断。"
        ]
    }

    static func certaintyModerate() -> [String] {
        [
            "这个解释目前变得更有可能。",
            "医生的判断正在逐渐聚焦。",
            "当前证据支持这一方向。",
            "情况开始出现更清晰的趋势。"
        ]
    }

    static func certaintyHigh() -> [String] {
        [
            "医生对这个解释已较为有把握。",
            "目前判断相对明确。",
            "大多数迹象指向这个原因。",
            "解释已接近确定状态。"
        ]
    }

    static func expectationSoft() -> [String] {
        [
            "接下来通常会继续观察变化。",
            "后续复诊可以帮助确认进展。",
            "未来的变化仍值得关注。",
            "下一步主要是跟踪情况。"
        ]
    }

    static func authoritySoft() -> [String] {
        [
            "医生选择暂时维持当前方案。",
            "目前处理方式保持稳定。",
            "现阶段更倾向于持续观察。",
            "暂未进行重大调整。"
        ]
    }
}
