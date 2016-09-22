import Foundation

public typealias MatchRouteHandler = ((URL, _ parameters: [String:String], _ context: AnyObject?) -> Void)
public typealias UnmatchRouteHandler = ((URL, _ context: AnyObject?) -> Void)

open class Router {
    fileprivate let core: RouterXCore = RouterXCore()
    fileprivate let defaultUnmatchHandler: UnmatchRouteHandler

    fileprivate var handlerMappings: [PatternIdentifier: MatchRouteHandler] = [:]

    public init(defaultUnmatchHandler: UnmatchRouteHandler? = nil) {
        if let unmatchHandler = defaultUnmatchHandler {
            self.defaultUnmatchHandler = unmatchHandler
        } else {
            self.defaultUnmatchHandler = { (_, _) in }
        }
    }

    open func registerRoutingPattern(_ pattern: String, handler: @escaping MatchRouteHandler) -> Bool {
        let patternIdentifier = pattern.hashValue
        if self.core.registerRoutingPattern(pattern, patternIdentifier: patternIdentifier) {
            self.handlerMappings[patternIdentifier] = handler

            return true
        } else {
            return false
        }
    }

    open func matchURLAndDoHandler(_ url: URL, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let matchedRoute = self.core.matchURL(url) else {
            if let handler = unmatchHandler {
                handler(url, context)
            } else {
                self.defaultUnmatchHandler(url, context)
            }

            return false
        }

        self.handlerMappings[matchedRoute.patternIdentifier]!(url, matchedRoute.parametars, context)

        return true
    }

    open func matchURLPathAndDoHandler(_ urlPath: String, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let url = URL(string: urlPath) else {
            return false
        }

        return matchURLAndDoHandler(url, context: context, unmatchHandler: unmatchHandler)
    }
}
