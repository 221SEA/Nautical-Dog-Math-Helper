import SwiftUI

struct ROTView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    @State private var speed: String = ""
    @State private var radius: String = ""
    @State private var rot: String = ""
    @State private var selectedCalculation: String = "ROT"
    @State private var result: String = ""

    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Rate of Turn Calculator")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding()
                        .foregroundColor(isDark ? .green : .black)
                    
                    Picker("Calculation", selection: $selectedCalculation) {
                        Text("ROT").tag("ROT")
                        Text("Radius").tag("Radius")
                        Text("Speed").tag("Speed")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    // Update segmented appearance when this view appears or theme changes:
                    .onAppear {
                        updateSegmentedControlAppearance(isDark: isDark)
                    }
                    .onChange(of: isDark) { newValue in
                        updateSegmentedControlAppearance(isDark: newValue)
                    }
                    
                    VStack(spacing: 20) {
                        if selectedCalculation == "ROT" {
                            InputField(label: "Speed (knots)", placeholder: "Enter speed", text: $speed)
                            InputField(label: "Radius (nm)", placeholder: "Enter radius", text: $radius)
                        } else if selectedCalculation == "Radius" {
                            InputField(label: "Speed (knots)", placeholder: "Enter speed", text: $speed)
                            InputField(label: "ROT (deg/min)", placeholder: "Enter ROT", text: $rot)
                        } else if selectedCalculation == "Speed" {
                            InputField(label: "ROT (deg/min)", placeholder: "Enter ROT", text: $rot)
                            InputField(label: "Radius (nm)", placeholder: "Enter radius", text: $radius)
                        }
                    }
                    
                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)
                    
                    if !result.isEmpty {
                        Text("Result: \(result)")
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
        .navigationTitle("Rate of Turn Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func calculate() {
        if selectedCalculation == "ROT" {
            guard let s = Double(speed), let r = Double(radius) else {
                result = "Invalid input"
                return
            }
            let rotValue = (0.955 * s) / r
            result = String(format: "%.2f deg/min", rotValue)
        } else if selectedCalculation == "Radius" {
            guard let s = Double(speed), let r = Double(rot) else {
                result = "Invalid input"
                return
            }
            let radiusValue = (0.955 * s) / r
            result = String(format: "%.2f nm", radiusValue)
        } else if selectedCalculation == "Speed" {
            guard let r = Double(rot), let rad = Double(radius) else {
                result = "Invalid input"
                return
            }
            let speedValue = (r * rad) / 0.955
            result = String(format: "%.2f knots", speedValue)
        }
    }
    
    private func updateSegmentedControlAppearance(isDark: Bool) {
        let appearance = UISegmentedControl.appearance()
        if isDark {
            appearance.backgroundColor = UIColor.black
            appearance.selectedSegmentTintColor = UIColor.green
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        } else {
            appearance.backgroundColor = UIColor.white
            appearance.selectedSegmentTintColor = UIColor(named: "AccentColor") ?? UIColor.systemBlue
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}

struct ROTView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ROTView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
