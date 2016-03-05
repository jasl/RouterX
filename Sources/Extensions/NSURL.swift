import Foundation

extension NSURL {
    var queryDictionary: [String: String] {
        guard let query = self.query else {
            return [:]
        }

        var dict = [String:String]()
        for parameter in query.componentsSeparatedByString("&") {
            let components = parameter.componentsSeparatedByString("=")

            guard let key = components[0].stringByRemovingPercentEncoding else {
                continue
            }

            if components.count > 1 {
                dict[key] = components[1].stringByRemovingPercentEncoding ?? ""
            } else {
                dict[key] = ""
            }
        }
        return dict
    }
}
