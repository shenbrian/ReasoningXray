import Foundation

struct ValidationExplainer {

    func explanation(for result: ValidationResult) -> [String] {

        var messages: [String] = []

        // Stage evaluation
        if result.detectedStages.isEmpty {
            messages.append("⚠️ No reasoning stage detected.")
        } else {
            messages.append("✓ Stage detection succeeded: \(result.detectedStages.joined(separator: ", ")).")
        }

        // Change detection
        if result.detectedChangeKinds.flatMap({ $0 }).isEmpty {
            messages.append("✓ No reasoning change detected.")
        } else {
            let changes = result.detectedChangeKinds
                .flatMap { $0 }
                .joined(separator: ", ")
            messages.append("✓ Reasoning change detected: \(changes).")
        }

        // Turning point detection
        if result.detectedTurningPoints.isEmpty {
            messages.append("✓ No turning point detected.")
        } else {
            messages.append("✓ Turning point detected: \(result.detectedTurningPoints.joined(separator: ", ")).")
        }

        // Wording notes
        if !result.wordingNotes.isEmpty {
            messages.append("⚠️ Wording issues: \(result.wordingNotes.joined(separator: ", "))")
        }

        // Timeline notes
        if !result.timelineNotes.isEmpty {
            messages.append("⚠️ Timeline issues: \(result.timelineNotes.joined(separator: ", "))")
        }

        return messages
    }
}
//

