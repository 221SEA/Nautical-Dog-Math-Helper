import SwiftUI

struct TurnView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme

    @State private var leg1      = ""
    @State private var leg2      = ""
    @State private var radius    = ""
    @State private var delta     = ""
    @State private var piForTurn = ""

    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Turn Calculator")
                        .font(.custom("Avenir", size: 34)).bold()
                        .foregroundColor(isDark ? .green : .black)

                    Text("This calculates the distance you need to place your parallel index (PI) line ahead of the ship.")
                        .font(.custom("Avenir", size: 18))
                        .padding()
                        .background(isDark ? Color.white.opacity(0.05)
                                           : Color.gray.opacity(0.1))
                        .foregroundColor(isDark ? .green : .black)
                        .cornerRadius(8)

                    VStack(spacing: 20) {
                        InputField(label:       "Radius of Turn (nm)",
                                   placeholder: "Enter Radius",
                                   text:        $radius)
                        InputField(label:       "Leg 1 of Turn (°)",
                                   placeholder: "Enter Leg 1",
                                   text:        $leg1)
                        InputField(label:       "Leg 2 of Turn (°)",
                                   placeholder: "Enter Leg 2",
                                   text:        $leg2)
                    }

                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)

                    VStack(spacing: 20) {
                        if !piForTurn.isEmpty {
                            Text("PI for Turn: \(piForTurn) nm")
                                .font(.headline)
                                .foregroundColor(isDark ? .green : .black)
                        }
                        if !delta.isEmpty {
                            Text("Delta of Course Change: \(delta)°")
                                .font(.headline)
                                .foregroundColor(isDark ? .green : .black)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("Turn Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }

    private func calculate() {
        guard
            let leg1Val   = Double(leg1),
            let leg2Val   = Double(leg2),
            let radiusVal = Double(radius)
        else {
            delta     = "Invalid input"
            piForTurn = ""
            return
        }

        // 1) fold raw course difference into the acute angle Δ
        var rawΔ = abs(leg1Val - leg2Val)
        if rawΔ > 180 { rawΔ = 360 - rawΔ }

        // 2) lead distance L = R × tan(Δ/2)
        let L = radiusVal * tan((rawΔ / 2) * .pi / 180)

        delta     = String(format: "%.0f", rawΔ)
        piForTurn = String(format: "%.2f", L)
    }
}
