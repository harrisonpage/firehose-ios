import SwiftUI
import UIKit

/// Design tokens from the Modernist system: Archivo, zero corner radius,
/// strong 2px rules, flush-left alignment. Light is the reviewed reference;
/// dark is the primary appearance in real use. Both ship; the system decides.
enum Theme {
    // MARK: Colors

    static let ground = dynamic(light: 0xF8F7F6, dark: 0x17161A)
    static let ink = dynamic(light: 0x201E1D, dark: 0xECE8E4)
    static let metaGrey = dynamic(light: 0x8B8582, dark: 0x6F6A67)
    static let dots = dynamic(light: 0xBAB6B6, dark: 0x56514E)
    static let rowRule = dynamic(light: 0x201E1D, lightAlpha: 0.11, dark: 0xFFFFFF, darkAlpha: 0.07)
    static let headerRule = dynamic(light: 0x201E1D, lightAlpha: 0.35, dark: 0xFFFFFF, darkAlpha: 0.13)
    /// Hacker News orange; the header bar reads white-on-orange in both appearances.
    static let headerFill = Color(rgb: 0xFF6600)
    static let headerInk = Color.white
    static let inset = dynamic(light: 0xEAE9E9, dark: 0x1C1A1E)
    static let accent = Color(rgb: 0xEC3013)
    static let accentText = dynamic(light: 0xAE1800, dark: 0xFF563C)
    static let bannerFill = dynamic(light: 0xFFE0D9, dark: 0x2A1310)
    static let bannerTitle = dynamic(light: 0x7C1405, dark: 0xFF9783)
    static let bannerBody = dynamic(light: 0x9E3526, dark: 0xA89B96)
    static let bannerAction = dynamic(light: 0xAE1800, dark: 0xFF563C)
    static let cardSurface = dynamic(light: 0xF8F7F6, dark: 0x232124)
    static let cardBorder = dynamic(light: 0x201E1D, dark: 0xFFFFFF, darkAlpha: 0.14)
    static let skeletonHeadline = dynamic(light: 0x201E1D, lightAlpha: 0.13, dark: 0xFFFFFF, darkAlpha: 0.13)
    static let skeletonMeta = dynamic(light: 0x201E1D, lightAlpha: 0.07, dark: 0xFFFFFF, darkAlpha: 0.07)

    // MARK: Type — Archivo throughout; all sizes scale with Dynamic Type.

    /// 17/600, −0.012em, scales with body.
    static let headline = Font.custom("Archivo-SemiBold", size: 17, relativeTo: .body)
    /// 13/500, scales with footnote.
    static let meta = Font.custom("Archivo-Medium", size: 13, relativeTo: .footnote)
    /// 11/800, tracked wide (apply .kerning separately).
    static let wordmark = Font.custom("Archivo-ExtraBold", size: 11, relativeTo: .caption)
    /// 11/500 version stamp.
    static let stamp = Font.custom("Archivo-Medium", size: 11, relativeTo: .caption)
    /// 14/600 card title.
    static let cardTitle = Font.custom("Archivo-SemiBold", size: 14, relativeTo: .subheadline)
    /// 12/500 card domain.
    static let cardDomain = Font.custom("Archivo-Medium", size: 12, relativeTo: .caption)
    /// 22/800 — About panel version and the no-image card masthead.
    static let masthead = Font.custom("Archivo-ExtraBold", size: 22, relativeTo: .title2)
    /// 13/400 body text (About panel grid).
    static let body13 = Font.custom("Archivo-Regular", size: 13, relativeTo: .footnote)

    private static func dynamic(
        light: UInt32, lightAlpha: CGFloat = 1,
        dark: UInt32, darkAlpha: CGFloat = 1
    ) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(rgb: dark, alpha: darkAlpha)
                : UIColor(rgb: light, alpha: lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(UIColor(rgb: rgb, alpha: alpha))
    }
}
