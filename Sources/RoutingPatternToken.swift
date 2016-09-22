import Foundation

public enum RoutingPatternToken {
    case slash
    case dot

    case literal(String)
    case symbol(String)
    case star(String)

    case lParen
    case rParen
}

extension RoutingPatternToken: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .slash:
            return "/"
        case .dot:
            return "."
        case .lParen:
            return "("
        case .rParen:
            return ")"
        case .literal(let value):
            return value
        case .symbol(let value):
            return ":\(value)"
        case .star(let value):
            return "*\(value)"
        }
    }

    public var debugDescription: String {
        switch self {
        case .slash:
            return "[Slash]"
        case .dot:
            return "[Dot]"
        case .lParen:
            return "[LParen]"
        case .rParen:
            return "[RParen]"
        case .literal(let value):
            return "[Literal \"\(value)\"]"
        case .symbol(let value):
            return "[Symbol \"\(value)\"]"
        case .star(let value):
            return "[Star \"\(value)\"]"
        }
    }
}

extension RoutingPatternToken: Equatable { }

public func == (lhs: RoutingPatternToken, rhs: RoutingPatternToken) -> Bool {
    switch (lhs, rhs) {
    case (.slash, .slash):
        return true
    case (.dot, .dot):
        return true
    case (let .literal(lval), let .literal(rval)):
        return lval == rval
    case (let .symbol(lval), let .symbol(rval)):
        return lval == rval
    case (let .star(lval), let .star(rval)):
        return lval == rval
    case (.lParen, .lParen):
        return true
    case (.rParen, .rParen):
        return true
    default:
        return false
    }
}
