import QtQuick
import QtQuick.Controls
import Quickshell
import "../../Theme"
import "../../Services"
import "../../Components"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null

    anchor.window: root.parentWindow
    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 6

    visible: Bluetooth.panelOpen && root.parentWindow !== null
    color: "transparent"

    implicitWidth: 320
    implicitHeight: card.implicitHeight

    Timer {
        id: leaveTimer
        interval: 450
        repeat: false
        onTriggered: Bluetooth.panelOpen = false
    }

    onVisibleChanged: {
        if (visible) {
            leaveTimer.stop();
        }
    }

    function getDeviceIcon(dev) {
        if (!dev) return "󰂯";
        const icon = (dev.icon || "").toLowerCase();
        const name = (dev.name || "").toLowerCase();
        if (icon.includes("head") || icon.includes("audio") || name.includes("wh-") || name.includes("sony") || name.includes("bud") || name.includes("headphone") || name.includes("earphone")) {
            return "󰋋";
        }
        if (icon.includes("mouse") || name.includes("mouse")) {
            return "󰍽";
        }
        if (icon.includes("keyboard") || name.includes("keyboard") || name.includes("kb")) {
            return "󰌌";
        }
        if (icon.includes("gamepad") || icon.includes("gaming") || name.includes("controller")) {
            return "󰊴";
        }
        if (icon.includes("phone") || name.includes("phone")) {
            return "󰏲";
        }
        return "󰂯";
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Appearance.radiusMedium
        color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.95)
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
        border.width: 1

        implicitHeight: contentCol.implicitHeight + Appearance.spacingMedium * 2

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                if (hovered) {
                    leaveTimer.stop();
                } else if (Bluetooth.panelOpen) {
                    leaveTimer.restart();
                }
            }
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Appearance.spacingMedium
            spacing: Appearance.spacingMedium

            // ── 1. HEADER (ADAPTER STATUS & POWER TOGGLE) ───────────────
            Row {
                width: parent.width
                spacing: Appearance.spacingSmall

                Icon {
                    name: !Bluetooth.isEnabled ? "󰂲" : (Bluetooth.isConnected ? "󰂱" : "󰂯")
                    size: Appearance.iconMedium
                    color: Bluetooth.isEnabled ? Colors.primary : Colors.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - 80
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        text: {
                            if (!Bluetooth.isEnabled) return "Bluetooth Off";
                            if (Bluetooth.isConnected && Bluetooth.connectedDevice) {
                                return Bluetooth.connectedDevice.name || "Connected";
                            }
                            return "Bluetooth";
                        }
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: {
                            if (!Bluetooth.isEnabled) return "Disabled";
                            if (Bluetooth.isConnected) return "Connected";
                            if (Bluetooth.isDiscovering) return "Searching for devices...";
                            return "Ready";
                        }
                        color: Bluetooth.isConnected ? Colors.primary : Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                    }
                }

                Toggle {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: Bluetooth.isEnabled
                    onToggled: Bluetooth.togglePower()
                }
            }

            // Divider line
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // ── 2. CONTROLS (SCAN BUTTON) ───────────────────────────────
            Row {
                width: parent.width
                visible: Bluetooth.isEnabled

                Text {
                    text: "Paired Devices"
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    // Spacer
                    width: parent.width - 170
                    height: 1
                }

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 24
                    radius: Appearance.radiusSmall
                    color: scanHover.containsMouse ? Colors.surface_container_high : "transparent"
                    border.color: Bluetooth.isDiscovering ? Colors.primary : Colors.outline_variant
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            id: scanIcon
                            name: "󰑐"
                            size: 13
                            color: Bluetooth.isDiscovering ? Colors.primary : Colors.on_surface
                            anchors.verticalCenter: parent.verticalCenter

                            NumberAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: Bluetooth.isDiscovering
                            }
                        }

                        Text {
                            text: Bluetooth.isDiscovering ? "Scanning" : "Scan"
                            color: Bluetooth.isDiscovering ? Colors.primary : Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: scanHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Bluetooth.toggleDiscovery()
                    }
                }
            }

            // ── 3. SCROLLABLE DEVICES CONTAINER ──────────────────────────
            ScrollView {
                id: deviceScroll
                width: parent.width
                implicitHeight: Bluetooth.isEnabled ? Math.min(280, deviceCol.implicitHeight) : 0
                clip: true
                contentWidth: availableWidth
                visible: Bluetooth.isEnabled

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: deviceCol.implicitHeight > 280 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

                Column {
                    id: deviceCol
                    width: deviceScroll.availableWidth
                    spacing: Appearance.spacingMedium

                    // ── 3a. PAIRED DEVICES LIST ──────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: Bluetooth.pairedDevices

                            delegate: Rectangle {
                                id: pairedRow
                                required property var modelData
                                width: parent.width
                                implicitHeight: 40
                                radius: Appearance.radiusSmall
                                color: rowHover.containsMouse ? Colors.surface_container_high : "transparent"

                                readonly property bool isDevConnected: modelData.connected
                                readonly property bool hasBattery: modelData.batteryAvailable && modelData.battery >= 0

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: Appearance.spacingSmall

                                    Icon {
                                        name: root.getDeviceIcon(pairedRow.modelData)
                                        size: Appearance.iconMedium
                                        color: pairedRow.isDevConnected ? Colors.primary : Colors.on_surface_variant
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - 150
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            width: parent.width
                                            text: pairedRow.modelData.name || pairedRow.modelData.address
                                            color: Colors.on_surface
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: Appearance.fontSmall
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Row {
                                            spacing: 4
                                            Text {
                                                text: pairedRow.isDevConnected ? "Connected" : "Paired"
                                                color: pairedRow.isDevConnected ? Colors.primary : Colors.on_surface_variant
                                                font.family: Appearance.fontFamily
                                                font.pixelSize: 10
                                            }

                                            Text {
                                                visible: pairedRow.hasBattery
                                                text: "• " + (pairedRow.modelData.battery || 0) + "%"
                                                color: Colors.on_surface_variant
                                                font.family: Appearance.fontFamily
                                                font.pixelSize: 10
                                            }
                                        }
                                    }

                                    // Connect / Disconnect button
                                    Rectangle {
                                        implicitWidth: 64
                                        implicitHeight: 24
                                        radius: Appearance.radiusSmall
                                        color: pairedRow.isDevConnected ? Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.3) : Colors.primary
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: pairedRow.isDevConnected ? "Disconnect" : "Connect"
                                            color: pairedRow.isDevConnected ? Colors.on_surface : Colors.on_primary
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: connHover
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (pairedRow.isDevConnected) {
                                                    Bluetooth.disconnectDevice(pairedRow.modelData);
                                                } else {
                                                    Bluetooth.connectDevice(pairedRow.modelData);
                                                }
                                            }
                                        }
                                    }

                                    // Forget button
                                    Rectangle {
                                        implicitWidth: 24
                                        implicitHeight: 24
                                        radius: Appearance.radiusSmall
                                        color: forgetHover.containsMouse ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.2) : "transparent"
                                        anchors.verticalCenter: parent.verticalCenter

                                        Icon {
                                            anchors.centerIn: parent
                                            name: "󰅖"
                                            size: 13
                                            color: forgetHover.containsMouse ? Colors.error : Colors.on_surface_variant
                                        }

                                        MouseArea {
                                            id: forgetHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Bluetooth.forgetDevice(pairedRow.modelData)
                                        }
                                    }
                                }

                                MouseArea {
                                    id: rowHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true
                                }
                            }
                        }

                        Text {
                            visible: Bluetooth.pairedDevices.length === 0
                            text: "No paired devices"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 4
                            bottomPadding: 4
                        }
                    }

                    // ── 3b. AVAILABLE / DISCOVERED DEVICES ────────────────────────
                    Column {
                        width: parent.width
                        spacing: 4
                        visible: Bluetooth.availableDevices.length > 0 || Bluetooth.isDiscovering

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
                        }

                        Text {
                            text: "Available Devices"
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: true
                        }

                        Repeater {
                            model: Bluetooth.availableDevices

                            delegate: Rectangle {
                                id: availRow
                                required property var modelData
                                width: parent.width
                                implicitHeight: 36
                                radius: Appearance.radiusSmall
                                color: availHover.containsMouse ? Colors.surface_container_high : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: Appearance.spacingSmall

                                    Icon {
                                        name: root.getDeviceIcon(availRow.modelData)
                                        size: Appearance.iconMedium
                                        color: Colors.on_surface_variant
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width - 100
                                        text: availRow.modelData.name || availRow.modelData.address
                                        color: Colors.on_surface
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSmall
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        implicitWidth: 50
                                        implicitHeight: 22
                                        radius: Appearance.radiusSmall
                                        color: Colors.primary
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Pair"
                                            color: Colors.on_primary
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Bluetooth.pairDevice(availRow.modelData)
                                        }
                                    }
                                }

                                MouseArea {
                                    id: availHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true
                                }
                            }
                        }

                        Text {
                            visible: Bluetooth.availableDevices.length === 0 && Bluetooth.isDiscovering
                            text: "Searching for devices..."
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 4
                            bottomPadding: 4
                        }
                    }
                }
            }
        }
    }
}
