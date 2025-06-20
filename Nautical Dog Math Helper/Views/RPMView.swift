import SwiftUI

struct RPMView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    @State private var currentRPM: String = ""
    @State private var currentSpeed: String = ""
    @State private var desiredSpeed: String = ""
    @State private var newRPM: String = ""

    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("RPM Calculator")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding()
                        .foregroundColor(isDark ? .green : .black)
                    Text("This page calculates the new engine RPMs required to achieve a desired speed.")
                        .font(.custom("Avenir", size: 18))
                        .padding()
                        .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                        .foregroundColor(isDark ? .green : .black)
                        .cornerRadius(8)
                    
                    VStack(spacing: 20) {
                        InputField(label: "Current RPMs (whole number)", placeholder: "Enter Current RPMs", text: $currentRPM)
                        InputField(label: "Current Speed (knots)", placeholder: "Enter Current Speed", text: $currentSpeed)
                        InputField(label: "Desired Speed (knots)", placeholder: "Enter Desired Speed", text: $desiredSpeed)
                    }
                    
                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)
                    
                    if !newRPM.isEmpty {
                        Text("New RPMs: \(newRPM)")
                            .font(.headline)
                            .foregroundColor(isDark ? .green : .black)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
        }
        .dismissKeyboardOnTap()
        .navigationTitle("RPM Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func calculate() {
        guard let currentRPMVal = Double(currentRPM),
              let currentSpeedVal = Double(currentSpeed),
              let desiredSpeedVal = Double(desiredSpeed),
              currentSpeedVal != 0 else {
            newRPM = "Invalid input"
            return
        }
        let calculatedRPM = (currentRPMVal / currentSpeedVal) * desiredSpeedVal
        newRPM = String(format: "%.0f", calculatedRPM)
    }
}

struct RPMView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RPMView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
