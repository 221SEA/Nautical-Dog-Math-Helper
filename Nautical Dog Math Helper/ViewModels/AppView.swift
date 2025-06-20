import SwiftUI

struct AppView: View {
    @StateObject private var nightMode = NightMode()
    
    var body: some View {
        NavigationStack {
            HomeView()
                .environmentObject(nightMode)
        }
        .preferredColorScheme(nightMode.isEnabled ? .dark : .light)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
