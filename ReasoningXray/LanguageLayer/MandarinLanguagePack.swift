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
    
    let approvedFallbacks: [TrajectoryState: [String]] = [
        .narrowing: [
            "医生仍在进一步观察情况。",
            "接下来需要继续跟踪变化。",
            "目前仍需时间来确认趋势。"
        ],
        .exploring: [
            "医生仍在考虑几种可能性。",
            "目前还没有形成明确方向。",
            "仍在收集更多线索。"
        ],
        .workingExplanation: [
            "目前已有较为集中的解释方向。",
            "医生正在围绕一个主要思路推进。",
            "已有一个更聚焦的判断框架。"
        ],
        .confirmation: [
            "目前判断已比之前更明确。",
            "现阶段的解释稳定性有所提升。",
            "方向正在逐步被确认。"
        ]
    ]
    
    func initialCandidate(for carrier: SignalCarrier) -> String {
        let domain = carrier.domains.first ?? .trajectory
        
        switch domain {
            
        case .certainty:
            switch carrier.certaintyState {
            case .activeUncertainty:
                let options = [
                    "目前还不能清楚判断原因。",
                    "现在仍存在一定不确定性。",
                    "当前还不足以形成明确解释。"
                ]
                return options.randomElement()!
                
            case .emergingClarity:
                let options = [
                    "这个解释目前变得更有可能。",
                    "现有信息使某个方向更被支持。",
                    "当前证据开始偏向一种解释。"
                ]
                return options.randomElement()!
                
            case .workingExplanation:
                let options = [
                    "目前已有一个较为可信的解释方向。",
                    "医生暂时更倾向于这个原因。",
                    "当前判断已有一定把握，但仍需确认。"
                ]
                return options.randomElement()!
                
            case .stabilizingUnderstanding:
                let options = [
                    "目前判断已经相对明确。",
                    "这个解释现在比之前更稳定。",
                    "现阶段的理解比之前更清晰。"
                ]
                return options.randomElement()!
            }
            
        case .expectation:
            switch carrier.expectationState {
            case .clarityMayIncrease:
                let options = [
                    "后续情况可能会带来更多清晰度。",
                    "随着后续进展，判断可能会更清楚一些。",
                    "接下来有机会看到更明确的变化方向。"
                ]
                return options.randomElement()!

            case .moreInformationNeeded:
                let options = [
                    "目前还需要更多信息来支持判断。",
                    "现阶段仍需更多线索才能更清楚地理解情况。",
                    "还需要进一步信息，判断才会更稳定。"
                ]
                return options.randomElement()!

            case .followUpMatters:
                let options = [
                    "后续情况将帮助进一步确认判断。",
                    "接下来的复查对理解变化很重要。",
                    "后续跟进会帮助看清情况的发展。"
                ]
                return options.randomElement()!

            case .noImmediateResolutionExpected:
                let options = [
                    "现阶段还需要继续观察变化。",
                    "目前不太可能立刻得到最终结论。",
                    "接下来更重要的是观察情况如何发展。"
                ]
                return options.randomElement()!

            case nil:
                let options = [
                    "接下来还需要继续观察变化。",
                    "后续情况将帮助进一步确认判断。",
                    "下一步主要是看情况是否持续改善。"
                ]
                return options.randomElement()!
            }
            
        case .authority:
            let options = [
                "医生目前选择先维持当前处理方式。",
                "现阶段仍以继续观察和跟进为主。",
                "医生暂时没有做更大的处理调整。"
            ]
            return options.randomElement()!
            
        case .emotionalTone:
            let options = [
                "目前没有迹象显示情况特别紧急。",
                "现阶段更像是谨慎观察，而不是严重变化。",
                "现在重点仍是稳妥评估，而不是过度担心。"
            ]
            return options.randomElement()!
            
        case .trajectory:
            switch carrier.trajectoryState {
            case .exploring:
                let options = [
                    "医生目前仍在评估几种可能的解释。",
                    "现在还在观察不同方向的发展。",
                    "当前信息还不足以形成明确判断。"
                ]
                return options.randomElement()!
                
            case .narrowing:
                let options = [
                    "医生的判断正在逐渐集中到一个较可能的解释上。",
                    "当前证据开始支持某一个方向。",
                    "现有信息使某种解释变得更有可能。"
                ]
                return options.randomElement()!
                
            case .workingExplanation:
                let options = [
                    "目前已有一个较为集中的解释思路。",
                    "医生暂时倾向于某个主要原因。",
                    "当前判断已有一定方向性，但仍需确认。"
                ]
                return options.randomElement()!
                
            case .confirmation:
                let options = [
                    "目前的判断已经比之前更加明确。",
                    "医生对当前解释的把握明显提高。",
                    "现阶段的结论相对稳定。"
                ]
                return options.randomElement()!
            }
        }
    }
}
