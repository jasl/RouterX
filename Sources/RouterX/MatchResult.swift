import Foundation

public struct MatchResult<Context>: CustomDebugStringConvertible, CustomStringConvertible {
    public let url: URL
    public let parameters: [String: String]
    public let context: Context?

    public var description: String {
        return """
        MatchResult<\(Context.self)> {
          url: \(url)
          parameters: \(parameters)
          context: \(String(describing: context))
        }
        """
    }

    public var debugDescription: String {
        return description
    }
}
