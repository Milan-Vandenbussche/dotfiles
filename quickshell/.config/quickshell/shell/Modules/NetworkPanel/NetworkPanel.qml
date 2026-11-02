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
    property string passwordTargetSsid: ""

    anchor.window: root.parentWindow
    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 6

    visible: Network.panelOpen && root.parentWindow !== null
    color: "transparent"

    implicitWidth: 320
    implicitHeight: card.implicitHeight

    Timer {
        id: leaveTimer
        interval: 450
        repeat: false
        onTriggered: Network.panelOpen = false
    }

    onVisibleChanged: {
        if (visible) {
            leaveTimer.stop();
            root.passwordTargetSsid = "";
        }
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
                } else if (Network.panelOpen) {
                    leaveTimer.restart();
                }
            }
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Appearance.spacingMedium
            spacing: Appearance.spacingMedium

            // ── 1. HEADER (ACTIVE CONNECTION & WI-FI TOGGLE) ────────────
            Row {
                width: parent.width
                spacing: Appearance.spacingSmall

                Icon {
                    name: Network.isEthernet ? "󰀂" : (Network.isConnected ? "󰤨" : "󰤮")
                    size: Appearance.iconMedium
                    color: Network.isConnected ? Colors.primary : Colors.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - 80
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        text: {
                            if (Network.isEthernet) return "Wired Connection";
                            if (Network.isWifi) return Network.activeSsid || "Wi-Fi Connected";
                            return "Disconnected";
                        }
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: Network.isConnected ? "Connected" : (Network.wifiEnabled ? "Available" : "Wi-Fi Disabled")
                        color: Network.isConnected ? Colors.primary : Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                    }
                }

                Toggle {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: Network.wifiEnabled
                    onToggled: Network.toggleWifi()
                }
            }

            // Divider line
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // ── 2. WIRED CONNECTION (IF HARDWARE EXISTS) ─────────────────
            Row {
                width: parent.width
                spacing: Appearance.spacingSmall
                visible: Network.wiredDevice !== null

                Icon {
                    name: "󰀂"
                    size: Appearance.iconMedium
                    color: Network.isEthernet ? Colors.primary : Colors.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "Ethernet"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: true
                    }

                    Text {
                        text: Network.isEthernet ? "Connected" : "Cable unplugged"
                        color: Network.isEthernet ? Colors.primary : Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                    }
                }
            }

            // ── 3. WI-FI NETWORKS LIST ───────────────────────────────────
            Column {
                width: parent.width
                spacing: 6
                visible: Network.wifiDevice !== null

                // Wi-Fi Header: title + rescan button
                Item {
                    width: parent.width
                    height: 24

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi Networks"
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: true
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: Appearance.radiusSmall
                        color: rescanHover.containsMouse ? Colors.surface_container_high : "transparent"

                        Icon {
                            anchors.centerIn: parent
                            name: "󰑐"
                            size: Appearance.iconSmall
                            color: rescanHover.containsMouse ? Colors.primary : Colors.on_surface_variant
                        }

                        MouseArea {
                            id: rescanHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Network.scan()
                        }
                    }
                }

                // If Wi-Fi is disabled
                Text {
                    visible: !Network.wifiEnabled
                    text: "Turn on Wi-Fi to see available networks"
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                }

                // If scanning / no networks found
                Text {
                    visible: Network.wifiEnabled && (!Network.networks || Network.networks.length === 0)
                    text: "Scanning for networks..."
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                }

                // Networks Scrollable List
                ListView {
                    id: netList
                    width: parent.width
                    implicitHeight: Math.min(220, count * 36 + (root.passwordTargetSsid !== "" ? 42 : 0))
                    clip: true
                    visible: Network.wifiEnabled && Network.networks && Network.networks.length > 0
                    model: Network.networks
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Column {
                        id: netDelegate
                        required property var modelData
                        width: netList.width
                        spacing: 4

                        readonly property bool isTarget: root.passwordTargetSsid === modelData.name

                        Rectangle {
                            width: parent.width
                            implicitHeight: 32
                            radius: Appearance.radiusSmall
                            color: rowHover.containsMouse ? Colors.surface_container_high : "transparent"

                            Item {
                                anchors.fill: parent
                                anchors.leftMargin: Appearance.spacingSmall
                                anchors.rightMargin: Appearance.spacingSmall

                                // Left info: icon + name + lock
                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: {
                                            const s = netDelegate.modelData.signalStrength;
                                            if (s > 0.75) return "󰤨";
                                            if (s > 0.50) return "󰤥";
                                            if (s > 0.25) return "󰤢";
                                            return "󰤟";
                                        }
                                        size: Appearance.iconSmall
                                        color: netDelegate.modelData.connected ? Colors.primary : Colors.on_surface_variant
                                    }

                                    Text {
                                        width: 140
                                        text: netDelegate.modelData.name || ""
                                        color: netDelegate.modelData.connected ? Colors.primary : Colors.on_surface
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSmall
                                        font.bold: netDelegate.modelData.connected
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: "󰌾"
                                        size: 10
                                        color: Colors.on_surface_variant
                                        visible: netDelegate.modelData.security && netDelegate.modelData.security !== 0
                                    }
                                }

                                // Right status / action
                                Row {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Rectangle {
                                        implicitHeight: 22
                                        implicitWidth: btnText.implicitWidth + 12
                                        radius: Appearance.radiusSmall
                                        color: netDelegate.modelData.connected ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.2) : (btnHover.containsMouse ? Colors.primary : Colors.surface_container_high)
                                        border.color: netDelegate.modelData.connected ? Colors.primary : "transparent"
                                        border.width: 1

                                        Text {
                                            id: btnText
                                            anchors.centerIn: parent
                                            text: netDelegate.modelData.connected ? "Connected" : (netDelegate.modelData.known ? "Connect" : "Join")
                                            color: netDelegate.modelData.connected ? Colors.primary : (btnHover.containsMouse ? Colors.on_primary : Colors.on_surface)
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: Appearance.fontSmall
                                            font.bold: netDelegate.modelData.connected
                                        }

                                        MouseArea {
                                            id: btnHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (netDelegate.modelData.connected) {
                                                    Network.disconnect(netDelegate.modelData);
                                                } else if (netDelegate.modelData.known || !netDelegate.modelData.security || netDelegate.modelData.security === 0) {
                                                    Network.connect(netDelegate.modelData, "");
                                                } else {
                                                    root.passwordTargetSsid = (root.passwordTargetSsid === netDelegate.modelData.name) ? "" : netDelegate.modelData.name;
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (netDelegate.modelData.connected) return;
                                    if (netDelegate.modelData.known || !netDelegate.modelData.security || netDelegate.modelData.security === 0) {
                                        Network.connect(netDelegate.modelData, "");
                                    } else {
                                        root.passwordTargetSsid = (root.passwordTargetSsid === netDelegate.modelData.name) ? "" : netDelegate.modelData.name;
                                    }
                                }
                            }
                        }

                        // Password Input Field
                        Rectangle {
                            visible: netDelegate.isTarget
                            width: parent.width
                            height: 34
                            radius: Appearance.radiusSmall
                            color: Colors.surface_container_high
                            border.color: Colors.primary
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 6

                                TextInput {
                                    id: passInput
                                    width: parent.width - 60
                                    anchors.verticalCenter: parent.verticalCenter
                                    echoMode: TextInput.Password
                                    color: Colors.on_surface
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSmall
                                    focus: netDelegate.isTarget

                                    Text {
                                        visible: passInput.text === "" && !passInput.activeFocus
                                        text: "Enter password..."
                                        color: Colors.on_surface_variant
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSmall
                                    }

                                    onAccepted: {
                                        Network.connect(netDelegate.modelData, passInput.text);
                                        root.passwordTargetSsid = "";
                                    }
                                }

                                Rectangle {
                                    implicitWidth: 50
                                    implicitHeight: 24
                                    radius: Appearance.radiusSmall
                                    color: Colors.primary
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Connect"
                                        color: Colors.on_primary
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSmall
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Network.connect(netDelegate.modelData, passInput.text);
                                            root.passwordTargetSsid = "";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Divider line
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // ── 4. FOOTER: ADVANCED SETTINGS (nmtui) ─────────────────────
            Rectangle {
                width: parent.width
                implicitHeight: 28
                radius: Appearance.radiusSmall
                color: advHover.containsMouse ? Colors.surface_container_high : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Icon {
                        name: "󰒓"
                        size: Appearance.iconSmall
                        color: advHover.containsMouse ? Colors.primary : Colors.on_surface_variant
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Advanced Settings (nmtui)"
                        color: advHover.containsMouse ? Colors.primary : Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: advHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.openTui()
                }
            }
        }
    }
}
