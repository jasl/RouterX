import Foundation

public enum RoutingPatternParserError: ErrorType {
    case UnexpectToken(got: RoutingPatternToken?, message: String)
    case AmbiguousOptionalPattern
}

public class RoutingPatternParser {
    private typealias RoutingPatternTokenGenerator = IndexingGenerator<Array<RoutingPatternToken>>

    private let routingPatternTokens: [RoutingPatternToken]
    private let terminalHandler: RouteTerminalHandler

    public init(routingPatternTokens: [RoutingPatternToken], terminalHandler: RouteTerminalHandler) {
        self.routingPatternTokens = routingPatternTokens
        self.terminalHandler = terminalHandler
    }

    public func parseAndAppendTo(rootRoute: RouteVertex) throws {
        var tokenGenerator = self.routingPatternTokens.generate()
        if let token = tokenGenerator.next() {
            switch token {
            case .Slash:
                try parseSlash(rootRoute, generator: tokenGenerator)
            default:
                throw RoutingPatternParserError.UnexpectToken(got: token, message: "Pattern must start with slash.")
            }
        } else {
            rootRoute.handler = self.terminalHandler
        }
    }

    public class func parseAndAppendTo(rootRoute: RouteVertex, routingPatternTokens: [RoutingPatternToken], terminalHandler: RouteTerminalHandler) throws {
        let parser = RoutingPatternParser(routingPatternTokens: routingPatternTokens, terminalHandler: terminalHandler)
        try parser.parseAndAppendTo(rootRoute)
    }

    private func parseLParen(context: RouteVertex, isFirstEnter: Bool = true, var generator: RoutingPatternTokenGenerator) throws {
        if isFirstEnter && !context.isFinale {
            throw RoutingPatternParserError.AmbiguousOptionalPattern
        }

        assignTerminalHandlerIfNil(context)

        var subTokens: [RoutingPatternToken] = []
        var parenPairingCount = 0
        while let token = generator.next() {
            if token == .LParen {
                parenPairingCount += 1
            } else if token == .RParen {
                if parenPairingCount == 0 {
                    break
                } else if parenPairingCount > 0 {
                    parenPairingCount -= 1
                } else {
                    throw RoutingPatternParserError.UnexpectToken(got: .RParen, message: "Unexpect \(token)")
                }
            }

            subTokens.append(token)
        }

        var subGenerator = subTokens.generate()
        if let token = subGenerator.next() {
            for ctx in contextTerminals(context) {
                switch token {
                case .Slash:
                    try parseSlash(ctx, generator: subGenerator)
                case .Dot:
                    try parseDot(ctx, generator: subGenerator)
                default:
                    throw RoutingPatternParserError.UnexpectToken(got: token, message: "Unexpect \(token)")
                }
            }
        }

        if let nextToken = generator.next() {
            if nextToken == .LParen {
                try parseLParen(context, isFirstEnter: false, generator: generator)
            } else {
                throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
            }
        }
    }

    private func parseSlash(context: RouteVertex, var generator: RoutingPatternTokenGenerator) throws {
        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.Slash] {
                assignTerminalHandlerIfNil(terminalRoute)
            } else {
                context.nextRoutes[.Slash] = RouteVertex(handler: self.terminalHandler)
            }

            return
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.Slash] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.Slash] = nextRoute
        }

        switch nextToken {
        case let .Literal(value):
            try parseLiteral(nextRoute, value: value, generator: generator)
        case let .Symbol(value):
            try parseSymbol(nextRoute, value: value, generator: generator)
        case let .Star(value):
            try parseStar(nextRoute, value: value, generator: generator)
        case .LParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    private func parseDot(context: RouteVertex, var generator: RoutingPatternTokenGenerator) throws {
        guard let nextToken = generator.next() else {
            throw RoutingPatternParserError.UnexpectToken(got: nil, message: "Expect a token after \".\"")
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.Dot] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.Dot] = nextRoute
        }

        switch nextToken {
        case let .Literal(value):
            try parseLiteral(nextRoute, value: value, generator: generator)
        case let .Symbol(value):
            try parseSymbol(nextRoute, value: value, generator: generator)
        default:
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    private func parseLiteral(context: RouteVertex, value: String, var generator: RoutingPatternTokenGenerator) throws {
        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.Literal(value)] {
                assignTerminalHandlerIfNil(terminalRoute)
            } else {
                context.nextRoutes[.Literal(value)] = RouteVertex(handler: self.terminalHandler)
            }

            return
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.Literal(value)] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.Literal(value)] = nextRoute
        }

        switch nextToken {
        case .Slash:
            try parseSlash(nextRoute, generator: generator)
        case .Dot:
            try parseDot(nextRoute, generator: generator)
        case .LParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    private func parseSymbol(context: RouteVertex, value: String, var generator: RoutingPatternTokenGenerator) throws {
        guard let nextToken = generator.next() else {
            if let terminalRoute = context.epsilonRoute?.1 {
                assignTerminalHandlerIfNil(terminalRoute)
            } else {
                context.epsilonRoute = (value, RouteVertex(handler: terminalHandler))
            }

            return
        }

        var nextRoute: RouteVertex!
        if let route = context.epsilonRoute?.1 {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.epsilonRoute = (value, nextRoute)
        }

        switch nextToken {
        case .Slash:
            try parseSlash(nextRoute, generator: generator)
        case .Dot:
            try parseDot(nextRoute, generator: generator)
        case .LParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    private func parseStar(context: RouteVertex, value: String, var generator: RoutingPatternTokenGenerator) throws {
        if let nextToken = generator.next() {
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }

        if let terminalRoute = context.epsilonRoute?.1 {
            assignTerminalHandlerIfNil(terminalRoute)
        } else {
            context.epsilonRoute = (value, RouteVertex(handler: terminalHandler))
        }
    }

    private func contextTerminals(context: RouteVertex) -> [RouteVertex] {
        var contexts: [RouteVertex] = []

        if context.isTerminal {
            contexts.append(context)
        }

        for ctx in context.nextRoutes.values {
            contexts.appendContentsOf(contextTerminals(ctx))
        }

        if let ctx = context.epsilonRoute?.1 {
            contexts.appendContentsOf(contextTerminals(ctx))
        }

        return contexts
    }

    private func assignTerminalHandlerIfNil(context: RouteVertex) {
        if context.handler == nil {
            context.handler = self.terminalHandler
        }
    }
}
