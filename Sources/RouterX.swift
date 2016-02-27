import Foundation

public typealias RouteTerminalHandlerType = ([String:String] -> Void)

public enum RouteMatchingResult {
    case Matched(parameters: [String:String], handler: RouteTerminalHandlerType, pattern: String)
    case UnMatched
}

public class Router {
    private let rootRoute: RouteVertex

    public init() {
        self.rootRoute = RouteVertex(pattern: "")
    }

    public func registerRoutingPattern(pattern: String, handler: RouteTerminalHandlerType) throws {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, terminalHandler: handler)
    }

    public func matchRoute(uriPath: String) -> RouteMatchingResult {
        let tokens = URIPathScanner.tokenize(uriPath)

        if tokens.isEmpty {
            return .UnMatched
        }

        var tokensGenerator = tokens.generate()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            if let currentRoute = targetRoute.toNextVertex(token.routeEdge) {
                targetRoute = currentRoute
            } else {
                return .UnMatched
            }
        }

        guard targetRoute.isTerminal else {
            return .UnMatched
        }

        var parameters: [String: String] = [:]
        for (k, i) in targetRoute.placeholderMappings {
            if case .Literal(let value) = tokens[i] {
                parameters[k] = value
            } else {
                parameters[k] = ""
            }
        }

        return .Matched(parameters: parameters, handler: targetRoute.handler!, pattern: targetRoute.pattern)
    }
}
