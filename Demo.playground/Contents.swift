//: Playground - noun: a place where people can play

import Foundation
import RouterX

let handler: RouteVertex.HandlerType = { _ in
    print("terminal")
}

let expr1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let tokens1 = RoutingPatternScanner.tokenize(expr1)
print(tokens1)

let expr2 = "/articles/new"
let tokens2 = RoutingPatternScanner.tokenize(expr2)
print(tokens2)

let expr3 = "/articles/:id"
let tokens3 = RoutingPatternScanner.tokenize(expr3)
print(tokens3)

let expr4 = "/:article_id"
let tokens4 = RoutingPatternScanner.tokenize(expr4)
print(tokens4)

let rootRoute = RouteVertex(pattern: "")

try! RoutingPatternParser.parseAndAppendTo(rootRoute, routingPatternTokens: tokens1, terminalHandler: handler)
try! RoutingPatternParser.parseAndAppendTo(rootRoute, routingPatternTokens: tokens2, terminalHandler: handler)
try! RoutingPatternParser.parseAndAppendTo(rootRoute, routingPatternTokens: tokens3, terminalHandler: handler)
try! RoutingPatternParser.parseAndAppendTo(rootRoute, routingPatternTokens: tokens4, terminalHandler: handler)

print(rootRoute)

let uri = "/articles/page/2/sort/recent.json"

let matchedRoute = match(uri, route: rootRoute)

print(matchedRoute)
