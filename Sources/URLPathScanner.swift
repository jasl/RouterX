import Foundation

public struct URLPathScanner {
    private static let stopWordsSet: Set<Character> = [".", "/"]

    public let path: String
    private(set) var position: String.Index

    public init(path: String) {
        self.path = path
        self.position = self.path.startIndex
    }

    public var isEOF: Bool {
        return self.position == self.path.endIndex
    }

    private var unScannedFragment: String {
        return self.path.substringFromIndex(self.position)
    }

    public mutating func nextToken() -> URLPathToken? {
        if self.isEOF {
            return nil
        }

        let firstChar = self.unScannedFragment.characters.first!

        self.position = self.position.advancedBy(1)

        switch firstChar {
        case "/":
            return .Slash
        case ".":
            return .Dot
        default:
            break
        }

        var fragment = ""
        var stepPosition = 0
        for char in self.unScannedFragment.characters {
            if URLPathScanner.stopWordsSet.contains(char) {
                break
            }

            fragment.append(char)
            stepPosition += 1
        }

        self.position = self.position.advancedBy(stepPosition)

        return .Literal("\(firstChar)\(fragment)")
    }

    public static func tokenize(path: String) -> [URLPathToken] {
        var scanner = self.init(path: path)

        var tokens: [URLPathToken] = []
        while let token = scanner.nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}
