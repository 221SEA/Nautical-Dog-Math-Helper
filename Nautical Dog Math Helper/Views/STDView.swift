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
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Speed, Time, Distance Calculator")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        Picker("Select Calculation Type", selection: $calculationType) {
                            ForEach(CalculationType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .onAppear {
                            updateSegmentedControlAppearance(isDark: isDark)
                        }
                        .onChange(of: isDark) { newValue in
                            updateSegmentedControlAppearance(isDark: newValue)
                        }
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                if calculationType == .speed {
                                    CompactInputField(
                                        label: "Time",
                                        placeholder: "hh.hh",
                                        text: $time
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    CompactInputField(
                                        label: "Distance",
                                        placeholder: "nm",
                                        text: $distance
                                    )
                                    .frame(maxWidth: .infinity)
                                } else if calculationType == .time {
                                    CompactInputField(
                                        label: "Speed",
                                        placeholder: "knots",
                                        text: $speed
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    CompactInputField(
                                        label: "Distance",
                                        placeholder: "nm",
                                        text: $distance
                                    )
                                    .frame(maxWidth: .infinity)
                                } else {
                                    CompactInputField(
                                        label: "Speed",
                                        placeholder: "knots",
                                        text: $speed
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    CompactInputField(
                                        label: "Time",
                                        placeholder: "hh.hh",
                                        text: $time
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        Button("Calculate", action: calculate)
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)
                        
                        if !calculatedValue.isEmpty {
                            HStack {
                                Text("\(calculationType.rawValue):")
                                    .font(.custom("Avenir", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(isDark ? .green : Color("AccentColor"))
                                Spacer()
                                Text(calculatedValue)
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
            appearance.selectedSegmentTintColor = UIColor(named: "AccentColor") ?? UIColor.systemBlue
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


