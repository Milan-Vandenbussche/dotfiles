import QtQuick
import Quickshell
import Quickshell.Wayland
import "Theme"
import "Services"
import "Modules/Bar"
import "Modules/WallpaperPicker"

ShellRoot {
    // 1. Wallpaper Picker Modal Overlay
    WallpaperPicker {}

    // 2. Bar Panel per Screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            WlrLayershell.namespace: "qs-bar"
            WlrLayershell.layer: WlrLayer.Top

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 28
            color: "transparent"

            Bar {
                screen: barWindow.screen
                barWindow: barWindow
            }
        }
    }
}
