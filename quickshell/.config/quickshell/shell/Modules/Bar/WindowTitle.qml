import QtQuick
import Quickshell.Hyprland
import "../../Theme"

Item {
    id: root
    implicitHeight: 22
    implicitWidth: Math.min(380, titleText.implicitWidth)

    Text {
        id: titleText
        anchors.centerIn: parent
        width: Math.min(380, implicitWidth)
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        color: Colors.on_surface_variant
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontNormal
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter

        Behavior on color { ColorAnimation { duration: Appearance.animDurationNormal } }
    }
}
