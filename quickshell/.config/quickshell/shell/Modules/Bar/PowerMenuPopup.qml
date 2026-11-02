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
            color: mouseArea.containsMouse || root.menuOpen ? Colors.error : Colors.on_surface_variant

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
            color: Colors.surfaceContainer
            border.color: Colors.outline
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

                Rectangle {
                    width: parent.width - 8
                    height: 1
                    color: Colors.outline
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ListRow {
                    width: parent.width
                    icon: "⏻"
                    title: "Shut Down"
                    onClicked: {
                        root.menuOpen = false;
                        Power.poweroff();
                    }
                }
            }
        }
    }
}
