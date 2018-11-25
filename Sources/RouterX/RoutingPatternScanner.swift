import Foundation

private enum _PatternScanTerminator: Character {
    case lParen = "("
    case rParen = ")"
    case slash = "/"
    case dot = "."
    case star = "*"

    var jointFragment: (token: RoutingPatternToken?, fragment: String) {
        switch self {
        case .lParen:
            return (token: .lParen, fragment: "")
        case .rParen:
            return (token: .rParen, fragment: "")
        case .slash:
            return (token: .slash, fragment: "")
        case .dot:
            return (token: .dot, fragment: "")
        case .star:
            return (token: nil, fragment: "*")
        }
    }
}

internal struct RoutingPatternScanner {

    static func tokenize(_ pattern: PatternIdentifier) -> [RoutingPatternToken] {
        guard !pattern.isEmpty else { return [] }

        var appending = ""
        var result: [RoutingPatternToken] = pattern.reduce(into: []) { box, char in
            guard let terminator = _PatternScanTerminator(rawValue: char) else {
                appending.append(char)
                return
            }

            let jointFragment = terminator.jointFragment
            defer {
                if let token = jointFragment.token {
                    box.append(token)
                }
                appending = jointFragment.fragment
            }

            guard let jointToken = _generateToken(expression: appending) else { return }
            box.append(jointToken)
        }

        if let tailToken = _generateToken(expression: appending) {
            result.append(tailToken)
        }
        return result
    }

    static private func _generateToken(expression: String) -> RoutingPatternToken? {
        guard let firstChar = expression.first else { return nil }
        let fragments = String(expression.dropFirst())
        switch firstChar {
        case ":":
            return .symbol(fragments)
        case "*":
            return .star(fragments)
        default:
            return .literal(expression)
        }
    }
}
