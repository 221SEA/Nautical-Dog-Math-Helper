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
                VStack(alignment: .leading, spacing: 20) {
                    Text("Swept Path Calculator")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding(.top)
                        .foregroundColor(isDark ? .green : .black)
                    
                    InputField(label: "Vessel Length (meters)", placeholder: "Enter vessel length", text: $vesselLength)
                    InputField(label: "Vessel Beam (meters)", placeholder: "Enter vessel beam", text: $vesselBeam)
                    InputField(label: "Additional Drift Angle (deg, optional)", placeholder: "e.g., 5", text: $additionalDriftAngle)
                    
                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)
                    
                    if !results.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(results.indices, id: \.self) { index in
                                Text(results[index])
                                    .font(.headline)
                                    .foregroundColor(isDark ? .green : .black)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
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
