//: Playground - noun: a place where people can play

import Foundation
import RouterX

let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let pattern2 = "/articles/new"
let pattern3 = "/articles/:id"
let pattern4 = "/:article_id"

let router = Router()

try! router.registerRoutingPattern(pattern1) { parameters in
    print("call articles")
    print(parameters)
}

try! router.registerRoutingPattern(pattern2) { _ in
    print("call new article")
}

let path1 = "/articles/page/2/sort/recent.json"

switch router.matchRoute(path1) {
case let .Matched(parameters, handler, pattern):
    print("Matched pattern \(pattern)")
    handler(parameters)
case .UnMatched:
    print("Unmatched")
}

let path2 = "/articles/2/edit"

switch router.matchRoute(path2) {
case let .Matched(parameters, handler, pattern):
    print("Matched pattern \(pattern)")
    handler(parameters)
case .UnMatched:
    print("Unmatched")
}
