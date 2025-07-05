//
//  ModernButtonStyle.swift
//  Nautical Dog Math Helper
//
//  Created by Jill Russell on 7/4/25
//

import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var colorScheme
    
    var isDark: Bool {
        nightMode.isEnabled || colorScheme == .dark
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Avenir", size: 20))
            .fontWeight(.semibold)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: isDark ? [Color.green, Color.green.opacity(0.8)] : [Color("AccentColor"), Color("AccentColor").opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: isDark ? Color.green.opacity(0.3) : Color("AccentColor").opacity(0.3), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
