import SwiftUI

// This file assumes that the following shared components are defined
// in ReusableComponents.swift: FilledButtonStyle, InputField, ResultField,
// HighlightedResultField, HomeIcon, and dismissKeyboardOnTap() extension.

struct ConvertView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) var dismiss

    @State private var inputValue: String = ""
    @State private var fromUnit: String = "Feet"
    @State private var toUnit: String = "Meters"

    let units = [
        "Feet",
        "Meters",
        "Fathoms",
        "Shackles",
        "Cables",
        "Statute Miles",
        "Nautical Miles",
        "Meters per second",
        "Nautical Miles per hour"
    ]

    // Base factors to convert *length* units into meters
    let lengthToMeters: [String: Double] = [
        "Feet": 0.3048,
        "Meters": 1.0,
        "Fathoms": 1.8288,
        "Shackles": 27.432,
        "Cables": 185.2,
        "Statute Miles": 1609.34,
        "Nautical Miles": 1852.0
    ]

    /// The raw converted value, in the target unit.
    var convertedValue: Double {
        guard let input = Double(inputValue) else {
            return 0.0
        }

        // 1) Meters/sec → Nautical Miles/hour
        if fromUnit == "Meters per second" && toUnit == "Nautical Miles per hour" {
            let metersPerHour = input * 3600.0
            return metersPerHour / (lengthToMeters["Nautical Miles"]!)
        }

        // 2) Nautical Miles/hour → Meters/sec
        if fromUnit == "Nautical Miles per hour" && toUnit == "Meters per second" {
            let metersPerHour = input * (lengthToMeters["Nautical Miles"]!)
            return metersPerHour / 3600.0
        }

        // 3) All other cases: treat as length conversion
        guard
            let fromFactor = lengthToMeters[fromUnit],
            let toFactor   = lengthToMeters[toUnit]
        else {
            return 0.0
        }
        let meters = input * fromFactor
        return meters / toFactor
    }

    /// A nicely formatted string of the result, avoiding nested quotes in the view.
    var formattedValue: String {
        String(format: "%.4f", convertedValue)
    }

    var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }

    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Unit Converter")
                        .font(.custom("Avenir", size: 34))
                        .bold()
                        .padding(.top)
                        .foregroundColor(isDark ? .green : .black)

                    // Input value
                    InputField(label: "Value to Convert",
                               placeholder: "Enter Value",
                               text: $inputValue)

                    // Pickers
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("From:")
                                .foregroundColor(isDark ? .green : .black)
                            Picker("From Unit", selection: $fromUnit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(isDark ? .green : Color("AccentColor"))
                        }
                        HStack {
                            Text("To:")
                                .foregroundColor(isDark ? .green : .black)
                            Picker("To Unit", selection: $toUnit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(isDark ? .green : Color("AccentColor"))
                        }
                    }

                    // Result display
                    Text("Converted Value: \(formattedValue)")
                        .font(.headline)
                        .padding()
                        .foregroundColor(isDark ? .green : .black)

                    Spacer()
                }
                .padding()
            }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("Convert")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
}

struct ConvertView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConvertView().environmentObject(NightMode())
        }
        .preferredColorScheme(.dark)
    }
}
