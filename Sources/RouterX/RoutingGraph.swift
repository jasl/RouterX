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
    var namedRoutes: [RouteEdge: RouteVertex] = [:]
    var parameterRoute: (String, RouteVertex)?
    var patternIdentifier: PatternIdentifier?

    init(patternIdentifier: PatternIdentifier? = nil) {
        self.patternIdentifier = patternIdentifier
    }

    var isTerminal: Bool {
        return self.patternIdentifier != nil
    }

    var isFinale: Bool {
        return self.namedRoutes.isEmpty && self.parameterRoute == nil
    }
}

extension RouteVertex: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        var str = "RouteVertex {\n"

        str += "  patternIdentifier: \(String(describing: patternIdentifier))\n"

        if namedRoutes.count > 0 {
            str += "  nextRoutes: [\n"
            for (edge, subVertex) in self.namedRoutes {
                str += "    \"\(edge.description)\": {\n"
                str += "      \(subVertex.description.replacingOccurrences(of: "\n", with: "\n      "))\n"
                str += "    },\n"
            }
            str += "  ]\n"
        } else {
           str += "  nextRoutes: []\n"
        }

        if let epsilonRoute = self.parameterRoute {
            str += "  episilonRoute: {\n"
            str += "    \"\(epsilonRoute.0)\": {\n"
            str += "      \(epsilonRoute.1.description.replacingOccurrences(of: "\n", with: "\n      "))\n"
            str += "    }\n"
            str += "  }\n"
        } else {
            str += "  episilonRoute: nil\n"
        }

        str += "}"

        return str
    }

    var debugDescription: String {
        return self.description
    }
}
