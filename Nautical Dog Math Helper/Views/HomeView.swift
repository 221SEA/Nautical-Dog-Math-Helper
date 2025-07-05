import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nightMode: NightMode
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            // Background color
            (nightMode.isEnabled ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Watermark logo - using overlay instead
                    Color.clear
                        .overlay(
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 800, height: 800)
                                .opacity(nightMode.isEnabled ? 0.03 : 0.05)
                                .foregroundColor(nightMode.isEnabled ? .green : Color("AccentColor"))
                                .rotationEffect(.degrees(15))
                        )
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Nautical Dog\nMath's Best Friend")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .padding(.top, 40)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        NavigationLink(destination: ROTView().environmentObject(nightMode)) {
                            HomeIcon(title: "Rate of Turn", iconName: "arrow.triangle.turn.up.right.circle", isSystemSymbol: true)
                        }
                        NavigationLink(destination: TurnView().environmentObject(nightMode)) {
                            HomeIcon(title: "Turn Transfer", iconName: "arrow.clockwise.circle", isSystemSymbol: true)
                        }
                        NavigationLink(destination: RPMView().environmentObject(nightMode)) {
                            HomeIcon(title: "New RPM", iconName: "speedometer", isSystemSymbol: true)
                        }
                        
                        NavigationLink(destination: STDView().environmentObject(nightMode)) {
                            HomeIcon(title: "DST", iconName: "timer", isSystemSymbol: true)
                        }
                        NavigationLink(destination: AnchorView().environmentObject(nightMode)) {
                            HomeIcon(title: "Anchor Swing", iconName: "scope", isSystemSymbol: true)
                        }
                        NavigationLink(destination: HawkView().environmentObject(nightMode)) {
                            HomeIcon(title: "Squat / UKC", iconName: "ferry.fill", isSystemSymbol: true)
                        }
                        
                        NavigationLink(destination: ConvertView().environmentObject(nightMode)) {
                            HomeIcon(title: "Convert", iconName: "arrow.left.arrow.right", isSystemSymbol: true)
                        }
                        NavigationLink(destination: SweptPathView().environmentObject(nightMode)) {
                            HomeIcon(title: "Swept Path", iconName: "ruler", isSystemSymbol: true)
                        }
                        // ← New tile in lower-right
                        NavigationLink(destination: TrueWindView().environmentObject(nightMode)) {
                                                    HomeIcon(title: "True Wind", iconName: "wind", isSystemSymbol: true)
                                                }
                                                
                                                // New Watch Schedule tile
                                                NavigationLink(destination: WatchScheduleView().environmentObject(nightMode)) {
                                                    HomeIcon(title: "Watch Schedule", iconName: "person.badge.clock", isSystemSymbol: true)
                                                }
                                            }
                    .padding(.horizontal)
                    
                    Toggle("Night Mode", isOn: $nightMode.isEnabled)
                        .padding(.horizontal)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                    
                    Button(action: { showPrivacyPolicy.toggle() }) {
                        Text("About")
                            .font(.custom("Avenir", size: 16))
                            .foregroundColor(nightMode.isEnabled ? .green : .black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                    .alert(isPresented: $showPrivacyPolicy) {
                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
                        return Alert(
                            title: Text("Build & Privacy"),
                            message: Text("""
                            Version \(version) Build \(build)

                            Privacy Policy: We do not collect any personal data from users of the Nautical Dog Math Helper app.
                            We do not share any personal data with third parties. For questions, contact captjillr+NDapp@gmail.com.  
                            This application is provided as a supplemental reference tool for maritime professionals. It is not a substitute for official navigation systems, real-time data, or professional judgment. The user assumes full responsibility for verifying the accuracy, completeness, and appropriateness of all calculations and information provided by this app for their specific operations, vessel, and circumstances.

                            By using this app, you acknowledge that you are solely responsible for any decisions, actions, or outcomes resulting from its use. The developers and publishers of this app disclaim all liability for any loss, damage, or injury resulting from the use or misuse of this app, including errors, omissions, or inaccuracies in its content. This app is not approved for use in live navigation or maneuvering decisions. Always exercise professional judgment and comply with applicable regulations.
                            """),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(nightMode.isEnabled ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(nightMode.isEnabled ? .dark : .light, for: .navigationBar)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView().environmentObject(NightMode())
        }
    }
}
