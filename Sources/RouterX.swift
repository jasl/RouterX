import Foundation

public typealias RouteTerminalHandlerType = (([String:String], context: AnyObject?) -> Void)
public typealias RouteUnmatchHandlerType = ((String, context: AnyObject?) -> ())

public struct MatchedRoute {
    public let parametars: [String: String]
    public let pattern: String
    private let handler: RouteTerminalHandlerType

    public init(parameters: [String: String], pattern: String, handler: RouteTerminalHandlerType) {
        self.pattern = pattern
        self.parametars = parameters
        self.handler = handler
    }

    public func doHandler(context: AnyObject? = nil) {
        self.handler(self.parametars, context: context)
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
            self.defaultUnmatchHandler = { (_, _) in }
        }
    }

    public func registerRoutingPattern(pattern: String, handler: RouteTerminalHandlerType) -> Bool {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        do {
            try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, terminalHandler: handler)

            return true
        } catch {
            return false
        }
    }

    public func matchAndDoHandler(uriPath: String, context: AnyObject? = nil, unmatchHandler: RouteUnmatchHandlerType? = nil) -> Bool {
        guard let matchedRoute = self.match(uriPath) else {
            if let handler = unmatchHandler {
                handler(uriPath, context: context)
            } else {
                self.defaultUnmatchHandler(uriPath, context: context)
            }

            return false
        }

        matchedRoute.doHandler(context)

        return true
    }

    public func match(uriPath: String) -> MatchedRoute? {
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
