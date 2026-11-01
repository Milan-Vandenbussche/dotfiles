import QtQuick
import "../Theme"

Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool newState)

    implicitWidth: 36
    implicitHeight: 20
    radius: height / 2
    color: checked ? Colors.primary : Colors.surface_container_high

    Behavior on color { ColorAnimation { duration: Appearance.animDurationNormal } }

    Rectangle {
        id: thumb
        width: parent.height - 4
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? (root.width - width - 2) : 2
        color: root.checked ? Colors.on_primary : Colors.on_surface_variant

        Behavior on x { NumberAnimation { duration: Appearance.animDurationFast; easing.type: Appearance.animEasing } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
