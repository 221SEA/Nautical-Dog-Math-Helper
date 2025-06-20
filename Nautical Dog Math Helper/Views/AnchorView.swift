import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    @State private var vesselLOA: String = ""
    @State private var bottomDepth: String = ""
    @State private var hawsepipeFreeboard: String = ""
    @State private var shacklesOnDeck: String = ""
    @State private var normalWxShots: String = ""
    @State private var roughWxShots: String = ""
    @State private var walkOutShots: String = ""
    @State private var swingCircle: String = ""

    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Anchor Swing Circle Calculator")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding(.top)
                        .foregroundColor(isDark ? .green : .black)
                    
                    VStack(spacing: 20) {
                        // Using the shared InputField from ReusableComponents.swift
                        InputField(label: "Vessel LOA (meters)", placeholder: "Enter Vessel LOA", text: $vesselLOA)
                        InputField(label: "Bottom Depth (meters)", placeholder: "Enter Bottom Depth", text: $bottomDepth)
                        InputField(label: "Hawsepipe Freeboard (meters)", placeholder: "Enter Freeboard", text: $hawsepipeFreeboard)
                        InputField(label: "Shackles on Deck (number)", placeholder: "Enter Shackles", text: $shacklesOnDeck)
                    }
                    
                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle()) // Using shared FilledButtonStyle
                        .padding(.horizontal)
                    
                    Group {
                        if !normalWxShots.isEmpty {
                            ResultField(label: "Normal Weather Guide (# shots):", value: normalWxShots, color: isDark ? .green : .black)
                        }
                        if !roughWxShots.isEmpty {
                            ResultField(label: "Rough Weather Guide (# shots):", value: roughWxShots, color: isDark ? .green : .black)
                        }
                        if !walkOutShots.isEmpty {
                            ResultField(label: "Walk Out Shots (#):", value: walkOutShots, color: isDark ? .green : .black)
                        }
                        if !swingCircle.isEmpty {
                            ResultField(label: "Swing Circle (nm):", value: swingCircle, color: isDark ? .green : .black)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
        }
        .dismissKeyboardOnTap()  // Using the shared keyboard dismiss extension
        .navigationTitle("Anchor Swing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func calculate() {
        guard let loa = Double(vesselLOA),
              let depth = Double(bottomDepth),
              let shackles = Double(shacklesOnDeck) else {
            normalWxShots = "Invalid Input"
            roughWxShots = ""
            walkOutShots = ""
            swingCircle = ""
            return
        }
        
        let freeboard = Double(hawsepipeFreeboard) ?? 0.0
        let normalShots = ((depth * 3) + 90) / 27.43
        normalWxShots = String(format: "%.1f", normalShots)
        let roughShots = ((depth * 4) + 150) / 27.43
        roughWxShots = String(format: "%.1f", roughShots)
        let walkOut = (depth - 5) / 27.432
        walkOutShots = String(format: "%.1f", walkOut)
        let b7 = depth + freeboard
        let chainLengthMeters = shackles * 27.432
        let underRadiusSquared = chainLengthMeters * chainLengthMeters - (b7 * b7)
        
        guard underRadiusSquared >= 0 else {
            swingCircle = "Invalid"
            return
        }
        
        let effectiveRadius = sqrt(underRadiusSquared)
        let swing = (effectiveRadius + loa) / 1852
        swingCircle = String(format: "%.2f", swing)
    }
}

struct AnchorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AnchorView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
