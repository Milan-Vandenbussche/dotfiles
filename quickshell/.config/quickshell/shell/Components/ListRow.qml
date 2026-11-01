import QtQuick
import "../Theme"

Rectangle {
    id: root
    signal clicked()

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    readonly property bool hovered: mouseArea.containsMouse

    implicitWidth: 200
    implicitHeight: subtitle !== "" ? 42 : 30
    radius: Appearance.radiusSmall
    color: hovered ? Colors.surface_container_high : "transparent"

    Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Appearance.spacingMedium
        anchors.rightMargin: Appearance.spacingMedium
        spacing: Appearance.spacingMedium

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: Appearance.iconMedium
            color: root.hovered ? Colors.primary : Colors.on_surface
            visible: root.icon !== ""
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: root.title
                color: Colors.on_surface
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontNormal
            }

            Text {
                text: root.subtitle
                color: Colors.on_surface_variant
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSmall
                visible: root.subtitle !== ""
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
