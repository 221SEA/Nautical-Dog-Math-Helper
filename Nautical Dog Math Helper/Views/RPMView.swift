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
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("RPM Calculator")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        Text("This page calculates the new engine RPMs required to achieve a desired speed, given current RPM and SMG. It does not take into account any changes in future set/drift.")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)
                        
                        VStack(spacing: 20) {
                            // First row - current values side by side
                            HStack(spacing: 16) {
                                CompactInputField(
                                    label: "Current RPMs",
                                    placeholder: "##",
                                    text: $currentRPM
                                )
                                .frame(maxWidth: .infinity)
                                
                                CompactInputField(
                                    label: "Current Speed",
                                    placeholder: "knots",
                                    text: $currentSpeed
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Second row - desired speed centered
                            CompactInputField(
                                label: "Desired Speed",
                                placeholder: "knots",
                                text: $desiredSpeed
                            )
                            .frame(maxWidth: 200)
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)
                        
                        if !newRPM.isEmpty {
                            HStack {
                                Text("New RPMs:")
                                    .font(.custom("Avenir", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(isDark ? .green : Color("AccentColor"))
                                Spacer()
                                Text(newRPM)
                                    .font(.custom("Avenir", size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isDark ? .green : Color("AccentColor"))
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
