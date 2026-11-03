import QtQuick
import Quickshell
import Quickshell.Wayland
import "Theme"
import "Services"
import "Modules/Bar"
import "Modules/WallpaperPicker"
import "Modules/PowerMenu"
import "Modules/Osd"

ShellRoot {
    // 1. Preloaded Wallpaper Picker Modal Overlay
    WallpaperPicker {}

    // 2. Centered Power Menu Overlay with Confirmation
    PowerMenu {}

    // 3. OSD Overlay per Screen (Volume & Brightness feedback)
    Variants {
        model: Quickshell.screens

        Osd {
            required property var modelData
            screen: modelData
        }
    }

    // 4. Bar Panel per Screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            WlrLayershell.namespace: "qs-bar"
            WlrLayershell.layer: layer_top_enum

            readonly property var layer_top_enum: WlrLayer.Top

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
