import Foundation

open class Router<Context> {
    public typealias MatchedHandler = (MatchResult<Context>) -> Void
    public typealias UnmatchHandler = ((URL, _ context: Context?) -> Void)

    private let core: RouterXCore = RouterXCore()
    private let defaultUnmatchHandler: UnmatchHandler?

    private var handlerMappings: [PatternIdentifier: MatchedHandler] = [:]

    public init(defaultUnmatchHandler: UnmatchHandler? = nil) {
        self.defaultUnmatchHandler = defaultUnmatchHandler
    }

    open func register(pattern: String, handler: @escaping MatchedHandler) throws {
        try core.register(pattern: pattern)
        handlerMappings[pattern] = handler
    }

    @discardableResult
    open func match(_ url: URL, context: Context? = nil, unmatchHandler: UnmatchHandler? = nil) -> Bool {
        guard let matchedRoute = core.match(url),
            let matchHandler = handlerMappings[matchedRoute.patternIdentifier] else {
                let expectUnmatchHandler = unmatchHandler ?? defaultUnmatchHandler
                expectUnmatchHandler?(url, context)
                return false
        }

        let result = MatchResult<Context>(url: url, parameters: matchedRoute.parametars, context: context)
        matchHandler(result)
        return true
    }

    @discardableResult
    open func match(_ path: String, context: Context? = nil, unmatchHandler: UnmatchHandler? = nil) -> Bool {
        guard let url = URL(string: path) else { return false }

        return match(url, context: context, unmatchHandler: unmatchHandler)
    }
}

extension Router: CustomDebugStringConvertible, CustomStringConvertible {
    open var description: String {
        return self.core.description
    }

    open var debugDescription: String {
        return self.description
    }
}
