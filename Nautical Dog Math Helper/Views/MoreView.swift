import SwiftUI

struct MoreView: View {
    @EnvironmentObject var nightMode: NightMode
    @EnvironmentObject var router: MoreRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            List {
                Section(header: Text("More Tools")
                    .foregroundColor(nightMode.isEnabled ? .green : .gray)
                ) {
                    NavigationLink("Speed, Time, Distance", value: MoreDestination.std)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    NavigationLink("Anchor Swing", value: MoreDestination.anchor)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    NavigationLink("Hawk Inlet", value: MoreDestination.hawk)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    NavigationLink("Convert Units", value: MoreDestination.convert)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    NavigationLink("Swept Path", value: MoreDestination.sweptPath)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                }
                .listRowBackground(nightMode.isEnabled ? Color.black : Color("TileBackground"))
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(nightMode.isEnabled ? Color.black : Color("TileBackground"))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(nightMode.isEnabled ? .black : Color("TileBackground"), for: .navigationBar)
            .toolbarColorScheme(nightMode.isEnabled ? .dark : .light, for: .navigationBar)
            .navigationDestination(for: MoreDestination.self) { destination in
                switch destination {
                case .std:
                    STDView().environmentObject(nightMode)
                case .anchor:
                    AnchorView().environmentObject(nightMode)
                case .hawk:
                    HawkView().environmentObject(nightMode)
                case .convert:
                    ConvertView().environmentObject(nightMode)
                case .sweptPath:
                    SweptPathView().environmentObject(nightMode)
                }
            }
        }
        .tint(nightMode.isEnabled ? .green : .accentColor)
        .background(nightMode.isEnabled ? Color.black : Color("TileBackground"))
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(NightMode())
            .environmentObject(MoreRouter())
    }
}
