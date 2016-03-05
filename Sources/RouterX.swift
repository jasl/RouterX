import Foundation

public typealias RouteTerminalHandlerType = (([String:String], context: AnyObject?) -> Void)
public typealias RouteUnmatchHandlerType = ((NSURL, context: AnyObject?) -> ())

public struct MatchedRoute {
    public let parametars: [String: String]
    private let handler: RouteTerminalHandlerType

    public init(parameters: [String: String], handler: RouteTerminalHandlerType) {
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

    public func matchURL(url: NSURL) -> MatchedRoute? {
        guard let path = url.path else {
            return nil
        }

        let tokens = URIPathScanner.tokenize(path)
        if tokens.isEmpty {
            return nil
        }

        var parameters: [String: String] = [:]

        var tokensGenerator = tokens.generate()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            if let determinativeRoute = targetRoute.nextRoutes[token.routeEdge] {
                targetRoute = determinativeRoute
            } else if let epsilonRoute = targetRoute.epsilonRoute {
                targetRoute = epsilonRoute.1
                parameters[epsilonRoute.0] = String(token).stringByRemovingPercentEncoding ?? ""
            } else {
                return nil
            }
        }

        guard let handler = targetRoute.handler else {
            return nil
        }

        parameters.unionInPlace(url.queryDictionary)

        return MatchedRoute(parameters: parameters, handler: handler)
    }

    public func matchURLPath(urlPath: String) -> MatchedRoute? {
        guard let url = NSURL(string: urlPath) else {
            return nil
        }

        return matchURL(url)
    }

    public func matchURLAndDoHandler(url: NSURL, context: AnyObject? = nil, unmatchHandler: RouteUnmatchHandlerType? = nil) -> Bool {
        guard let matchedRoute = self.matchURL(url) else {
            if let handler = unmatchHandler {
                handler(url, context: context)
            } else {
                self.defaultUnmatchHandler(url, context: context)
            }

            return false
        }

        matchedRoute.doHandler(context)

        return true
    }

    public func matchURLPathAndDoHandler(urlPath: String, context: AnyObject? = nil, unmatchHandler: RouteUnmatchHandlerType? = nil) -> Bool {
        guard let url = NSURL(string: urlPath) else {
            return false
        }

        return matchURLAndDoHandler(url, context: context, unmatchHandler: unmatchHandler)
    }
}
