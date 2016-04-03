import Foundation

public enum RoutingPatternParserError: ErrorType {
    case UnexpectToken(got: RoutingPatternToken?, message: String)
    case AmbiguousOptionalPattern
}

public class RoutingPatternParser {
    private typealias RoutingPatternTokenGenerator = IndexingGenerator<Array<RoutingPatternToken>>

    private let routingPatternTokens: [RoutingPatternToken]
    private let patternIdentifier: PatternIdentifier

    public init(routingPatternTokens: [RoutingPatternToken], patternIdentifier: PatternIdentifier) {
        self.routingPatternTokens = routingPatternTokens
        self.patternIdentifier = patternIdentifier
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
            rootRoute.patternIdentifier = self.patternIdentifier
        }
    }

    public class func parseAndAppendTo(rootRoute: RouteVertex, routingPatternTokens: [RoutingPatternToken], patternIdentifier: PatternIdentifier) throws {
        let parser = RoutingPatternParser(routingPatternTokens: routingPatternTokens, patternIdentifier: patternIdentifier)
        try parser.parseAndAppendTo(rootRoute)
    }

    private func parseLParen(context: RouteVertex, isFirstEnter: Bool = true, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        if isFirstEnter && !context.isFinale {
            throw RoutingPatternParserError.AmbiguousOptionalPattern
        }

        assignPatternIdentifierIfNil(context)

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

    private func parseSlash(context: RouteVertex, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.Slash] {
                assignPatternIdentifierIfNil(terminalRoute)
            } else {
                context.nextRoutes[.Slash] = RouteVertex(patternIdentifier: self.patternIdentifier)
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

    private func parseDot(context: RouteVertex, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

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

    private func parseLiteral(context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.Literal(value)] {
                assignPatternIdentifierIfNil(terminalRoute)
            } else {
                context.nextRoutes[.Literal(value)] = RouteVertex(patternIdentifier: self.patternIdentifier)
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

    private func parseSymbol(context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            if let terminalRoute = context.epsilonRoute?.1 {
                assignPatternIdentifierIfNil(terminalRoute)
            } else {
                context.epsilonRoute = (value, RouteVertex(patternIdentifier: self.patternIdentifier))
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

    private func parseStar(context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        if let nextToken = generator.next() {
            throw RoutingPatternParserError.UnexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }

        if let terminalRoute = context.epsilonRoute?.1 {
            assignPatternIdentifierIfNil(terminalRoute)
        } else {
            context.epsilonRoute = (value, RouteVertex(patternIdentifier: self.patternIdentifier))
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

    private func assignPatternIdentifierIfNil(context: RouteVertex) {
        if context.patternIdentifier == nil {
            context.patternIdentifier = self.patternIdentifier
        }
    }
}
