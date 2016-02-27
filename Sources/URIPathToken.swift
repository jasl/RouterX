import Foundation

public enum URIPathToken {
    case Slash
    case Dot
    case Literal(String)

    var routeEdge: RouteEdge {
        switch self {
        case .Slash:
            return .Slash
        case .Dot:
            return .Dot
        case let .Literal(value):
            return .Literal(value)
        }
    }
}

extension URIPathToken: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .Slash:
            return "/"
        case .Dot:
            return "."
        case .Literal(let value):
            return value
        }
    }

    public var debugDescription: String {
        switch self {
        case .Slash:
            return "[Slash]"
        case .Dot:
            return "[Dot]"
        case .Literal(let value):
            return "[Literal \"\(value)\"]"
        }
    }
}

extension URIPathToken: Equatable { }

public func == (lhs: URIPathToken, rhs: URIPathToken) -> Bool {
    switch (lhs, rhs) {
    case (.Slash, .Slash):
        return true
    case (.Dot, .Dot):
        return true
    case (let .Literal(lval), let .Literal(rval)):
        return lval == rval
    default:
        return false
    }
}
