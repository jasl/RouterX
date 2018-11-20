import Foundation

public enum RoutingPatternParserError: Error {
    case unexpectToken(got: RoutingPatternToken?, message: String)
    case ambiguousOptionalPattern
}

open class RoutingPatternParser {
    fileprivate typealias RoutingPatternTokenGenerator = IndexingIterator<Array<RoutingPatternToken>>

    fileprivate let routingPatternTokens: [RoutingPatternToken]
    fileprivate let patternIdentifier: PatternIdentifier

    public init(routingPatternTokens: [RoutingPatternToken], patternIdentifier: PatternIdentifier) {
        self.routingPatternTokens = routingPatternTokens
        self.patternIdentifier = patternIdentifier
    }

    open func parseAndAppendTo(_ rootRoute: RouteVertex) throws {
        var tokenGenerator = self.routingPatternTokens.makeIterator()
        if let token = tokenGenerator.next() {
            switch token {
            case .slash:
                try parseSlash(rootRoute, generator: tokenGenerator)
            default:
                throw RoutingPatternParserError.unexpectToken(got: token, message: "Pattern must start with slash.")
            }
        } else {
            rootRoute.patternIdentifier = self.patternIdentifier
        }
    }

    open class func parseAndAppendTo(_ rootRoute: RouteVertex, routingPatternTokens: [RoutingPatternToken], patternIdentifier: PatternIdentifier) throws {
        let parser = RoutingPatternParser(routingPatternTokens: routingPatternTokens, patternIdentifier: patternIdentifier)
        try parser.parseAndAppendTo(rootRoute)
    }

    fileprivate func parseLParen(_ context: RouteVertex, isFirstEnter: Bool = true, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        if isFirstEnter && !context.isFinale {
            throw RoutingPatternParserError.ambiguousOptionalPattern
        }

        assignPatternIdentifierIfNil(context)

        var subTokens: [RoutingPatternToken] = []
        var parenPairingCount = 0
        while let token = generator.next() {
            if token == .lParen {
                parenPairingCount += 1
            } else if token == .rParen {
                if parenPairingCount == 0 {
                    break
                } else if parenPairingCount > 0 {
                    parenPairingCount -= 1
                } else {
                    throw RoutingPatternParserError.unexpectToken(got: .rParen, message: "Unexpect \(token)")
                }
            }

            subTokens.append(token)
        }

        var subGenerator = subTokens.makeIterator()
        if let token = subGenerator.next() {
            for ctx in contextTerminals(context) {
                switch token {
                case .slash:
                    try parseSlash(ctx, generator: subGenerator)
                case .dot:
                    try parseDot(ctx, generator: subGenerator)
                default:
                    throw RoutingPatternParserError.unexpectToken(got: token, message: "Unexpect \(token)")
                }
            }
        }

        if let nextToken = generator.next() {
            if nextToken == .lParen {
                try parseLParen(context, isFirstEnter: false, generator: generator)
            } else {
                throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
            }
        }
    }

    fileprivate func parseSlash(_ context: RouteVertex, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.slash] {
                assignPatternIdentifierIfNil(terminalRoute)
            } else {
                context.nextRoutes[.slash] = RouteVertex(patternIdentifier: self.patternIdentifier)
            }

            return
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.slash] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.slash] = nextRoute
        }

        switch nextToken {
        case let .literal(value):
            try parseLiteral(nextRoute, value: value, generator: generator)
        case let .symbol(value):
            try parseSymbol(nextRoute, value: value, generator: generator)
        case let .star(value):
            try parseStar(nextRoute, value: value, generator: generator)
        case .lParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    fileprivate func parseDot(_ context: RouteVertex, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            throw RoutingPatternParserError.unexpectToken(got: nil, message: "Expect a token after \".\"")
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.dot] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.dot] = nextRoute
        }

        switch nextToken {
        case let .literal(value):
            try parseLiteral(nextRoute, value: value, generator: generator)
        case let .symbol(value):
            try parseSymbol(nextRoute, value: value, generator: generator)
        default:
            throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    fileprivate func parseLiteral(_ context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        guard let nextToken = generator.next() else {
            if let terminalRoute = context.nextRoutes[.literal(value)] {
                assignPatternIdentifierIfNil(terminalRoute)
            } else {
                context.nextRoutes[.literal(value)] = RouteVertex(patternIdentifier: self.patternIdentifier)
            }

            return
        }

        var nextRoute: RouteVertex!
        if let route = context.nextRoutes[.literal(value)] {
            nextRoute = route
        } else {
            nextRoute = RouteVertex()
            context.nextRoutes[.literal(value)] = nextRoute
        }

        switch nextToken {
        case .slash:
            try parseSlash(nextRoute, generator: generator)
        case .dot:
            try parseDot(nextRoute, generator: generator)
        case .lParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    fileprivate func parseSymbol(_ context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
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
        case .slash:
            try parseSlash(nextRoute, generator: generator)
        case .dot:
            try parseDot(nextRoute, generator: generator)
        case .lParen:
            try parseLParen(nextRoute, generator: generator)
        default:
            throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }
    }

    fileprivate func parseStar(_ context: RouteVertex, value: String, generator: RoutingPatternTokenGenerator) throws {
        var generator = generator

        if let nextToken = generator.next() {
            throw RoutingPatternParserError.unexpectToken(got: nextToken, message: "Unexpect \(nextToken)")
        }

        if let terminalRoute = context.epsilonRoute?.1 {
            assignPatternIdentifierIfNil(terminalRoute)
        } else {
            context.epsilonRoute = (value, RouteVertex(patternIdentifier: self.patternIdentifier))
        }
    }

    fileprivate func contextTerminals(_ context: RouteVertex) -> [RouteVertex] {
        var contexts: [RouteVertex] = []

        if context.isTerminal {
            contexts.append(context)
        }

        for ctx in context.nextRoutes.values {
            contexts.append(contentsOf: contextTerminals(ctx))
        }

        if let ctx = context.epsilonRoute?.1 {
            contexts.append(contentsOf: contextTerminals(ctx))
        }

        return contexts
    }

    fileprivate func assignPatternIdentifierIfNil(_ context: RouteVertex) {
        if context.patternIdentifier == nil {
            context.patternIdentifier = self.patternIdentifier
        }
    }
}
