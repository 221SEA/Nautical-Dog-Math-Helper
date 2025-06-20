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
                VStack(alignment: .leading, spacing: 20) {
                    Text("Squat & UKC")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding(.top)
                        .foregroundColor(isDark ? .green : .black)

                    Text("Formula used: Squat = 2 x Cb x V² / 100\nOutput: water depth(m); max static draft(m); squat(m); UKC(m)")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(isDark ? .green : .black)
                        .padding(.bottom)

                    VStack(spacing: 20) {
                        // New user‐input for least charted depth
                        InputField(
                            label: "Least Charted Depth (m)",
                            placeholder: "e.g. 7.6",
                            text: $leastChartedDepth
                        )

                        InputField(
                            label: "Height of Tide at HW (m)",
                            placeholder: "Enter Height of Tide",
                            text: $heightOfTide
                        )
                        InputField(
                            label: "Vessel Block Coefficient (Cb)",
                            placeholder: "Enter Block Coefficient (e.g. 0.8)",
                            text: $blockCoefficient
                        )
                        InputField(
                            label: "Transit Speed (knots)",
                            placeholder: "Enter Transit Speed",
                            text: $transitSpeed
                        )
                        InputField(
                            label: "Vessel Deep Draft (m)",
                            placeholder: "Enter Deep Draft",
                            text: $deepDraft
                        )
                    }

                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)

                    Group {
                        if !waterDepthAtHW.isEmpty {
                            ResultField(
                                label: "Water Depth at HW (m):",
                                value: waterDepthAtHW,
                                color: isDark ? .green : .black
                            )
                        }
                        if !maxStaticDraft.isEmpty {
                            ResultField(
                                label: "Max Static Draft (m):",
                                value: maxStaticDraft,
                                color: isDark ? .green : .black
                            )
                        }
                        if !squat.isEmpty {
                            ResultField(
                                label: "Squat (m):",
                                value: squat,
                                color: isDark ? .green : .black
                            )
                        }
                        if !underkeelClearance.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HighlightedResultField(
                                    label: "Underkeel Clearance (m):",
                                    value: underkeelClearance,
                                    isWarning: ukcWarning
                                )
                                if ukcWarning {
                                    Text("⚠️ Hawk Inlet SE AK only: Calculated UKC is less than USCG required 1.83 m!")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .bold()
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
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
