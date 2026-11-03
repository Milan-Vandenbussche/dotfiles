import QtQuick
import Quickshell
import "../../Theme"
import "../../Services"
import "../../Components"
import "../Notifications"

Item {
    id: root

    property var parentWindow: null

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        id: bellBtn
        anchors.fill: parent
        radius: Appearance.radiusSmall
        color: Notifications.panelOpen ? Colors.surface_container_high : (mouseArea.containsMouse ? Colors.surface_container_high : "transparent")

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        Icon {
            anchors.centerIn: parent
            name: Notifications.dnd ? "󰂛" : (Notifications.unreadCount > 0 ? "󰂚" : "󰂚")
            size: Appearance.iconSmall
            color: Notifications.dnd ? Colors.error : (Notifications.unreadCount > 0 ? Colors.primary : Colors.on_surface_variant)

            Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
        }

        // Unread badge dot
        Rectangle {
            visible: Notifications.unreadCount > 0 && !Notifications.dnd
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            width: 6
            height: 6
            radius: 3
            color: Colors.primary
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Notifications.toggleDnd();
                } else {
                    Notifications.togglePanel();
                }
            }
        }
    }

    // Anchored Notification History Popup
    NotificationHistoryPanel {
        parentWindow: root.parentWindow
        anchorItem: bellBtn
    }
}
