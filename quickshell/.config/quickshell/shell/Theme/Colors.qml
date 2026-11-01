pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Path to Matugen generated colors.json
    readonly property string colorsPath: {
        const stateHome = Quickshell.env("XDG_STATE_HOME");
        const base = stateHome && stateHome !== "" ? stateHome : (Quickshell.env("HOME") + "/.local/state");
        return base + "/theme/generated/colors.json";
    }

    FileView {
        id: fileView
        path: root.colorsPath
        watchChanges: true

        JsonAdapter {
            id: json

            // Catppuccin Mocha Fallbacks:
            // Mauve: #cba6f7, Crust: #11111b, Mantle: #181825, Base: #1e1e2e,
            // Surface0: #313244, Surface1: #45475a, Subtext0: #a6adc8, Text: #cdd6f4, Red: #f38ba8
            property string primary: "#cba6f7"
            property string on_primary: "#11111b"
            property string primary_container: "#313244"
            property string on_primary_container: "#cdd6f4"

            property string surface: "#1e1e2e"
            property string on_surface: "#cdd6f4"
            property string surface_container: "#181825"
            property string surface_container_low: "#14141f"
            property string surface_container_high: "#313244"
            property string on_surface_variant: "#a6adc8"

            property string outline: "#45475a"
            property string outline_variant: "#313244"
            property string error: "#f38ba8"
            property string on_error: "#11111b"
        }
    }

    // Public color roles consumed by the shell
    property color primary: json.primary || "#cba6f7"
    property color on_primary: json.on_primary || "#11111b"
    property color primary_container: json.primary_container || "#313244"
    property color on_primary_container: json.on_primary_container || "#cdd6f4"

    property color surface: json.surface || "#1e1e2e"
    property color on_surface: json.on_surface || "#cdd6f4"
    property color surface_container: json.surface_container || "#181825"
    property color surface_container_low: json.surface_container_low || "#14141f"
    property color surface_container_high: json.surface_container_high || "#313244"
    property color on_surface_variant: json.on_surface_variant || "#a6adc8"

    property color outline: json.outline || "#45475a"
    property color outline_variant: json.outline_variant || "#313244"
    property color error: json.error || "#f38ba8"
    property color on_error: json.on_error || "#11111b"

    // Smooth animation across all token changes
    readonly property int animDuration: 250
    Behavior on primary { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on on_primary { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on primary_container { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on on_primary_container { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on surface { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on on_surface { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on surface_container { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on surface_container_low { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on surface_container_high { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on on_surface_variant { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on outline { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on outline_variant { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on error { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
    Behavior on on_error { ColorAnimation { duration: root.animDuration; easing.type: Easing.InOutQuad } }
}
