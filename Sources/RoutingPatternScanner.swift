import Foundation

public struct RoutingPatternScanner {
    fileprivate static let stopWordsSet: Set<Character> = ["(", ")", "/"]

    public let expression: String

    private(set) var position: String.Index

    public init(expression: String) {
        self.expression = expression
        self.position = self.expression.startIndex
    }

    public var isEOF: Bool {
        return self.position == self.expression.endIndex
    }

    private var unScannedFragment: String {
        return String(expression[position..<expression.endIndex])
    }
    
    public mutating func nextToken() -> RoutingPatternToken? {
        guard !isEOF else { return nil }
        
         guard let firstChar = unScannedFragment.first else { return nil }

        self.position = expression.index(position, offsetBy: 1)

        switch firstChar {
        case "/":
            return .slash
        case ".":
            return .dot
        case "(":
            return .lParen
        case ")":
            return .rParen
        default:
            break
        }

        var fragment = ""
        var stepPosition = 0
        for char in self.unScannedFragment {
            if RoutingPatternScanner.stopWordsSet.contains(char) {
                break
            }

            fragment.append(char)
            stepPosition += 1
        }

        self.position = expression.index(self.position, offsetBy: stepPosition)

        switch firstChar {
        case ":":
            return .symbol(fragment)
        case "*":
            return .star(fragment)
        default:
            return .literal("\(firstChar)\(fragment)")
        }
    }

    public static func tokenize(_ expression: String) -> [RoutingPatternToken] {
        var scanner = RoutingPatternScanner(expression: expression)

        var tokens: [RoutingPatternToken] = []
        while let token = scanner.nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}
