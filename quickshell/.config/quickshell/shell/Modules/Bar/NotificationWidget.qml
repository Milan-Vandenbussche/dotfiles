import QtQuick
import "../../Theme"
import "../../Components"

Rectangle {
    id: root
    signal clicked()

    property bool hasUnread: false
    property bool dnd: false

    implicitWidth: 26
    implicitHeight: 26
    radius: Appearance.radiusSmall
    color: mouseArea.containsMouse ? Colors.surface_container_high : "transparent"

    Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

    Icon {
        anchors.centerIn: parent
        name: root.dnd ? "󰂛" : (root.hasUnread ? "󰂚" : "󰂚")
        size: Appearance.iconSmall
        color: root.hasUnread ? Colors.primary : Colors.on_surface_variant

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
