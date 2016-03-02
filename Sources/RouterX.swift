import Foundation

public typealias RouteTerminalHandlerType = ([String:String] -> Void)
public typealias RouteUnmatchHandlerType = ((String) -> ())

public struct MatchedRoute {
    public let parametars: [String: String]
    public let pattern: String
    private let handler: RouteTerminalHandlerType

    public init(parameters: [String: String], pattern: String, handler: RouteTerminalHandlerType) {
        self.pattern = pattern
        self.parametars = parameters
        self.handler = handler
    }

    public func doHandler() {
        self.handler(self.parametars)
    }
}

public class Router {
    private let rootRoute: RouteVertex
    private let defaultUnmatchHandler: RouteUnmatchHandlerType

    public init(defaultUnmatchHandler: RouteUnmatchHandlerType? = nil) {
        self.rootRoute = RouteVertex(pattern: "")

        if let unmatchHandler = defaultUnmatchHandler {
            self.defaultUnmatchHandler = unmatchHandler
        } else {
            self.defaultUnmatchHandler = { _ in }
        }
    }

    public func registerRoutingPattern(pattern: String, handler: RouteTerminalHandlerType) throws {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, terminalHandler: handler)
    }

    public func matchAndDoHandler(uriPath: String, unmatchHandler: RouteUnmatchHandlerType? = nil) {
        guard let matchedRoute = self.match(uriPath) else {
            if let handler = unmatchHandler {
                handler(uriPath)
            } else {
                self.defaultUnmatchHandler(uriPath)
            }

            return
        }

        matchedRoute.doHandler()
    }

    private func match(uriPath: String) -> MatchedRoute? {
        let tokens = URIPathScanner.tokenize(uriPath)

        if tokens.isEmpty {
            return nil
        }

        var tokensGenerator = tokens.generate()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            guard let currentRoute = targetRoute.toNextVertex(token.routeEdge) else {
                return nil
            }

            targetRoute = currentRoute
        }

        guard let handler = targetRoute.handler else {
            return nil
        }

        var parameters: [String: String] = [:]
        for (k, i) in targetRoute.placeholderMappings {
            if case .Literal(let value) = tokens[i] {
                parameters[k] = value
            }
        }

        return MatchedRoute(parameters: parameters, pattern: targetRoute.pattern, handler: handler)
    }
}
