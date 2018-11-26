import Foundation

public enum PatternRegisterError: LocalizedError {
    case empty
    case missingPrefixSlash
    case invalidGlobbing(globbing: String, after: String)
    case invalidSymbol(symbol: String, after: String)
    case unbalanceParenthesis
    case unexpectToken(after: String)
}
