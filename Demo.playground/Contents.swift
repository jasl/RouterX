//: Playground - noun: a place where people can play

import Foundation
import RouterX

//: Here I define some pattern

let pattern1 = "/articles(/page/:page(/per_page/:per_page))(/sort/:sort)(.:format)"
let pattern2 = "/articles/new"
let pattern3 = "/articles/:id"
let pattern4 = "/:article_id"

//: Initialize the router, I can give a default closure to handle while given a URI path but match no one.

// This is the handler that would be performed after no pattern match
let defaultUnmatchHandler = { (uriPath: String) in
  // Do something here, e.g: give some tips or show a default UI
  print("\(uriPath) is unmatched.")
}

// Initialize a router instance, consider it's global and singleton
let router = Router(defaultUnmatchHandler: defaultUnmatchHandler)

//: Register patterns, the closure is the handle when matched the pattern.

// Set a route pattern, the closure is a handler that would be performed after match the pattern
router.registerRoutingPattern(pattern1) { parameters in
  // Do something here, e.g: show a UI
  print("articles pattern handler, parameter is \(parameters).")
}

router.registerRoutingPattern(pattern2) { _ in
  // Do something here, e.g: show a UI
  print("call new article")
}

//: Let match some URI Path.

// A case that should be matched
let path1 = "/articles/page/2/sort/recent.json"

// It's will be matched, and perform the handler that we have set up.
router.matchAndDoHandler(path1)

// A case that shouldn't be matched
let path2 = "/articles/2/edit"

let customUnmatchHandler = { (uriPath: String) in
  print("no match...")
}
// It's will not be matched, and perform the default unmatch handler that we have set up
router.matchAndDoHandler(path2)

// It can provide a custome unmatch handler to override the default
router.matchAndDoHandler(path2, unmatchHandler: customUnmatchHandler)
