import QtQuick
import Quickshell
import Quickshell.Wayland
import "Theme"
import "Services"
import "Modules/Bar"
import "Modules/WallpaperPicker"
import "Modules/PowerMenu"
import "Modules/Launcher"
import "Modules/Osd"
import "Modules/Notifications"

ShellRoot {
    // 1. Preloaded Wallpaper Picker Modal Overlay
    WallpaperPicker {}

    // 2. Centered Power Menu Overlay with Confirmation
    PowerMenu {}

    // 3. Application Launcher Overlay
    Launcher {}

    // 4. Per-Screen Overlays (OSD & Notification Popups)
    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData

            Osd {
                screen: modelData
            }

            NotificationPopup {
                targetScreen: modelData
            }
        }
    }

    // 5. Bar Panel per Screen
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
