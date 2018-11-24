import Foundation
@testable import RouterX

extension RouteVertex {
    func toNextVertex(_ token: RouteEdge) -> RouteVertex? {
        switch token {
        case .slash:
            return self.namedRoutes[.slash]
        case .dot:
            return self.namedRoutes[.dot]
        default:
            return self.namedRoutes[token] ?? self.parameterRoute?.1
        }
    }
}
