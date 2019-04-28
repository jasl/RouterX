import Foundation

internal struct URLPathScanner {
    private static let stopWordsSet: Set<Character> = [".", "/"]

    let path: String
    private(set) var startIndex: String.Index

    init(path: String) {
        self.path = path
        self.startIndex = self.path.startIndex
    }

    var isEOF: Bool {
        return self.startIndex == self.path.endIndex
    }

    private var unScannedFragment: String {
        return String(path[startIndex ..< path.endIndex])
    }

    mutating func nextToken() -> URLPathToken? {
        let unScanned = unScannedFragment
        guard let firstChar = unScanned.first else {
            // Is end of file
            return nil
        }

        let offset: Int

        defer {
            startIndex = path.index(startIndex, offsetBy: offset)
        }

        switch firstChar {
        case "/":
            offset = 1
            return .slash
        case ".":
            offset = 1
            return .dot
        default:
            break
        }

        let clipStep = unScanned.firstIndex(where: { URLPathScanner.stopWordsSet.contains($0) }) ?? unScanned.endIndex
        let literal = unScanned[unScanned.startIndex..<clipStep]
        offset = clipStep.utf16Offset(in: unScanned)

        return .literal("\(literal)")
    }

    static func tokenize(_ path: String) -> [URLPathToken] {
        var scanner = self.init(path: path)

        var tokens: [URLPathToken] = []
        while let token = scanner.nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}
