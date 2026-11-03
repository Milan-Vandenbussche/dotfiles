import QtQuick
import Quickshell
import "../../Theme"
import "../../Services"
import "../../Components"

Item {
    id: root

    property alias buttonItem: powerBtn
    property var parentWindow: null

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        id: powerBtn
        anchors.fill: parent
        radius: Appearance.radiusSmall
        color: Power.menuOpen ? Colors.surface_container_high : (mouseArea.containsMouse ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.15) : "transparent")

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        Icon {
            anchors.centerIn: parent
            name: "⏻"
            size: Appearance.iconSmall
            color: mouseArea.containsMouse || Power.menuOpen ? Colors.error : Colors.primary

            Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Power.toggleMenu()
        }
    }
}
