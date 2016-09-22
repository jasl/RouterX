import Foundation

public typealias PatternIdentifier = Int

public enum RouteEdge {
    case dot
    case slash
    case literal(String)
}

extension RouteEdge: Equatable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case .literal(let value):
            return value
        case .dot:
            return "."
        case .slash:
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

open class RouteVertex {
    open var nextRoutes: [RouteEdge: RouteVertex] = [:]
    open var epsilonRoute: (String, RouteVertex)?
    open var patternIdentifier: PatternIdentifier?

    public init(patternIdentifier: PatternIdentifier? = nil) {
        self.patternIdentifier = patternIdentifier
    }

    open var isTerminal: Bool {
        return self.patternIdentifier != nil
    }

    open var isFinale: Bool {
        return self.nextRoutes.isEmpty && self.epsilonRoute == nil
    }
}
