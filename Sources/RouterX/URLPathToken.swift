import Foundation

public enum URLPathToken {
    case slash
    case dot
    case literal(String)

    var routeEdge: RouteEdge {
        switch self {
        case .slash:
            return .slash
        case .dot:
            return .dot
        case let .literal(value):
            return .literal(value)
        }
    }
}

extension URLPathToken: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .slash:
            return "/"
        case .dot:
            return "."
        case .literal(let value):
            return value
        }
    }

    public var debugDescription: String {
        switch self {
        case .slash:
            return "[Slash]"
        case .dot:
            return "[Dot]"
        case .literal(let value):
            return "[Literal \"\(value)\"]"
        }
    }
}

extension URLPathToken: Equatable { }

public func == (lhs: URLPathToken, rhs: URLPathToken) -> Bool {
    switch (lhs, rhs) {
    case (.slash, .slash):
        return true
    case (.dot, .dot):
        return true
    case (let .literal(lval), let .literal(rval)):
        return lval == rval
    default:
        return false
    }
}
