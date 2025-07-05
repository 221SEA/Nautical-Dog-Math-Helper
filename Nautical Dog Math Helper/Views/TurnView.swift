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
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Turn Calculator")
                            .font(.custom("Avenir", size: 34)).bold()
                            .foregroundColor(isDark ? .green : .black)

                        Text("This calculates the distance you need to place your parallel index (PI) line ahead of the ship. For larger / faster moving ships, you may need to add up to 0.15nm.\nPlace the PI at the intersection of the distance VRM and your current true course vector (COG).\nOutput includes delta of c/c for user to check validity of response.")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)

                        VStack(spacing: 20) {
                            // Radius on its own row (primary input)
                            CompactInputField(
                                label: "Radius of Turn",
                                placeholder: "nm",
                                text: $radius
                            )
                            .frame(maxWidth: 200)
                            
                            // Leg 1 and Leg 2 side by side
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Leg 1",
                                    placeholder: "COG°",
                                    text: $leg1
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Leg 2",
                                    placeholder: "Course °",
                                    text: $leg2
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }

                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)

                        if !piForTurn.isEmpty || !delta.isEmpty {
                            VStack(spacing: 12) {
                                if !piForTurn.isEmpty {
                                    HStack {
                                        Text("VRM distance to set PI:")
                                            .font(.subheadline)
                                            .foregroundColor(isDark ? .green : .black)
                                        Spacer()
                                        Text("\(piForTurn) nm")
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(isDark ? .green : .black)
                                    }
                                }
                                if !delta.isEmpty {
                                    HStack {
                                        Text("Delta of Course Change:")
                                            .font(.subheadline)
                                            .foregroundColor(isDark ? .green : .black)
                                        Spacer()
                                        Text("\(delta)°")
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(isDark ? .green : .black)
                                    }
                                }
                            }
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()
                    }
                }
                .padding(.vertical)
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
