import Foundation

public enum RoutingPatternToken {
    case Slash
    case Dot

    case Literal(String)
    case Symbol(String)
    case Star(String)

    case LParen
    case RParen
}

extension RoutingPatternToken: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .Slash:
            return "/"
        case .Dot:
            return "."
        case .LParen:
            return "("
        case .RParen:
            return ")"
        case .Literal(let value):
            return value
        case .Symbol(let value):
            return ":\(value)"
        case .Star(let value):
            return "*\(value)"
        }
    }

    public var debugDescription: String {
        switch self {
        case .Slash:
            return "[Slash]"
        case .Dot:
            return "[Dot]"
        case .LParen:
            return "[LParen]"
        case .RParen:
            return "[RParen]"
        case .Literal(let value):
            return "[Literal \"\(value)\"]"
        case .Symbol(let value):
            return "[Symbol \"\(value)\"]"
        case .Star(let value):
            return "[Star \"\(value)\"]"
        }
    }
}

extension RoutingPatternToken: Equatable { }

public func == (lhs: RoutingPatternToken, rhs: RoutingPatternToken) -> Bool {
    switch (lhs, rhs) {
    case (.Slash, .Slash):
        return true
    case (.Dot, .Dot):
        return true
    case (let .Literal(lval), let .Literal(rval)):
        return lval == rval
    case (let .Symbol(lval), let .Symbol(rval)):
        return lval == rval
    case (let .Star(lval), let .Star(rval)):
        return lval == rval
    case (.LParen, .LParen):
        return true
    case (.RParen, .RParen):
        return true
    default:
        return false
    }
}
