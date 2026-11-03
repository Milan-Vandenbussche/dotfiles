import QtQuick
import Quickshell
import "../../Theme"
import "../../Services"

Rectangle {
    id: root

    required property var screen
    required property var barWindow

    anchors.fill: parent
    color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.80)

    Behavior on color { ColorAnimation { duration: Appearance.animDurationNormal } }

    // Subtle 1px bottom boundary line with theme accent
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
    }

    // ── LEFT SECTION (Workspaces + Media Ticker) ─────────────────────────
    Row {
        id: leftCluster
        anchors.left: parent.left
        anchors.leftMargin: Appearance.spacingLarge
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacingLarge

        Workspaces {
            screen: root.screen
        }

        MediaTicker {}
    }

    // ── CENTER SECTION (Active Window Title) ─────────────────────────────
    WindowTitle {
        anchors.centerIn: parent
    }

    // ── RIGHT SECTION (Picker + Status + Clock + Bell + Power) ───────────
    Row {
        id: rightCluster
        anchors.right: parent.right
        anchors.rightMargin: Appearance.spacingLarge
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacingLarge

        StatusCluster {
            parentWindow: root.barWindow
            onWallpaperPickerRequested: Wallpaper.togglePicker()
        }

        ClockWidget {
            parentWindow: root.barWindow
        }

        NotificationWidget {
            parentWindow: root.barWindow
        }

        PowerMenuPopup {
            parentWindow: root.barWindow
        }
    }
}
