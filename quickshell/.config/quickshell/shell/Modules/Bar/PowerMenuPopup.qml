import QtQuick
import Quickshell
import "../../Theme"
import "../../Services"
import "../../Components"

Item {
    id: root

    property alias buttonItem: powerBtn
    property var parentWindow: null
    property bool menuOpen: false

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        id: powerBtn
        anchors.fill: parent
        radius: Appearance.radiusSmall
        color: root.menuOpen ? Colors.surface_container_high : (mouseArea.containsMouse ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.15) : "transparent")

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        Icon {
            anchors.centerIn: parent
            name: "⏻"
            size: Appearance.iconSmall
            color: mouseArea.containsMouse || root.menuOpen ? Colors.error : Colors.primary

            Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.menuOpen = !root.menuOpen
        }
    }

    PopupWindow {
        id: powerPopup
        visible: root.menuOpen && root.parentWindow !== null
        anchor.window: root.parentWindow
        anchor.item: powerBtn
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.margins.top: 6
        color: "transparent"

        implicitWidth: 170
        implicitHeight: menuCard.implicitHeight

        Rectangle {
            id: menuCard
            anchors.fill: parent
            radius: Appearance.radiusMedium
            color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.95)
            border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
            border.width: 1

            implicitHeight: menuColumn.implicitHeight + Appearance.spacingSmall * 2

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: Appearance.spacingSmall
                spacing: 2

                ListRow {
                    width: parent.width
                    icon: "󰌾"
                    title: "Lock"
                    onClicked: {
                        root.menuOpen = false;
                        Power.lock();
                    }
                }

                ListRow {
                    width: parent.width
                    icon: "󰒲"
                    title: "Suspend"
                    onClicked: {
                        root.menuOpen = false;
                        Power.suspend();
                    }
                }

                ListRow {
                    width: parent.width
                    icon: "󰜉"
                    title: "Restart"
                    onClicked: {
                        root.menuOpen = false;
                        Power.reboot();
                    }
                }

                ListRow {
                    width: parent.width
                    icon: "⏻"
                    title: "Shut Down"
                    onClicked: {
                        root.menuOpen = false;
                        Power.shutdown();
                    }
                }
            }
        }
    }
}
