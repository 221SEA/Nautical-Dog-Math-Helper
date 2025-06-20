import Foundation
import SwiftUI

enum MoreDestination: Hashable {
    case std
    case anchor
    case hawk
    case convert
    case sweptPath  // New case added for Swept Path Calculator
}

class MoreRouter: ObservableObject {
    @Published var path: [MoreDestination] = []
    
    func navigate(to destination: MoreDestination) {
        path = [destination]  // Push the destination
    }
    
    func reset() {
        path = []
    }
}
