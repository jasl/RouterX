import Foundation

public enum RouteEdge {
    case Dot
    case Slash
    case Literal(String)
}

extension RouteEdge: Equatable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case .Literal(let value):
            return value
        case .Dot:
            return "."
        case .Slash:
            return "/"
        }
    }

    public var debugDescription: String {
        return self.description
    }

    public var hashValue: Int {
        return self.description.hashValue
    }
}

public func == (lhs: RouteEdge, rhs: RouteEdge) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class RouteVertex {
    public var nextRoutes: [RouteEdge: RouteVertex] = [:]
    public var epsilonRoute: (String, RouteVertex)?
    public var handler: RouteTerminalHandler?

    public init(handler: RouteTerminalHandler? = nil) {
        self.handler = handler
    }

    public var isTerminal: Bool {
        return self.handler != nil
    }

    public var isFinale: Bool {
        return self.nextRoutes.isEmpty && self.epsilonRoute == nil
    }
}
