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
                CardContainer {
                    VStack(spacing: 20) {
                        Text("Unit Converter")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        // Input value - centered and compact
                        CompactInputField(
                            label: "Value to Convert",
                            placeholder: "Enter Value",
                            text: $inputValue
                        )
                        .frame(maxWidth: 200)
                        .frame(maxWidth: .infinity)
                        
                        // Pickers in a styled container
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("From:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(isDark ? .green : .primary)
                                    .frame(width: 50, alignment: .leading)
                                
                                Picker("From Unit", selection: $fromUnit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(isDark ? .green : Color("AccentColor"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            HStack {
                                Text("To:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(isDark ? .green : .primary)
                                    .frame(width: 50, alignment: .leading)
                                
                                Picker("To Unit", selection: $toUnit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(isDark ? .green : Color("AccentColor"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        
                        Button("Calculate", action: { }) // Empty action since conversion is automatic
                            .buttonStyle(ModernButtonStyle())
                            .padding(.horizontal)
                        
                        // Result display
                        // Result display
                        HStack {
                            Text("Converted Value:")
                                .font(.custom("Avenir", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(isDark ? .green : Color("AccentColor"))
                            Spacer()
                            Text(formattedValue)
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
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
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
