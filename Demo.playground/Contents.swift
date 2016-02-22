//: Playground - noun: a place where people can play

import Foundation
import RouterX

let expr1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let tokens1 = RoutingPatternScanner.tokenize(expr1)
print(tokens1)

let expr2 = "/articles/new"
let tokens2 = RoutingPatternScanner.tokenize(expr2)
print(tokens2)

let expr3 = "/articles/:id"
let tokens3 = RoutingPatternScanner.tokenize(expr3)
print(tokens3)

let handler: RouteVertex.HandlerType = { _ in
    print("terminal")
}

var route = parse(tokens1, terminalHandler: handler)
route = parse(tokens2, context: route, terminalHandler: handler)
route = parse(tokens3, context: route, terminalHandler: handler)

print(route.debugDescription)

let uri = "/articles/page/2/sort/recent.json"

let matchedRoute = match(uri, route: route)

print(matchedRoute)
