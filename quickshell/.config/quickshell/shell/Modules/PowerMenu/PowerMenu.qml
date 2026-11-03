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
    property string confirmAction: "" // "", "logout", "reboot", "poweroff"

    onVisibleChanged: {
        if (visible) {
            root.confirmAction = "";
            root.focusedIndex = 3;
            dialogCard.forceActiveFocus();
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
            onClicked: {
                root.confirmAction = "";
                Power.menuOpen = false;
            }
        }
    }

    // Modal Card
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: 480
        height: 240
        radius: Appearance.radiusLarge
        color: Colors.surface_container
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.40)
        border.width: 1
        clip: true

        focus: true

        Keys.onEscapePressed: (event) => {
            if (root.confirmAction !== "") {
                root.confirmAction = "";
            } else {
                Power.menuOpen = false;
            }
            event.accepted = true;
        }

        Keys.onLeftPressed: (event) => {
            if (root.confirmAction === "") {
                root.focusedIndex = (root.focusedIndex + 3) % 4;
            }
            event.accepted = true;
        }

        Keys.onRightPressed: (event) => {
            if (root.confirmAction === "") {
                root.focusedIndex = (root.focusedIndex + 1) % 4;
            }
            event.accepted = true;
        }

        Keys.onUpPressed: (event) => {
            if (root.confirmAction === "") {
                root.focusedIndex = (root.focusedIndex + 3) % 4;
            }
            event.accepted = true;
        }

        Keys.onDownPressed: (event) => {
            if (root.confirmAction === "") {
                root.focusedIndex = (root.focusedIndex + 1) % 4;
            }
            event.accepted = true;
        }

        Keys.onReturnPressed: (event) => {
            if (root.confirmAction !== "") {
                root.executeConfirmedAction();
            } else {
                root.triggerIndex(root.focusedIndex);
            }
            event.accepted = true;
        }

        Keys.onPressed: (event) => {
            if (root.confirmAction === "") {
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
        }

        function triggerIndex(idx) {
            if (idx === 0) {
                root.confirmAction = "logout";
            } else if (idx === 1) {
                Power.suspend();
            } else if (idx === 2) {
                root.confirmAction = "reboot";
            } else if (idx === 3) {
                root.confirmAction = "poweroff";
            }
        }

        function executeConfirmedAction() {
            if (root.confirmAction === "logout") {
                Power.logout();
            } else if (root.confirmAction === "reboot") {
                Power.reboot();
            } else if (root.confirmAction === "poweroff") {
                Power.poweroff();
            }
            root.confirmAction = "";
        }

        // Prevent clicking inside the card from closing
        MouseArea {
            anchors.fill: parent
        }

        // ── 1. MAIN SELECTION VIEW ──────────────────────────────────────
        Column {
            anchors.fill: parent
            anchors.margins: Appearance.spacingLarge
            spacing: Appearance.spacingLarge
            visible: root.confirmAction === ""

            Row {
                width: parent.width
                spacing: Appearance.spacingSmall

                Icon {
                    name: "󰐥"
                    size: Appearance.iconMedium
                    color: Colors.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Power Menu"
                    color: Colors.on_surface
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontLarge
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 4 Action Tiles
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Appearance.spacingMedium

                // Tile 0: Log Out
                Rectangle {
                    id: tileLogout
                    width: 95
                    height: 110
                    radius: Appearance.radiusMedium
                    color: (root.focusedIndex === 0 || hover0.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                    border.color: root.focusedIndex === 0 ? Colors.primary : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "󰍃"
                            size: 32
                            color: hover0.containsMouse || root.focusedIndex === 0 ? Colors.primary : Colors.on_surface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Log Out"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: root.focusedIndex === 0
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "1"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: hover0
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusedIndex = 0;
                            root.confirmAction = "logout";
                        }
                    }
                }

                // Tile 1: Suspend
                Rectangle {
                    id: tileSuspend
                    width: 95
                    height: 110
                    radius: Appearance.radiusMedium
                    color: (root.focusedIndex === 1 || hover1.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                    border.color: root.focusedIndex === 1 ? Colors.primary : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "󰒲"
                            size: 32
                            color: hover1.containsMouse || root.focusedIndex === 1 ? Colors.primary : Colors.on_surface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Suspend"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: root.focusedIndex === 1
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "2"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: hover1
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusedIndex = 1;
                            Power.suspend();
                        }
                    }
                }

                // Tile 2: Reboot
                Rectangle {
                    id: tileReboot
                    width: 95
                    height: 110
                    radius: Appearance.radiusMedium
                    color: (root.focusedIndex === 2 || hover2.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                    border.color: root.focusedIndex === 2 ? Colors.primary : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "󰜉"
                            size: 32
                            color: hover2.containsMouse || root.focusedIndex === 2 ? Colors.primary : Colors.on_surface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Restart"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: root.focusedIndex === 2
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "3"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: hover2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusedIndex = 2;
                            root.confirmAction = "reboot";
                        }
                    }
                }

                // Tile 3: Shut Down
                Rectangle {
                    id: tilePoweroff
                    width: 95
                    height: 110
                    radius: Appearance.radiusMedium
                    color: (root.focusedIndex === 3 || hover3.containsMouse) ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.4)
                    border.color: root.focusedIndex === 3 ? Colors.error : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "󰐥"
                            size: 32
                            color: hover3.containsMouse || root.focusedIndex === 3 ? Colors.error : Colors.on_surface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Shut Down"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: root.focusedIndex === 3
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "4"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: hover3
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusedIndex = 3;
                            root.confirmAction = "poweroff";
                        }
                    }
                }
            }
        }

        // ── 2. CONFIRMATION VIEW (DESTRUCTIVE ACTIONS) ───────────────────
        Column {
            anchors.centerIn: parent
            spacing: Appearance.spacingLarge
            visible: root.confirmAction !== ""

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (root.confirmAction === "poweroff") return "Shut Down the system?";
                        if (root.confirmAction === "reboot") return "Restart the system?";
                        if (root.confirmAction === "logout") return "Log out of session?";
                        return "Are you sure?";
                    }
                    color: Colors.on_surface
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontLarge
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Unsaved work will be lost."
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Appearance.spacingMedium

                // Confirm button
                Rectangle {
                    width: 130
                    height: 38
                    radius: Appearance.radiusSmall
                    color: confirmBtnHover.containsMouse ? Colors.error : Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.85)

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (root.confirmAction === "poweroff") return "Shut Down";
                            if (root.confirmAction === "reboot") return "Restart";
                            if (root.confirmAction === "logout") return "Log Out";
                            return "Confirm";
                        }
                        color: Colors.on_error
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmBtnHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.executeConfirmedAction()
                    }
                }

                // Cancel button
                Rectangle {
                    width: 100
                    height: 38
                    radius: Appearance.radiusSmall
                    color: cancelBtnHover.containsMouse ? Colors.surface_container_highest : Colors.surface_container_high
                    border.color: Colors.outline_variant
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                    }

                    MouseArea {
                        id: cancelBtnHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.confirmAction = ""
                    }
                }
            }
        }
    }
}
