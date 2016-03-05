import Foundation
@testable import RouterX

extension RouteVertex {
    func toNextVertex(token: RouteEdge) -> RouteVertex? {
        switch token {
        case .Slash:
            return self.nextRoutes[.Slash]
        case .Dot:
            return self.nextRoutes[.Dot]
        default:
            return self.nextRoutes[token] ?? self.epsilonRoute?.1
        }
    }
}
