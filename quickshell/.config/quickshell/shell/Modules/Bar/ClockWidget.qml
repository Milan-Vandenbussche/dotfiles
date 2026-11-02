import QtQuick
import Quickshell
import "../../Theme"
import "../../Components"

Item {
    id: root

    implicitHeight: 24
    implicitWidth: clockText.implicitWidth + Appearance.spacingMedium * 2

    property var parentWindow: null
    property bool showCalendar: mouseArea.containsMouse || calHover.containsMouse

    Rectangle {
        anchors.fill: parent
        radius: Appearance.radiusSmall
        color: root.showCalendar ? Colors.surface_container_high : "transparent"

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: Colors.primary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontNormal
            font.bold: true
            text: Qt.formatDateTime(new Date(), "HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    // Anchored Calendar Popup
    PopupWindow {
        id: calPopup
        visible: root.showCalendar && root.parentWindow !== null
        anchor.window: root.parentWindow
        anchor.item: clockText
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 6
        implicitWidth: calCard.implicitWidth
        implicitHeight: calCard.implicitHeight
        color: "transparent"

        CalendarPopup {
            id: calCard
            anchors.fill: parent

            MouseArea {
                id: calHover
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
