import Foundation

public struct MatchedRoute {
    public let url: URL
    public let parametars: [String: String]
    public let patternIdentifier: PatternIdentifier

    public init(url: URL, parameters: [String: String], patternIdentifier: PatternIdentifier) {
        self.url = url
        self.parametars = parameters
        self.patternIdentifier = patternIdentifier
    }
}

public class RouterXCore {
    private let rootRoute: RouteVertex

    public init() {
        self.rootRoute = RouteVertex()
    }

    public func register(pattern: String) throws {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        guard let prefixToken = tokens.first else { throw PatternRegisterError.empty }
        guard prefixToken == .slash else { throw PatternRegisterError.missingPrefixSlash }

        var previousToken: RoutingPatternToken?
        var stackTokensDescription = ""
        var parenthesisOffset = 0
        for token in tokens {
            switch token {
            case .star(let globbing):
                if previousToken != .slash { throw PatternRegisterError.invalidGlobbing(globbing: globbing, after: stackTokensDescription) }
            case .symbol(let symbol):
                if previousToken != .slash && previousToken != .dot { throw PatternRegisterError.invalidSymbol(symbol: symbol, after: stackTokensDescription) }
            case .lParen:
                parenthesisOffset += 1
            case .rParen:
                if parenthesisOffset <= 0 {
                    throw PatternRegisterError.unexpectToken(after: stackTokensDescription)
                }
                parenthesisOffset -= 1
            default: break
            }
            stackTokensDescription.append(token.description)
            previousToken = token
        }

        guard parenthesisOffset == 0 else {
            throw PatternRegisterError.unbalanceParenthesis
        }
        try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, patternIdentifier: pattern)
    }

    public func match(_ url: URL) -> MatchedRoute? {
        let path = url.path

        let tokens = URLPathScanner.tokenize(path)
        if tokens.isEmpty {
            return nil
        }

        var parameters: [String: String] = [:]

        var tokensGenerator = tokens.makeIterator()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            if let determinativeRoute = targetRoute.namedRoutes[token.routeEdge] {
                targetRoute = determinativeRoute
            } else if let epsilonRoute = targetRoute.parameterRoute {
                targetRoute = epsilonRoute.1
                parameters[epsilonRoute.0] = String(describing: token).removingPercentEncoding ?? ""
            } else {
                return nil
            }
        }

        guard let pathPatternIdentifier = targetRoute.patternIdentifier else { return nil }

        return MatchedRoute(url: url, parameters: parameters, patternIdentifier: pathPatternIdentifier)
    }

    public func match(_ path: String) -> MatchedRoute? {
        guard let url = URL(string: path) else { return nil }
        return match(url)
    }
}

extension RouterXCore: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return self.rootRoute.description
    }

    public var debugDescription: String {
        return self.description
    }
}
