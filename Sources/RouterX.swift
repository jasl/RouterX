import Foundation

public typealias RouteTerminalHandlerType = ([String:String] -> Void)
public typealias RouteUnmatchHandlerType = ((String) -> ())

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

    public func matchRouteAndDoHandler(uriPath: String, unmatchHandler: RouteUnmatchHandlerType? = nil) {
        let tokens = URIPathScanner.tokenize(uriPath)

        if tokens.isEmpty {
            if let handler = unmatchHandler {
                handler(uriPath)
            } else {
                self.defaultUnmatchHandler(uriPath)
            }
            return
        }

        var tokensGenerator = tokens.generate()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            if let currentRoute = targetRoute.toNextVertex(token.routeEdge) {
                targetRoute = currentRoute
            } else {
                if let handler = unmatchHandler {
                    handler(uriPath)
                } else {
                    self.defaultUnmatchHandler(uriPath)
                }
                return
            }
        }

        guard let terminalHandler = targetRoute.handler else {
            if let handler = unmatchHandler {
                handler(uriPath)
            } else {
                self.defaultUnmatchHandler(uriPath)
            }
            return
        }

        var parameters: [String: String] = [:]
        for (k, i) in targetRoute.placeholderMappings {
            if case .Literal(let value) = tokens[i] {
                parameters[k] = value
            } else {
                parameters[k] = ""
            }
        }

        terminalHandler(parameters)
    }
}
