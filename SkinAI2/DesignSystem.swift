// Existing imports
import SwiftUI

// MARK: - Color System
extension Color {
    // Existing colors
    static let skinGood = Color.green
    static let skinBad = Color.yellow // Or Color.red, depending on severity/preference
    static let cardBackground = Color(UIColor.systemBackground) // Adapts to light/dark mode
    static let primaryText = Color(UIColor.label) // Adapts to light/dark mode
    static let secondaryText = Color(UIColor.secondaryLabel) // Adapts to light/dark mode
    static let appBlue = Color.blue // From RecommendationsView
    static let appPink = Color.pink // From RecommendationsView

    // ADD: New semantic colors for a unified system
    static let accent = Color.appBlue // Main interactive color
    static let destructive = Color.red // For delete or critical actions
    static let subtleBackground = Color(UIColor.secondarySystemBackground) // For elements needing slight separation
    static let subtleBorder = Color(UIColor.separator) // For subtle borders
    static let icon = Color.secondaryText // Default icon color
}

// MARK: - Typography System
// Based on your specifications. Apply these directly using .font() and .fontWeight() or .opacity().
// - Section Headers: .font(.title2.bold())
// - Block Titles: .font(.headline)
// - Supporting Info: .font(.subheadline)
// - Secondary Metadata: .font(.caption2).opacity(0.6)
// We will use these standard modifiers. Custom ViewModifiers can be added if needed for more complex styles.
// Example of direct application: Text("Header").font(.title2.bold())

// MARK: - Card View Modifier
// Existing AppCardStyle
struct AppCardStyle: ViewModifier {
    var minHeight: CGFloat? = nil // Optional minHeight

    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.standard) // Use defined spacing
            .background(Color.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.standard) // Use defined corner radius
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ifLet(minHeight) { view, height in // Helper to apply modifier conditionally
                view.frame(minHeight: height)
            }
    }
}

extension View {
    // Existing appCardStyle
    func appCardStyle(minHeight: CGFloat? = nil) -> some View {
        self.modifier(AppCardStyle(minHeight: minHeight))
    }
}

// Helper for conditional modifiers
// Existing ifLet
extension View {
    @ViewBuilder
    func ifLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Spacing & Corner Radius
struct DesignSystem {
    struct Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let standard: CGFloat = 16 // Default padding for cards, content
        static let medium: CGFloat = 12 // Consistent spacing between sections/cards
        static let large: CGFloat = 24
        static let sectionBottom: CGFloat = 12 // As used in RecommendationsView
    }

    // ADD: Consistent Corner Radius values
    struct CornerRadius {
        static let small: CGFloat = 4
        static let standard: CGFloat = 12 // For cards
        static let large: CGFloat = 16
        static let capsule: CGFloat = 999 // For pill-shaped elements
    }

    // ADD: Reusable Button Styles
    struct AppPrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .padding(.vertical, Spacing.medium)
                .padding(.horizontal, Spacing.large)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white) // Text color on accent background
                .background(Color.accent)
                .cornerRadius(CornerRadius.standard)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    struct AppSecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .padding(.vertical, Spacing.medium)
                .padding(.horizontal, Spacing.large)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.accent)
                .background(Color.accent.opacity(0.15)) // Subtle background
                .cornerRadius(CornerRadius.standard)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(Color.accent, lineWidth: 1.5) // Optional: border instead of/with background
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    struct AppTextButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(Color.accent)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
        }
    }

    // ADD: Reusable TextField Style
    struct AppTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(.subheadline) // Consistent font for input
                .padding(Spacing.medium)
                .background(Color.subtleBackground)
                .cornerRadius(CornerRadius.standard)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(Color.subtleBorder, lineWidth: 1)
                )
        }
    }

    // ADD: Icons - SF Symbols
    // Recommendation: Use SF Symbols for iconography.
    // Examples: "camera.fill", "lightbulb.fill", "drop.fill", "chart.line.uptrend.xyaxis",
    // "chevron.right", "trash.fill", "gearshape.fill", "house.fill", "magnifyingglass"
    // Use consistently with appropriate weights and scales.
    // Color them using .foregroundColor(Color.icon) or .foregroundColor(Color.accent) as needed.

    // ADD: Headers
    // For screen titles, use .navigationTitle("Your Title") within a NavigationView.
    // For section headers within lists or forms, use the Section view with a custom header:
    // Section(header: Text("Section Title").font(.title2.bold()).foregroundColor(.primaryText)) { ... }
    // This aligns with the typography system.

    // ADD: Tab Bar
    // Use SwiftUI's TabView. For icons, consistently use SF Symbols.
    // Example:
    // TabView {
    //     HomeView()
    //         .tabItem {
    //             Label("Home", systemImage: "house.fill")
    //         }
    //     AnalyzeView()
    //         .tabItem {
    //             Label("Analyze", systemImage: "camera.fill") // Or your specific icon
    //         }
    //     // ... other tabs
    // }
    // .accentColor(Color.accent) // Sets the selected tab item color
}
// End of file. No additional code.