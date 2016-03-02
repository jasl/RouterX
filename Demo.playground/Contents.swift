//: Playground - noun: a place where people can play

import Foundation
import RouterX

let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let pattern2 = "/articles/new"
let pattern3 = "/articles/:id"
let pattern4 = "/:article_id"

let defaultUnmatchHandler = { (uriPath: String) in
  print("\(uriPath) is unmatched.")
}

let router = Router(defaultUnmatchHandler: defaultUnmatchHandler)

try! router.registerRoutingPattern(pattern1) { parameters in
    print("articles pattern handler, parameter is \(parameters).")
}

try! router.registerRoutingPattern(pattern2) { _ in
    print("call new article")
}

let path1 = "/articles/page/2/sort/recent.json"

router.matchAndDoHandler(path1)

let path2 = "/articles/2/edit"

let customUnmatchHandler = { (uriPath: String) in
    print("no match...")
}
router.matchAndDoHandler(path2, unmatchHandler: customUnmatchHandler)
router.matchAndDoHandler(path2)
