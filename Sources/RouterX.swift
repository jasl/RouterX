import Foundation

public typealias MatchRouteHandler = ((NSURL, parameters: [String:String], context: AnyObject?) -> Void)
public typealias UnmatchRouteHandler = ((NSURL, context: AnyObject?) -> ())

public class Router {
    private let core: RouterXCore = RouterXCore()
    private let defaultUnmatchHandler: UnmatchRouteHandler

    private var handlerMappings: [PatternIdentifier: MatchRouteHandler] = [:]

    public init(defaultUnmatchHandler: UnmatchRouteHandler? = nil) {
        if let unmatchHandler = defaultUnmatchHandler {
            self.defaultUnmatchHandler = unmatchHandler
        } else {
            self.defaultUnmatchHandler = { (_, _) in }
        }
    }

    public func registerRoutingPattern(pattern: String, handler: MatchRouteHandler) -> Bool {
        let patternIdentifier = pattern.hashValue
        if self.core.registerRoutingPattern(pattern, patternIdentifier: patternIdentifier) {
            self.handlerMappings[patternIdentifier] = handler

            return true
        } else {
            return false
        }
    }

    public func matchURLAndDoHandler(url: NSURL, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let matchedRoute = self.core.matchURL(url) else {
            if let handler = unmatchHandler {
                handler(url, context: context)
            } else {
                self.defaultUnmatchHandler(url, context: context)
            }

            return false
        }

        self.handlerMappings[matchedRoute.patternIdentifier]!(url, parameters: matchedRoute.parametars, context: context)

        return true
    }

    public func matchURLPathAndDoHandler(urlPath: String, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let url = NSURL(string: urlPath) else {
            return false
        }

        return matchURLAndDoHandler(url, context: context, unmatchHandler: unmatchHandler)
    }
}
