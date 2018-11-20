import Foundation

public typealias MatchRouteHandler = ((URL, _ parameters: [String: String], _ context: AnyObject?) -> Void)
public typealias UnmatchRouteHandler = ((URL, _ context: AnyObject?) -> Void)

open class Router {
    private let core: RouterXCore = RouterXCore()
    private let defaultUnmatchHandler: UnmatchRouteHandler?

    private var handlerMappings: [PatternIdentifier: MatchRouteHandler] = [:]

    public init(defaultUnmatchHandler: UnmatchRouteHandler? = nil) {
        self.defaultUnmatchHandler = defaultUnmatchHandler
    }

    open func register(pattern: String, handler: @escaping MatchRouteHandler) -> Bool {
        let patternIdentifier = pattern.hashValue
        if self.core.registerRoutingPattern(pattern, patternIdentifier: patternIdentifier) {
            self.handlerMappings[patternIdentifier] = handler

            return true
        } else {
            return false
        }
    }

    open func match(url: URL, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let matchedRoute = core.matchURL(url),
        let matchHandler = handlerMappings[matchedRoute.patternIdentifier] else {
            let expectUnmatchHandler = unmatchHandler ?? defaultUnmatchHandler
            expectUnmatchHandler?(url, context)
            return false
        }

        matchHandler(url, matchedRoute.parametars, context)
        return true
    }

    open func match(urlPath: String, context: AnyObject? = nil, unmatchHandler: UnmatchRouteHandler? = nil) -> Bool {
        guard let url = URL(string: urlPath) else { return false }

        return match(url: url, context: context, unmatchHandler: unmatchHandler)
    }
}
