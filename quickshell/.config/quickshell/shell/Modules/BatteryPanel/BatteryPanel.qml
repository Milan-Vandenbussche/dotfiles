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

    visible: Power.batteryPanelOpen && root.parentWindow !== null
    color: "transparent"

    implicitWidth: 300
    implicitHeight: card.implicitHeight

    Timer {
        id: leaveTimer
        interval: 400
        repeat: false
        onTriggered: Power.batteryPanelOpen = false
    }

    onVisibleChanged: {
        if (visible) {
            leaveTimer.stop();
            Power.queryProfile();
        }
    }

    function cancelLeave() {
        leaveTimer.stop();
    }

    function startLeave() {
        leaveTimer.restart();
    }

    readonly property string batIcon: {
        const p = Power.batteryPercentage;
        if (Power.isCharging) {
            if (p > 90) return "󰂅";
            if (p > 80) return "󰂋";
            if (p > 70) return "󰂊";
            if (p > 60) return "󰢝";
            if (p > 50) return "󰂉";
            if (p > 40) return "󰂈";
            if (p > 30) return "󰂇";
            if (p > 20) return "󰂆";
            return "󰢜";
        } else {
            if (p > 90) return "󰁹";
            if (p > 80) return "󰂂";
            if (p > 70) return "󰂁";
            if (p > 60) return "󰂀";
            if (p > 50) return "󰁿";
            if (p > 40) return "󰁾";
            if (p > 30) return "󰁽";
            if (p > 20) return "󰁼";
            if (p > 10) return "󰁻";
            return "󰁺";
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
                } else if (Power.batteryPanelOpen) {
                    leaveTimer.restart();
                }
            }
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Appearance.spacingMedium
            spacing: Appearance.spacingMedium

            // ── 1. HEADER (BATTERY % + REMAINING TIME + STATUS BADGE) ──
            Row {
                width: parent.width
                spacing: Appearance.spacingSmall

                // Big battery icon
                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        anchors.centerIn: parent
                        name: root.batIcon
                        size: Appearance.iconLarge + 4
                        color: Power.batteryPercentage <= 20 && !Power.isCharging ? Colors.error : Colors.primary
                    }
                }

                // Battery details
                Column {
                    width: parent.width - 32 - badgeRect.width - Appearance.spacingSmall * 2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Row {
                        spacing: 6
                        Text {
                            text: Power.batteryPercentage + "%"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontTitle
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: Power.isCharging ? "Charging" : (Power.batteryStatus === "Full" ? "Full" : "Battery")
                            color: Colors.primary
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        width: parent.width
                        text: Power.timeRemainingText
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        elide: Text.ElideRight
                    }
                }

                // Power state badge
                Rectangle {
                    id: badgeRect
                    implicitWidth: badgeRow.implicitWidth + 12
                    implicitHeight: 22
                    radius: 11
                    anchors.verticalCenter: parent.verticalCenter
                    color: Power.isCharging || Power.batteryStatus === "Full"
                        ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15)
                        : Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.20)
                    border.color: Power.isCharging || Power.batteryStatus === "Full" ? Colors.primary : "transparent"
                    border.width: 1

                    Row {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: Power.isCharging ? "󰂄" : (Power.batteryStatus === "Full" ? "󱐋" : "󰁹")
                            size: 11
                            color: Power.isCharging || Power.batteryStatus === "Full" ? Colors.primary : Colors.on_surface_variant
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Power.isCharging ? "AC" : (Power.batteryStatus === "Full" ? "AC" : "BAT")
                            color: Power.isCharging || Power.batteryStatus === "Full" ? Colors.primary : Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // ── 2. POWER PROFILE OPTIONS ────────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "POWER PROFILE"
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall - 1
                    font.bold: true
                }

                Repeater {
                    model: [
                        {
                            id: "power-saver",
                            name: "Battery Saver",
                            desc: "Maximum battery life",
                            icon: "󰌪"
                        },
                        {
                            id: "balanced",
                            name: "Balanced",
                            desc: "Standard balance",
                            icon: "󰾅"
                        },
                        {
                            id: "performance",
                            name: "Performance",
                            desc: "Maximum power & speed",
                            icon: "󰓅"
                        }
                    ]

                    delegate: Rectangle {
                        id: profBtn
                        required property var modelData
                        width: parent.width
                        implicitHeight: 40
                        radius: Appearance.radiusSmall

                        readonly property bool isActive: Power.currentProfile === modelData.id

                        color: isActive
                            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.20)
                            : (btnHover.containsMouse ? Colors.surface_container_high : "transparent")

                        border.color: isActive
                            ? Colors.primary
                            : (btnHover.containsMouse ? Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.4) : "transparent")
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

                        Row {
                            anchors.left: parent.left
                            anchors.right: checkIcon.left
                            anchors.leftMargin: 10
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacingSmall

                            Icon {
                                name: modelData.icon
                                size: Appearance.iconMedium
                                color: profBtn.isActive ? Colors.primary : Colors.on_surface_variant
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    text: modelData.name
                                    color: profBtn.isActive ? Colors.primary : Colors.on_surface
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSmall
                                    font.bold: profBtn.isActive
                                }

                                Text {
                                    text: modelData.desc
                                    color: Colors.on_surface_variant
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 9
                                }
                            }
                        }

                        Icon {
                            id: checkIcon
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            name: "󰄬"
                            size: 14
                            color: Colors.primary
                            visible: profBtn.isActive
                        }

                        MouseArea {
                            id: btnHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Power.setProfile(modelData.id)
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // ── 3. SCREEN BRIGHTNESS ────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                Item {
                    width: parent.width
                    height: 16
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "BRIGHTNESS"
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall - 1
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: Power.brightnessPercentage + "%"
                        color: Colors.primary
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: true
                    }
                }

                Row {
                    width: parent.width
                    spacing: Appearance.spacingSmall

                    Icon {
                        name: "󰃠"
                        size: Appearance.iconSmall
                        color: Colors.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Slider {
                        width: parent.width - 24
                        anchors.verticalCenter: parent.verticalCenter
                        value: Power.brightnessPercentage / 100.0
                        onValueMoved: (newVal) => Power.setBrightness(Math.round(newVal * 100))
                    }
                }
            }
        }
    }
}
