import Foundation

public struct URLPathScanner {
    fileprivate static let stopWordsSet: Set<Character> = [".", "/"]

    public let path: String
    fileprivate(set) var position: String.Index

    public init(path: String) {
        self.path = path
        self.position = self.path.startIndex
    }

    public var isEOF: Bool {
        return self.position == self.path.endIndex
    }

    fileprivate var unScannedFragment: String {
        return self.path.substring(from: self.position)
    }

    public mutating func nextToken() -> URLPathToken? {
        if self.isEOF {
            return nil
        }

        let firstChar = self.unScannedFragment.characters.first!
      
        self.position = path.index(self.position, offsetBy: 1)

        switch firstChar {
        case "/":
            return .slash
        case ".":
            return .dot
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

        self.position = path.index(self.position, offsetBy: stepPosition)

        return .literal("\(firstChar)\(fragment)")
    }

    public static func tokenize(_ path: String) -> [URLPathToken] {
        var scanner = self.init(path: path)

        var tokens: [URLPathToken] = []
        while let token = scanner.nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}
