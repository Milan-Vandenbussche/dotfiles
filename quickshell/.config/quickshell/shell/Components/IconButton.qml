import QtQuick
import "../Theme"

Rectangle {
    id: root
    signal clicked(var mouse)

    property string icon: ""
    property int iconSize: Appearance.iconSmall
    property color iconColor: hovered ? Colors.primary : Colors.on_surface
    property string tooltipText: ""
    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    implicitWidth: 26
    implicitHeight: 26
    radius: Appearance.radiusSmall
    color: pressed ? Colors.surface_container_high : (hovered ? Colors.surface_container : "transparent")

    Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.iconColor

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => root.clicked(mouse)
    }
}
