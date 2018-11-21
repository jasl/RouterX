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

open class RouterXCore {
    private let rootRoute: RouteVertex

    public init() {
        self.rootRoute = RouteVertex()
    }

    open func registerRoutingPattern(_ pattern: String, patternIdentifier: PatternIdentifier) -> Bool {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        do {
            try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, patternIdentifier: patternIdentifier)
            return true
        } catch {
            return false
        }
    }

    open func matchURL(_ url: URL) -> MatchedRoute? {
        let path = url.path

        let tokens = URLPathScanner.tokenize(path)
        if tokens.isEmpty {
            return nil
        }

        var parameters: [String: String] = [:]

        var tokensGenerator = tokens.makeIterator()
        var targetRoute: RouteVertex = rootRoute
        while let token = tokensGenerator.next() {
            if let determinativeRoute = targetRoute.nextRoutes[token.routeEdge] {
                targetRoute = determinativeRoute
            } else if let epsilonRoute = targetRoute.epsilonRoute {
                targetRoute = epsilonRoute.1
                parameters[epsilonRoute.0] = String(describing: token).removingPercentEncoding ?? ""
            } else {
                return nil
            }
        }
        
        guard let pathPatternIdentifier = targetRoute.patternIdentifier else { return nil }

        return MatchedRoute(url: url, parameters: parameters, patternIdentifier: pathPatternIdentifier)
    }

    open func matchURLPath(_ urlPath: String) -> MatchedRoute? {
        guard let url = URL(string: urlPath) else { return nil }
        return matchURL(url)
    }
}
