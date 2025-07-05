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
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("True Wind Calculator")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        Text("Output is true wind direction and speed.")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)

                        VStack(spacing: 20) {
                            // First row - Wind data
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Apparent Wind Speed",
                                    placeholder: "knots",
                                    text: $awsInput
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Apparent Wind Angle",
                                    placeholder: "0-359°",
                                    text: $awaInput
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Second row - Vessel data
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Vessel Speed",
                                    placeholder: "knots",
                                    text: $bsInput
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Vessel Heading",
                                    placeholder: "0-359°",
                                    text: $hdgInput
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }

                        Button("Calculate") {
                            calculateTrueWind()
                        }
                        .buttonStyle(ModernButtonStyle())
                        .padding(.horizontal)

                        if !twsResult.isEmpty || !twdResult.isEmpty {
                            VStack(spacing: 12) {
                                if !twsResult.isEmpty {
                                    ResultField(
                                        label: "True Wind Speed",
                                        value: "\(twsResult) kts",
                                        color: isDark ? .green : Color("AccentColor")
                                    )
                                }
                                if !twdResult.isEmpty {
                                    ResultField(
                                        label: "True Wind Direction",
                                        value: "\(twdResult)°",
                                        color: isDark ? .green : Color("AccentColor")
                                    )
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
