import SwiftUI

struct SweptPathView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var vesselLength: String = ""
    @State private var vesselBeam: String = ""
    @State private var additionalDriftAngle: String = ""
    @State private var results: [String] = []
    
    let presetDriftAngles: [Double] = [2, 4, 6, 8, 10]
    
    var isDark: Bool {
        nightMode.isEnabled || colorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Swept Path Calculator")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        Text("Output of swept path distances are calculated for 2° - 10° drift angles, in 2° increments. Add an additional angle (i.e. 5°) below to include the results for that angle in the output data.")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)

                        VStack(spacing: 20) {
                            // Vessel dimensions side by side
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Vessel Length",
                                    placeholder: "meters",
                                    text: $vesselLength
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Vessel Beam",
                                    placeholder: "meters",
                                    text: $vesselBeam
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Additional drift angle centered
                            CompactInputField(
                                label: "Additional Drift Angle (optional)",
                                placeholder: "degrees",
                                text: $additionalDriftAngle
                            )
                            .frame(maxWidth: 200)
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)
                        
                        if !results.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Results")
                                    .font(.custom("Avenir", size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isDark ? .green : Color("AccentColor"))
                                    .padding(.bottom, 4)
                                
                                ForEach(results.indices, id: \.self) { index in
                                    HStack {
                                        Text(results[index])
                                            .font(.custom("Avenir", size: 16))
                                            .foregroundColor(isDark ? .green : Color("AccentColor"))
                                        Spacer()
                                    }
                                    
                                    if index < results.count - 1 {
                                        Divider()
                                            .background(isDark ? Color.green.opacity(0.2) : Color("AccentColor").opacity(0.2))
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
        .navigationTitle("Swept Path")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func calculate() {
        results = []
        guard let L = Double(vesselLength),
              let B = Double(vesselBeam),
              L > 0, B > 0 else {
            results = ["Invalid input for vessel length or beam."]
            return
        }
        let baseValue = sqrt(L * L + B * B)
        let angleComponent = atan(B / L)
        var driftAngles = presetDriftAngles
        if let additional = Double(additionalDriftAngle.trimmingCharacters(in: .whitespaces)), additional > 0 {
            let tolerance = 0.001
            if !driftAngles.contains(where: { abs($0 - additional) < tolerance }) {
                driftAngles.append(additional)
            }
        }
        driftAngles.sort()
        for drift in driftAngles {
            let driftRadians = drift * .pi / 180
            let computedPath = baseValue * sin(angleComponent + driftRadians)
            let formatted = String(format: "%.2f", computedPath)
            results.append("Drift Angle \(Int(drift))°: Swept Path = \(formatted) m")
        }
    }
}

struct SweptPathView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SweptPathView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
