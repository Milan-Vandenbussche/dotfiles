import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Power.menuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: Power.menuOpen

    property int focusedIndex: 3 // Default focus on Shut Down (index 3)

    function triggerIndex(idx) {
        if (idx === 0) {
            Power.logout();
        } else if (idx === 1) {
            Power.suspend();
        } else if (idx === 2) {
            Power.reboot();
        } else if (idx === 3) {
            Power.poweroff();
        }
    }

    Timer {
        id: focusTimer
        interval: 30
        repeat: false
        onTriggered: dialogCard.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible) {
            root.focusedIndex = 3;
            dialogCard.forceActiveFocus();
            focusTimer.restart();
        } else {
            dialogCard.focus = false;
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Dim backdrop (clicking outside cancels / closes)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)

        MouseArea {
            anchors.fill: parent
            onClicked: Power.menuOpen = false
        }
    }

    // Modal Card
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: 460
        height: 160
        radius: Appearance.radiusLarge
        color: Colors.surface_container
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.40)
        border.width: 1
        clip: true

        focus: true

        Keys.onEscapePressed: (event) => {
            Power.menuOpen = false;
            event.accepted = true;
        }

        Keys.onLeftPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 3) % 4;
            event.accepted = true;
        }

        Keys.onRightPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 1) % 4;
            event.accepted = true;
        }

        Keys.onUpPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 3) % 4;
            event.accepted = true;
        }

        Keys.onDownPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 1) % 4;
            event.accepted = true;
        }

        Keys.onTabPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 1) % 4;
            event.accepted = true;
        }

        Keys.onBacktabPressed: (event) => {
            root.focusedIndex = (root.focusedIndex + 3) % 4;
            event.accepted = true;
        }

        Keys.onReturnPressed: (event) => {
            root.triggerIndex(root.focusedIndex);
            event.accepted = true;
        }

        Keys.onEnterPressed: (event) => {
            root.triggerIndex(root.focusedIndex);
            event.accepted = true;
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_1) {
                root.triggerIndex(0);
                event.accepted = true;
            } else if (event.key === Qt.Key_2) {
                root.triggerIndex(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_3) {
                root.triggerIndex(2);
                event.accepted = true;
            } else if (event.key === Qt.Key_4) {
                root.triggerIndex(3);
                event.accepted = true;
            }
        }

        // Prevent clicking inside the card padding from closing
        MouseArea {
            anchors.fill: parent
        }

        // 4 Action Tiles centered in dialogCard (top & bottom spacing equally large)
        Row {
            id: tilesRow
            anchors.centerIn: parent
            spacing: Appearance.spacingMedium

            // Tile 0: Log Out
            Rectangle {
                id: tileLogout
                width: 95
                height: 100
                radius: Appearance.radiusMedium
                color: (root.focusedIndex === 0 || hover0.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                border.color: root.focusedIndex === 0 ? Colors.primary : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "󰍃"
                        size: 32
                        color: hover0.containsMouse || root.focusedIndex === 0 ? Colors.primary : Colors.on_surface

                        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Log Out"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: root.focusedIndex === 0
                    }
                }

                MouseArea {
                    id: hover0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.focusedIndex = 0
                    onClicked: Power.logout()
                }
            }

            // Tile 1: Suspend
            Rectangle {
                id: tileSuspend
                width: 95
                height: 100
                radius: Appearance.radiusMedium
                color: (root.focusedIndex === 1 || hover1.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                border.color: root.focusedIndex === 1 ? Colors.primary : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "󰒲"
                        size: 32
                        color: hover1.containsMouse || root.focusedIndex === 1 ? Colors.primary : Colors.on_surface

                        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Suspend"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: root.focusedIndex === 1
                    }
                }

                MouseArea {
                    id: hover1
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.focusedIndex = 1
                    onClicked: Power.suspend()
                }
            }

            // Tile 2: Reboot
            Rectangle {
                id: tileReboot
                width: 95
                height: 100
                radius: Appearance.radiusMedium
                color: (root.focusedIndex === 2 || hover2.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                border.color: root.focusedIndex === 2 ? Colors.primary : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "󰜉"
                        size: 32
                        color: hover2.containsMouse || root.focusedIndex === 2 ? Colors.primary : Colors.on_surface

                        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Restart"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: root.focusedIndex === 2
                    }
                }

                MouseArea {
                    id: hover2
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.focusedIndex = 2
                    onClicked: Power.reboot()
                }
            }

            // Tile 3: Shut Down
            Rectangle {
                id: tilePoweroff
                width: 95
                height: 100
                radius: Appearance.radiusMedium
                color: (root.focusedIndex === 3 || hover3.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                border.color: root.focusedIndex === 3 ? Colors.error : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "󰐥"
                        size: 32
                        color: hover3.containsMouse || root.focusedIndex === 3 ? Colors.error : Colors.on_surface

                        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Shut Down"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: root.focusedIndex === 3
                    }
                }

                MouseArea {
                    id: hover3
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.focusedIndex = 3
                    onClicked: Power.poweroff()
                }
            }
        }
    }
}
