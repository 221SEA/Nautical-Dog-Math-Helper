import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    @State private var vesselLOA: String = ""
    @State private var bottomDepth: String = ""
    @State private var hawsepipeFreeboard: String = ""
    @State private var shacklesOnDeck: String = ""
    @State private var normalWxShots: String = ""
    @State private var roughWxShots: String = ""
    @State private var walkOutShots: String = ""
    @State private var swingCircle: String = ""

    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Anchor Swing Circle Calculator")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .padding()
                            .foregroundColor(isDark ? .green : .black)
                        Text("Input details and an estimated # of shots on deck.\nOutput: Guidelines for Normal Wx Shots, Rough Wx Shots, Walk Out # of Shots and a calculated Swing Circle")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Vessel LOA",
                                    placeholder: "meters",
                                    text: $vesselLOA
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Bottom Depth",
                                    placeholder: "meters",
                                    text: $bottomDepth
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Hawsepipe Freeboard",
                                    placeholder: "meters",
                                    text: $hawsepipeFreeboard
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Shackles on Deck",
                                    placeholder: "shackles",
                                    text: $shacklesOnDeck
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle()) // Using shared FilledButtonStyle
                            .padding(.horizontal)
                        
                        if !normalWxShots.isEmpty {
                            VStack(spacing: 12) {
                                ResultField(label: "Normal Weather Guide (# shots):", value: normalWxShots, color: isDark ? .green : Color("AccentColor"))
                                ResultField(label: "Rough Weather Guide (# shots):", value: roughWxShots, color: isDark ? .green : Color("AccentColor"))
                                ResultField(label: "Walk Out Shots (#):", value: walkOutShots, color: isDark ? .green : Color("AccentColor"))
                                ResultField(label: "Swing Circle (nm):", value: swingCircle, color: isDark ? .green : Color("AccentColor"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isDark ? Color.green.opacity(0.1) : Color("AccentColor").opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isDark ? Color.green.opacity(0.3) : Color("AccentColor").opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
            }
        }
        .dismissKeyboardOnTap()  // Using the shared keyboard dismiss extension
        .navigationTitle("Anchor Swing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    private func calculate() {
        guard let loa = Double(vesselLOA),
              let depth = Double(bottomDepth),
              let shackles = Double(shacklesOnDeck) else {
            normalWxShots = "Invalid Input"
            roughWxShots = ""
            walkOutShots = ""
            swingCircle = ""
            return
        }
        
        let freeboard = Double(hawsepipeFreeboard) ?? 0.0
        let normalShots = ((depth * 3) + 90) / 27.43
        normalWxShots = String(format: "%.1f", normalShots)
        let roughShots = ((depth * 4) + 150) / 27.43
        roughWxShots = String(format: "%.1f", roughShots)
        let walkOut = (depth - 5) / 27.432
        walkOutShots = String(format: "%.1f", walkOut)
        let b7 = depth + freeboard
        let chainLengthMeters = shackles * 27.432
        let underRadiusSquared = chainLengthMeters * chainLengthMeters - (b7 * b7)
        
        guard underRadiusSquared >= 0 else {
            swingCircle = "Invalid"
            return
        }
        
        let effectiveRadius = sqrt(underRadiusSquared)
        let swing = (effectiveRadius + loa) / 1852
        swingCircle = String(format: "%.2f", swing)
    }
}

struct AnchorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AnchorView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
