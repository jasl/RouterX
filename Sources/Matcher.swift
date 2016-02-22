import Foundation

public enum URIToken {
    case Slash
    case Dot
    case Literal(String)

    var routeEdge: RouteEdge {
        switch self {
        case .Slash:
            return .Slash
        case .Dot:
            return .Dot
        case let .Literal(value):
            return .Literal(value)
        }
    }
}

extension URIToken: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .Slash:
            return "/"
        case .Dot:
            return "."
        case .Literal(let value):
            return value
        }
    }

    public var debugDescription: String {
        switch self {
        case .Slash:
            return "[Slash]"
        case .Dot:
            return "[Dot]"
        case .Literal(let value):
            return "[Literal \"\(value)\"]"
        }
    }
}

public struct URIScanner {
    private let stopWordsSet: Set<Character> = [".", "/"]

    public let uri: String
    private(set) var position: String.Index

    public init(uri: String) {
        self.uri = uri
        self.position = self.uri.startIndex
    }

    public var isEOF: Bool {
        return self.position == self.uri.endIndex
    }

    private var unScannedFragment: String {
        return self.uri.substringFromIndex(self.position)
    }

    public mutating func nextToken() -> URIToken? {
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
            if stopWordsSet.contains(char) {
                break
            }

            fragment.append(char)
            stepPosition += 1
        }

        self.position = self.position.advancedBy(stepPosition)

        return .Literal("\(firstChar)\(fragment)")
    }

    public static func tokenize(uri: String) -> [URIToken] {
        var scanner = self.init(uri: uri)

        var tokens: [URIToken] = []
        while let token = scanner.nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}

public func match(uri: String, route: RouteVertex) -> RouteVertex? {
    let tokens = URIScanner.tokenize(uri)

    if tokens.isEmpty {
        return nil
    }

    var tokensGenerator = tokens.generate()
    var currentRoute: RouteVertex? = route
    while let token = tokensGenerator.next() {
        currentRoute = currentRoute!.toNextVertex(token.routeEdge)

        if currentRoute == nil {
            return nil
        }
    }

    return currentRoute
}
