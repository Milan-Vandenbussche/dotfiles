import QtQuick
import "../Theme"

Item {
    id: root
    property real value: 0.0 // 0.0 to 1.0
    property bool readOnly: false
    signal valueMoved(real newValue)

    implicitWidth: 120
    implicitHeight: 20

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 6
        radius: 3
        color: Colors.surface_container_high

        Rectangle {
            id: fill
            height: parent.height
            width: Math.max(0, Math.min(parent.width, parent.width * root.value))
            radius: parent.radius
            color: Colors.primary
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: !root.readOnly
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateVal(mouseX) {
            const normalized = Math.max(0.0, Math.min(1.0, mouseX / track.width));
            root.valueMoved(normalized);
        }

        onPositionChanged: (mouse) => {
            if (pressed) updateVal(mouse.x);
        }
        onPressed: (mouse) => updateVal(mouse.x)
    }
}
