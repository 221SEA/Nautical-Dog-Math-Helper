import SwiftUI

struct STDView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var time: String = ""
    @State private var distance: String = ""
    @State private var speed: String = ""
    @State private var calculatedValue: String = ""
    @State private var calculationType: CalculationType = .speed
    
    enum CalculationType: String, CaseIterable, Identifiable {
        case speed = "Speed"
        case time = "Time"
        case distance = "Distance"
        var id: String { self.rawValue }
    }
    
    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Speed, Time, Distance Calculator")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding()
                        .foregroundColor(isDark ? .green : .black)
                    
                    Picker("Select Calculation Type", selection: $calculationType) {
                        ForEach(CalculationType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    // Update segmented appearance when the view appears or when the theme changes:
                    .onAppear {
                        updateSegmentedControlAppearance(isDark: isDark)
                    }
                    .onChange(of: isDark) { newValue in
                        updateSegmentedControlAppearance(isDark: newValue)
                    }
                    
                    VStack(spacing: 20) {
                        if calculationType == .speed {
                            InputField(label: "Time (hh.hh)", placeholder: "Enter Time", text: $time)
                            InputField(label: "Distance (nm)", placeholder: "Enter Distance", text: $distance)
                        } else if calculationType == .time {
                            InputField(label: "Speed (knots)", placeholder: "Enter Speed", text: $speed)
                            InputField(label: "Distance (nm)", placeholder: "Enter Distance", text: $distance)
                        } else {
                            InputField(label: "Speed (knots)", placeholder: "Enter Speed", text: $speed)
                            InputField(label: "Time (hh.hh)", placeholder: "Enter Time", text: $time)
                        }
                    }
                    
                    Button("Calculate", action: calculate)
                        .buttonStyle(FilledButtonStyle())
                        .padding(.horizontal)
                    
                    if !calculatedValue.isEmpty {
                        Text("\(calculationType.rawValue): \(calculatedValue)")
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
        .navigationTitle("DST")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func calculate() {
        switch calculationType {
        case .speed:
            guard let timeVal = Double(time), let distanceVal = Double(distance), timeVal > 0 else {
                calculatedValue = "Invalid input"
                return
            }
            calculatedValue = String(format: "%.1f knots", distanceVal / timeVal)
        case .time:
            guard let speedVal = Double(speed), let distanceVal = Double(distance), speedVal > 0 else {
                calculatedValue = "Invalid input"
                return
            }
            calculatedValue = String(format: "%.2f hours", distanceVal / speedVal)
        case .distance:
            guard let speedVal = Double(speed), let timeVal = Double(time) else {
                calculatedValue = "Invalid input"
                return
            }
            calculatedValue = String(format: "%.1f nm", speedVal * timeVal)
        }
    }
    
    private func updateSegmentedControlAppearance(isDark: Bool) {
        // This will update the global appearance of UISegmentedControl
        let appearance = UISegmentedControl.appearance()
        if isDark {
            appearance.backgroundColor = UIColor.black
            appearance.selectedSegmentTintColor = UIColor.green
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        } else {
            appearance.backgroundColor = UIColor.white
            appearance.selectedSegmentTintColor = UIColor.systemBlue
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}

struct STDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            STDView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
