import QtQuick
import Quickshell
import Quickshell.Wayland
import "Theme"
import "Services"
import "Modules/Bar"
import "Modules/WallpaperPicker"

ShellRoot {
    // 1. Wallpaper Picker Modal Overlay (lazily loaded to avoid ghost layer surfaces)
    Loader {
        active: Wallpaper.pickerOpen
        sourceComponent: WallpaperPicker {}
    }

    // 2. Bar Panel per Screen
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
