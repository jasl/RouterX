import Foundation
@testable import RouterX

extension RouteVertex {
    func toNextVertex(_ token: RouteEdge) -> RouteVertex? {
        switch token {
        case .slash:
            return self.nextRoutes[.slash]
        case .dot:
            return self.nextRoutes[.dot]
        default:
            return self.nextRoutes[token] ?? self.epsilonRoute?.1
        }
    }
}
