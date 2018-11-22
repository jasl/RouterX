import Foundation

public typealias PatternIdentifier = String

internal enum RouteEdge {
    case dot
    case slash
    case literal(String)
}

extension RouteEdge: Hashable, CustomDebugStringConvertible, CustomStringConvertible {
    var description: String {
        switch self {
        case .literal(let value):
            return value
        case .dot:
            return "."
        case .slash:
            return "/"
        }
    }

    var debugDescription: String {
        return self.description
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

internal class RouteVertex {
    var nextRoutes: [RouteEdge: RouteVertex] = [:]
    var epsilonRoute: (String, RouteVertex)?
    var patternIdentifier: PatternIdentifier?

    init(patternIdentifier: PatternIdentifier? = nil) {
        self.patternIdentifier = patternIdentifier
    }

    var isTerminal: Bool {
        return self.patternIdentifier != nil
    }

    var isFinale: Bool {
        return self.nextRoutes.isEmpty && self.epsilonRoute == nil
    }
}
