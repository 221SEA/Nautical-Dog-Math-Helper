import SwiftUI

struct CardContainer<Content: View>: View {
    let content: Content
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var isDark: Bool {
        nightMode.isEnabled || colorScheme == .dark
    }
    
    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: 600)
            .background(cardBackground)
            .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
    }
    
    // Break down complex views into computed properties
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
    
    private var fillColor: Color {
        isDark ? Color.black.opacity(0.3) : Color.white
    }
    
    private var strokeColor: Color {
        isDark ? Color.green.opacity(0.2) : Color.gray.opacity(0.1)
    }
    
    private var shadowColor: Color {
        isDark ? Color.green.opacity(0.1) : Color.black.opacity(0.1)
    }
}
