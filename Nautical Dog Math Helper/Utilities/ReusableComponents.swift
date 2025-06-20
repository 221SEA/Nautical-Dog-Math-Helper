import SwiftUI

// MARK: - FilledButtonStyle
struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Avenir", size: 20))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - InputField
struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let isDark = nightMode.isEnabled || colorScheme == .dark

        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(isDark ? .green : .black)

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(isDark ? Color.white.opacity(0.1) : Color.white)
                .foregroundColor(isDark ? .green : .black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isDark ? Color.green.opacity(0.3) : Color.gray.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - ResultField
struct ResultField: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(color)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - HighlightedResultField
struct HighlightedResultField: View {
    let label: String
    let value: String
    let isWarning: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
            Spacer()
            if isWarning {
                HStack(spacing: 5) {
                    Text("⚠️")
                        .font(.headline)
                    Text(value)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.red)
                }
            } else {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - HomeIcon
struct HomeIcon: View {
    var title: String
    var iconName: String
    var isSystemSymbol: Bool = false
    @EnvironmentObject var nightMode: NightMode

    var body: some View {
        VStack(spacing: 8) {
            Group {
                if isSystemSymbol {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                } else {
                    Image(iconName)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(nightMode.isEnabled ? .green : .black)
                }
            }
            .shadow(radius: 3)
            Text(title)
                .font(.custom("Avenir", size: 12))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(nightMode.isEnabled ? .green : .black)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(nightMode.isEnabled ? Color.white.opacity(0.05) : Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(nightMode.isEnabled ? Color.green.opacity(0.3) : Color("TileBorder"), lineWidth: 0.5)
        )
    }
}

// MARK: - Keyboard Dismiss Modifier
struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture()
                    .onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}

extension View {
    /// Call this on any view to allow tapping anywhere to dismiss the keyboard.
    func dismissKeyboardOnTap() -> some View {
        self.modifier(KeyboardDismissModifier())
    }
}
