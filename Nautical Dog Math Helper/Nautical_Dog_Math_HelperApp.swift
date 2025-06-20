import SwiftUI

@main
struct Nautical_Dog_Math_HelperApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var nightMode = NightMode()

    init() {
        updateAppearance(for: false) // initial light
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .id(nightMode.isEnabled) // 💡 Forces full redraw on toggle
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(nightMode)
                .preferredColorScheme(nightMode.isEnabled ? .dark : .light)
                .onChange(of: nightMode.isEnabled, perform: { newValue in
                    updateAppearance(for: newValue)
                })
        }
    }

    private func updateAppearance(for isNightMode: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = isNightMode ? UIColor.black : UIColor.white
        navBarAppearance.titleTextAttributes = [.foregroundColor: isNightMode ? UIColor.green : UIColor.label]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: isNightMode ? UIColor.green : UIColor.label]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = isNightMode ? .green : .label

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "AccentColor") ?? UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
