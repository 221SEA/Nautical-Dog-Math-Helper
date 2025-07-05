//
//  CompactInputField.swift
//  Nautical Dog Math Helper
//
//  Created by Jill Russell on 7/4/25.
//

import SwiftUI

struct CompactInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var colorScheme
    
    var isDark: Bool {
        nightMode.isEnabled || colorScheme == .dark
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Avenir", size: 14))  // Larger from caption
                .fontWeight(.semibold)  // Bolder
                .foregroundColor(isDark ? .green : .primary)
                .frame(height: 32, alignment: .bottomLeading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .font(.custom("Avenir", size: 17))
                        .foregroundColor(isDark ? Color.green.opacity(0.5) : Color.gray.opacity(0.6))
                        .padding(.leading, 2)  // Add small padding to placeholder
                }
                .keyboardType(.decimalPad)
                .font(.custom("Avenir", size: 17))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(isDark ? Color.white.opacity(0.1) : Color.white)
                .foregroundColor(isDark ? .green : .black)
                .accentColor(isDark ? .green : Color("AccentColor"))
                .tint(isDark ? .green : Color("AccentColor"))  // Add tint for cursor
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isDark ? Color.green.opacity(0.5) : Color("AccentColor").opacity(0.3), lineWidth: 1.5)
                )
        }
    }
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
