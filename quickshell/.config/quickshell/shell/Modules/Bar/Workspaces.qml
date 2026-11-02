import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../Theme"

Row {
    id: root
    spacing: Appearance.spacingMedium
    anchors.verticalCenter: parent.verticalCenter

    required property var screen

    Repeater {
        model: Hyprland.workspaces ? Hyprland.workspaces.values : []

        delegate: Item {
            id: wsItem
            required property var modelData

            // Filter workspaces by monitor on multi-monitor setups
            readonly property bool matchesScreen: {
                if (!root.screen || !modelData || !modelData.monitor) return true;
                return modelData.monitor.name === root.screen.name;
            }

            // Visible only if on this monitor AND (is currently active OR has windows open)
            readonly property bool isOccupied: modelData && modelData.toplevels && modelData.toplevels.values && modelData.toplevels.values.length > 0
            readonly property bool isFocused: modelData ? modelData.focused : false

            visible: matchesScreen && (isFocused || isOccupied)
            width: visible ? 16 : 0
            height: visible ? 20 : 0

            Rectangle {
                anchors.centerIn: parent
                width: wsItem.isFocused ? 10 : 8
                height: width
                radius: width / 2

                // Active = solid primary dot, Occupied = outline ring with surface fill
                color: wsItem.isFocused ? Colors.primary : "transparent"
                border.color: wsItem.isFocused ? Colors.primary : Colors.on_surface_variant
                border.width: wsItem.isFocused ? 0 : 1.5

                Behavior on width { NumberAnimation { duration: Appearance.animDurationFast; easing.type: Appearance.animEasing } }
                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsItem.modelData) {
                        wsItem.modelData.activate();
                    }
                }
            }
        }
    }
}
