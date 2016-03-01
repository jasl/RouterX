//: Playground - noun: a place where people can play

import Foundation
import RouterX

let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let pattern2 = "/articles/new"
let pattern3 = "/articles/:id"
let pattern4 = "/:article_id"

let router = Router()

try! router.registerRoutingPattern(pattern1) { parameters in
    print("articles pattern handler, parameter is \(parameters).")
}

try! router.registerRoutingPattern(pattern2) { _ in
    print("call new article")
}

let path1 = "/articles/page/2/sort/recent.json"

router.matchRouteAndDoHandler(path1)

let path2 = "/articles/2/edit"
let path2UnmatchHandler = { (uriPath: String) in
    print("\(uriPath) is unmatched.")
}

router.matchRouteAndDoHandler(path2, unmatchHandler: path2UnmatchHandler)