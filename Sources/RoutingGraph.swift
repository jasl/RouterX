import Foundation

public enum RouteEdge {
    case Dot
    case Slash

    case Literal(String)
    case Any
}

extension RouteEdge: Equatable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
    public var hashValue: Int {
        return self.description.hashValue
    }

    public var description: String {
        switch self {
        case .Literal(let value):
            return value
        case .Dot:
            return "."
        case .Slash:
            return "/"
        case .Any:
            return "*"
        }
    }

    public var debugDescription: String {
        return self.description
    }
}

public func == (lhs: RouteEdge, rhs: RouteEdge) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class RouteVertex {
    private static let stopWordsSet: Set<Character> = [".", "/"]
    private static let placeholderPrefixsSet: Set<Character> = [":", "*"]

    public typealias HandlerType = ([String:String] -> Void)

    public private(set) var pattern: String
    public private(set) lazy var placeholderMappings: [String: Int] = {
        var placeholderMappings: [String: Int] = [:]

        let splitedPattern = self.pattern.characters.split(allowEmptySlices: true) { RouteVertex.stopWordsSet.contains($0) }.map(String.init)
        for (index, element) in splitedPattern.enumerate() {
            if let prefix = element.characters.first where RouteVertex.placeholderPrefixsSet.contains(prefix) {
                let placeholder = element.substringFromIndex(element.startIndex.successor())
                let i = index * 2 - 1
                placeholderMappings[placeholder] = i > 0 ? i : 0
            }
        }

        return placeholderMappings
    }()

    public var nextRoutes: [RouteEdge: RouteVertex] = [:]
    public var handler: HandlerType?

    public init(pattern: String, handler: HandlerType? = nil) {
        self.pattern = pattern
        self.handler = handler
    }

    public var isTerminal: Bool {
        return self.handler != nil
    }

    public var isFinish: Bool {
        return self.nextRoutes.isEmpty
    }

    public func toNextVertex(token: RouteEdge) -> RouteVertex? {
        switch token {
        case .Slash:
            return self.nextRoutes[.Slash]
        case .Dot:
            return self.nextRoutes[.Dot]
        case .Literal(let value):
            return self.nextRoutes[.Literal(value)] ?? self.nextRoutes[.Any]
        default:
            return nil
        }
    }
}

extension RouteVertex: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        var string = "<RouteVertex"
//
//        if isTerminal {
//            string += ":T"
//        }
//        if isFinish {
//            string += ":F"
//        }
//
//        string += ":\(self.pattern)"
//
//        string += " {"
//
//        for (k, v) in nextRoutes {
//            string += "\"\(k)\": \(v.debugDescription), "
//        }
//        if !nextRoutes.isEmpty {
//            string.removeRange(Range(start: string.endIndex.advancedBy(-2), end: string.endIndex))
//        }
//        string += "}>"
//
//        return string
//    }

    public var debugDescription: String {
        var string = ""

        if self.isTerminal {
            string += "<RouteVertex"

            if isTerminal {
                string += ":T"
            }
            if isFinish {
                string += ":F"
            }

            string += ":\(self.pattern) \(self.placeholderMappings.map { (k,v) in "\(k): \(v)" })"

            string += ">\n"
        }

        for v in nextRoutes.values {
            string += v.debugDescription
        }

        return string
    }
}
