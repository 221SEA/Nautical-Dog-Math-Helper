import SwiftUI

struct TrueWindView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme

    @State private var awsInput   = ""
    @State private var awaInput   = ""
    @State private var bsInput    = ""
    @State private var hdgInput   = ""
    @State private var twsResult  = ""
    @State private var twdResult  = ""

    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("True Wind Calculator")
                        .font(.custom("Avenir", size: 34)).bold()
                        .foregroundColor(isDark ? .green : .black)

                    Text("""
                    Enter:
                    • Apparent Wind Speed (kts)  
                    • Apparent Wind Angle (0–359° Relative)  
                    • Vessel Speed (kts)  
                    • Vessel Heading (° True)
                    """)
                    .font(.custom("Avenir", size: 16))
                    .padding()
                    .background(isDark ? Color.white.opacity(0.05)
                                       : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(isDark ? .green : .black)

                    VStack(spacing: 16) {
                        InputField(label:       "Apparent Wind Speed (kts)",
                                   placeholder: "e.g. 12.5",
                                   text:        $awsInput)
                        InputField(label:       "Apparent Wind Angle (°)",
                                   placeholder: "0–359 R",
                                   text:        $awaInput)
                        InputField(label:       "Vessel Speed (kts)",
                                   placeholder: "e.g. 8.0",
                                   text:        $bsInput)
                        InputField(label:       "Vessel Heading (°)",
                                   placeholder: "0–359 T",
                                   text:        $hdgInput)
                    }

                    Button("Calculate") {
                        calculateTrueWind()
                    }
                    .buttonStyle(FilledButtonStyle())
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        if !twsResult.isEmpty {
                            ResultField(label: "True Wind Speed",
                                        value: "\(twsResult) kts",
                                        color: isDark ? .green : .black)
                        }
                        if !twdResult.isEmpty {
                            ResultField(label: "True Wind Direction",
                                        value: "\(twdResult)°",
                                        color: isDark ? .green : .black)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("True Wind")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }

    private func calculateTrueWind() {
        guard
            let aws   = Double(awsInput),
            let awa360 = Double(awaInput),
            let bs    = Double(bsInput),
            let hdg   = Double(hdgInput)
        else {
            twsResult = "Invalid input"
            twdResult = ""
            return
        }

        // Map 0–359 → –180…+180 (port negative, starboard positive)
        let awa = (awa360 > 180) ? awa360 - 360 : awa360
        let awaRad = awa * .pi / 180

        // 1) True Wind Speed (law of cosines)
        let tws = sqrt(aws*aws + bs*bs - 2*aws*bs*cos(awaRad))

        // 2) True Wind Angle relative to bow
        let numerator   = aws * sin(awaRad)
        let denominator = aws * cos(awaRad) - bs
        let twaRad      = atan2(numerator, denominator)
        let twaDeg      = twaRad * 180 / .pi

        // 3) True Wind Direction from north
        let rawTWD = hdg + twaDeg
        let twd = (rawTWD.truncatingRemainder(dividingBy: 360) + 360)
                    .truncatingRemainder(dividingBy: 360)

        // Format results
        twsResult = String(format: "%.2f", tws)
        twdResult = String(format: "%.0f", twd)
    }
}

struct TrueWindView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TrueWindView().environmentObject(NightMode())
        }
        .preferredColorScheme(.light)
    }
}
