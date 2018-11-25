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
let defaultUnmatchHandler: Router<Any>.UnmatchHandler = { url, context in
    // Do something here, e.g: give some tips or show a default UI
    print("Default unmatch handler")
    print("\(url) is unmatched")

    // context can be provided on matching patterns
    if let context = context as? String {
        print("Context is \"\(context)\"")
    }
    print("\n")
}

// Initialize a router instance, consider it's global and singleton
// Router.T is used for specifying context type
let router = Router<Any>(defaultUnmatchHandler: defaultUnmatchHandler)

//: Register patterns, the closure is the handle when matched the pattern.

// Set a route pattern, the closure is a handler that would be performed after match the pattern
do {
    try router.register(pattern: pattern1) { result in
        // Now, registered pattern has been matched
        // Do anything you want, e.g: show a UI
        print(result)
        print("\n")
    }
} catch let error {
    print("register failed, reason:\n\(error.localizedDescription)\n")
}

do {
    try router.register(pattern: pattern2) { _ in
    // Now, registered pattern has been matched
    // Do anything you want, e.g: show a UI
    print("call new article")
}
} catch let error {
    print("register failed, reason:\n\(error.localizedDescription)\n")
}
//: Let match some URI Path.

// A case that should be matched
let path1 = "/articles/page/2/sort/recent.json?foo=bar&baz"

// It's will be matched, and perform the handler that we have set up.
router.match(path1)
// It can pass the context for handler
router.match(path1, context: "fooo")

// A case that shouldn't be matched
let path2 = "/articles/2/edit"

let customUnmatchHandler: Router<Any>.UnmatchHandler = { (url, context) in
    print("This is custom unmatch handler")
    var string = "\(url) is no match..."
    // context can be provided on matching patterns
    if let context = context as? String {
        string += "\nContext is \"\(context)\""
    }

    print(string)
}
// It's will not be matched, and perform the default unmatch handler that we have set up
router.match(path2)

// It can provide a custome unmatch handler to override the default, also can pass the context
router.match(path2, context: "bar", unmatchHandler: customUnmatchHandler)
