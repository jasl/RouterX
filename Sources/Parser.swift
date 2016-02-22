import Foundation

public func parse(tokens: [RoutingPatternToken], context: RouteVertex = RouteVertex(pattern: ""), terminalHandler: RouteVertex.HandlerType) -> RouteVertex {
    let root = context

    var sequence = tokens.generate()
    if let token = sequence.next() {
        switch token {
        case .Slash:
            parseSlash(root, sequence: sequence, terminalHandler: terminalHandler)
        case .Dot:
            parseDot(root, sequence: sequence, terminalHandler: terminalHandler)
        case .LParen:
            parseLParen(root, sequence: sequence, terminalHandler: terminalHandler)
        default:
            fatalError("Unexpect \(token)")
        }
    } else {
        root.handler = terminalHandler
    }

    return root
}

func contextTerminals(context: RouteVertex) -> [RouteVertex] {
    var contexts: [RouteVertex] = []

    if context.isTerminal {
        contexts.append(context)
    }

    for ctx in context.nextRoutes.values {
        contexts.appendContentsOf(contextTerminals(ctx))
    }

    return contexts
}

func parseLParen(context: RouteVertex, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    context.handler = terminalHandler

    var subTokens: [RoutingPatternToken] = []
    var parenPairingCount = 0
    while let token = sequence.next() {
        if token == .LParen {
            parenPairingCount += 1
        } else if token == .RParen {
            if parenPairingCount == 0 {
                break
            } else if parenPairingCount > 0 {
                parenPairingCount -= 1
            } else {
                fatalError("Unexpect \(token)")
            }
        }

        subTokens.append(token)
    }

    var subSequence = subTokens.generate()
    if let token = subSequence.next() {
        for ctx in contextTerminals(context) {
            switch token {
            case .Slash:
                parseSlash(ctx, sequence: subSequence, terminalHandler: terminalHandler)
            case .Dot:
                parseDot(ctx, sequence: subSequence, terminalHandler: terminalHandler)
            case .LParen:
                parseLParen(ctx, sequence: subSequence, terminalHandler: terminalHandler)
            default:
                fatalError("Unexpect \(token)")
            }
        }
    }

    if let token = sequence.next() {
        if token == .LParen {
            parseLParen(context, sequence: sequence, terminalHandler: terminalHandler)
        } else {
            fatalError("Unexpect \(token)")
        }
    }
}

func parseSlash(context: RouteVertex, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    let pattern = context.pattern + "/"

    guard let nextToken = sequence.next() else {
        if let terminalRoute = context.nextRoutes[.Slash] {
            terminalRoute.handler = terminalHandler
        } else {
            context.nextRoutes[.Slash] = RouteVertex(pattern: pattern, handler: terminalHandler)
        }

        return
    }

    var nextRoute: RouteVertex!
    if let route = context.nextRoutes[.Slash] {
        nextRoute = route
    } else {
        nextRoute = RouteVertex(pattern: pattern)
        context.nextRoutes[.Slash] = nextRoute
    }

    switch nextToken {
    case let .Literal(value):
        parseLiteral(nextRoute, value: value, sequence: sequence, terminalHandler: terminalHandler)
    case let .Symbol(value):
        parseSymbol(nextRoute, value: value, sequence: sequence, terminalHandler: terminalHandler)
    case let .Star(value):
        parseStar(nextRoute, value: value, sequence: sequence, terminalHandler: terminalHandler)
    case .LParen:
        parseLParen(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    default:
        fatalError("Unexpect \(nextToken)")
    }
}

func parseDot(context: RouteVertex, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    let pattern = context.pattern + "."

    guard let nextToken = sequence.next() else {
        fatalError("Expect a token after \"(.)\"")
    }

    var nextRoute: RouteVertex!
    if let route = context.nextRoutes[.Dot] {
        nextRoute = route
    } else {
        nextRoute = RouteVertex(pattern: pattern)
        context.nextRoutes[.Dot] = nextRoute
    }

    switch nextToken {
    case let .Literal(value):
        parseLiteral(nextRoute, value: value, sequence: sequence, terminalHandler: terminalHandler)
    case let .Symbol(value):
        parseSymbol(nextRoute, value: value, sequence: sequence, terminalHandler: terminalHandler)
    default:
        fatalError("Unexpect \(nextToken)")
    }
}

func parseLiteral(context: RouteVertex, value: String, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    let pattern = context.pattern + value

    guard let nextToken = sequence.next() else {
        if let terminalRoute = context.nextRoutes[.Literal(value)] {
            terminalRoute.handler = terminalHandler
        } else {
            context.nextRoutes[.Literal(value)] = RouteVertex(pattern: pattern, handler: terminalHandler)
        }

        return
    }

    var nextRoute: RouteVertex!
    if let route = context.nextRoutes[.Literal(value)] {
        nextRoute = route
    } else {
        nextRoute = RouteVertex(pattern: pattern)
        context.nextRoutes[.Literal(value)] = nextRoute
    }

    switch nextToken {
    case .Slash:
        parseSlash(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    case .Dot:
        parseDot(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    case .LParen:
        parseLParen(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    default:
        fatalError("Unexpect \(nextToken)")
    }
}

func parseSymbol(context: RouteVertex, value: String, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    let pattern = context.pattern + ":\(value)"

    guard let nextToken = sequence.next() else {
        if let terminalRoute = context.nextRoutes[.Any] {
            terminalRoute.handler = terminalHandler
        } else {
            context.nextRoutes[.Any] = RouteVertex(pattern: pattern, handler: terminalHandler)
        }

        return
    }

    var nextRoute: RouteVertex!
    if let route = context.nextRoutes[.Any] {
        nextRoute = route
    } else {
        nextRoute = RouteVertex(pattern: pattern)
        context.nextRoutes[.Any] = nextRoute
    }

    switch nextToken {
    case .Slash:
        parseSlash(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    case .Dot:
        parseDot(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    case .LParen:
        parseLParen(nextRoute, sequence: sequence, terminalHandler: terminalHandler)
    default:
        fatalError("Unexpect \(nextToken)")
    }
}

func parseStar(context: RouteVertex, value: String, var sequence: IndexingGenerator<Array<RoutingPatternToken>>, terminalHandler: RouteVertex.HandlerType) {
    let pattern = context.pattern + "*\(value)"

    if let nextToken = sequence.next() where nextToken != .RParen {
        fatalError("Unexpect \(nextToken)")
    }

    if let terminalRoute = context.nextRoutes[.Any] {
        terminalRoute.handler = terminalHandler
    } else {
        context.nextRoutes[.Any] = RouteVertex(pattern: pattern, handler: terminalHandler)
    }
}
