import SwiftUI
// Formerly only for Hawk Inlet. Changed to Squat/UKC for generic use but file name kept.
struct HawkView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    // User‐entered inputs
    @State private var leastChartedDepth: String = ""
    @State private var heightOfTide: String = ""
    @State private var blockCoefficient: String = ""
    @State private var transitSpeed: String = ""
    @State private var deepDraft: String = ""

    // Results
    @State private var waterDepthAtHW: String = ""
    @State private var maxStaticDraft: String = ""
    @State private var squat: String = ""
    @State private var underkeelClearance: String = ""
    @State private var ukcWarning: Bool = false

    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()

            ScrollView {
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Squat & UKC")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)

                        Text("Formula used: Squat = 2 x Cb x V² / 100\nOutput: Water depth at HW (m); Max static draft(m); Squat(m); UKC(m)")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)

                        VStack(spacing: 20) {
                            // First row - 2 fields
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Least Charted Depth",
                                    placeholder: "meters",
                                    text: $leastChartedDepth
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Height of Tide at HW",
                                    placeholder: "meters",
                                    text: $heightOfTide
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Second row - 2 fields
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Block Coefficient (Cb)",
                                    placeholder: "e.g. 0.8",
                                    text: $blockCoefficient
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Transit Speed",
                                    placeholder: "knots",
                                    text: $transitSpeed
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Third row - 1 field centered
                            CompactInputField(
                                label: "Vessel Deep Draft",
                                placeholder: "meters",
                                text: $deepDraft
                            )
                            .frame(maxWidth: 200)
                            .frame(maxWidth: .infinity)
                        }

                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)

                        if !waterDepthAtHW.isEmpty {
                            VStack(spacing: 12) {
                                ResultField(
                                    label: "Water Depth at HW (m):",
                                    value: waterDepthAtHW,
                                    color: isDark ? .green : Color("AccentColor")
                                )
                                ResultField(
                                    label: "Max Static Draft (m):",
                                    value: maxStaticDraft,
                                    color: isDark ? .green : Color("AccentColor")
                                )
                                ResultField(
                                    label: "Squat (m):",
                                    value: squat,
                                    color: isDark ? .green : Color("AccentColor")
                                )
                                
                                // Special handling for UKC with warning
                                VStack(alignment: .leading, spacing: 8) {
                                    HighlightedResultField(
                                        label: "Underkeel Clearance (m):",
                                        value: underkeelClearance,
                                        isWarning: ukcWarning
                                    )
                                    if ukcWarning {
                                        Text("⚠️ Hawk Inlet SE AK only: Calculated UKC is less than USCG required 1.83 m!")
                                            .font(.custom("Avenir", size: 14))
                                            .foregroundColor(.red)
                                            .bold()
                                            .padding(.horizontal, 8)
                                    }
                                }
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
        .dismissKeyboardOnTap()
        .navigationTitle("Squat & UKC")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }

    private func calculate() {
        // Parse all inputs, including the new least charted depth
        guard
            let charted = Double(leastChartedDepth),
            let tide    = Double(heightOfTide),
            let cb      = Double(blockCoefficient),
            let speed   = Double(transitSpeed),
            let draft   = Double(deepDraft)
        else {
            waterDepthAtHW    = "Invalid Input"
            squat             = ""
            maxStaticDraft    = ""
            underkeelClearance = ""
            ukcWarning        = false
            return
        }

        // 1) Water depth at HW
        let depthAtHW = charted + tide
        waterDepthAtHW = String(format: "%.2f", depthAtHW)

        // 2) Squat (m)
        let calculatedSquat = (cb * 2.0 * pow(speed, 2)) / 100.0
        squat = String(format: "%.2f", calculatedSquat)

        // 3) Max static draft = waterDepthAtHW – squat – regulatory UKC (1.83 m)
        let maxDraft = depthAtHW - calculatedSquat - 1.83
        maxStaticDraft = String(format: "%.2f", maxDraft)

        // 4) Underkeel clearance = waterDepthAtHW – vessel draft – squat
        let ukc = depthAtHW - draft - calculatedSquat
        underkeelClearance = String(format: "%.2f", ukc)

        // 5) Warning if UKC < 1.83 m
        ukcWarning = ukc < 1.83
    }
}

struct HawkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HawkView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
