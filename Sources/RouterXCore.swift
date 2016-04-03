import Foundation

public struct MatchedRoute {
    public let url: NSURL
    public let parametars: [String: String]
    public let patternIdentifier: PatternIdentifier

    public init(url: NSURL, parameters: [String: String], patternIdentifier: PatternIdentifier) {
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

    public func registerRoutingPattern(pattern: String, patternIdentifier: PatternIdentifier) -> Bool {
        let tokens = RoutingPatternScanner.tokenize(pattern)

        do {
            try RoutingPatternParser.parseAndAppendTo(self.rootRoute, routingPatternTokens: tokens, patternIdentifier: patternIdentifier)

            return true
        } catch {
            return false
        }
    }

    public func matchURL(url: NSURL) -> MatchedRoute? {
        guard let path = url.path else {
            return nil
        }

        let tokens = URLPathScanner.tokenize(path)
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

        return MatchedRoute(url: url, parameters: parameters, patternIdentifier: targetRoute.patternIdentifier!)
    }

    public func matchURLPath(urlPath: String) -> MatchedRoute? {
        guard let url = NSURL(string: urlPath) else {
            return nil
        }

        return matchURL(url)
    }
}
