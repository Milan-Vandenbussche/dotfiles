pragma Singleton
import QtQuick

Item {
    id: root

    // Typography
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // Font Sizes (unscaled base)
    readonly property int fontSmall: 10
    readonly property int fontNormal: 12
    readonly property int fontMedium: 14
    readonly property int fontLarge: 16
    readonly property int fontTitle: 18

    // Spacing & Padding
    readonly property int spacingXSmall: 2
    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 12
    readonly property int spacingXLarge: 16

    // Corner Radii
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12
    readonly property int radiusFull: 9999

    // Icon Sizes
    readonly property int iconXSmall: 12
    readonly property int iconSmall: 14
    readonly property int iconMedium: 18
    readonly property int iconLarge: 22

    // Animation Durations & Easing
    readonly property int animDurationFast: 120
    readonly property int animDurationNormal: 200
    readonly property int animDurationSlow: 300
    readonly property var animEasing: Easing.InOutQuad

    // Scaling helper for displays
    function scaled(value, screen) {
        if (!screen || !screen.devicePixelRatio) return value;
        return Math.round(value * screen.devicePixelRatio);
    }
}
