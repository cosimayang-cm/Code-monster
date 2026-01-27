import Foundation

/// Text style representing formatting attributes.
///
/// TextStyle is a value type containing boolean flags for text formatting:
/// - Bold
/// - Italic
/// - Underline
///
/// Foundation-only design ensures Model layer independence from UIKit.
///
/// Usage:
/// ```swift
/// let boldStyle = TextStyle.bold
/// let customStyle = TextStyle(isBold: true, isItalic: true)
/// ```
public struct TextStyle: Equatable, Hashable {
    // MARK: - Properties

    /// Indicates if text should be rendered in bold
    public let isBold: Bool

    /// Indicates if text should be rendered in italic
    public let isItalic: Bool

    /// Indicates if text should be underlined
    public let isUnderlined: Bool

    // MARK: - Initialization

    /// Creates a text style with specified formatting attributes.
    ///
    /// - Parameters:
    ///   - isBold: Enable bold formatting (default: false)
    ///   - isItalic: Enable italic formatting (default: false)
    ///   - isUnderlined: Enable underline formatting (default: false)
    public init(
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false
    ) {
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
    }

    // MARK: - Predefined Styles

    /// Plain text with no formatting
    public static let plain = TextStyle()

    /// Bold text
    public static let bold = TextStyle(isBold: true)

    /// Italic text
    public static let italic = TextStyle(isItalic: true)

    /// Underlined text
    public static let underline = TextStyle(isUnderlined: true)
}
