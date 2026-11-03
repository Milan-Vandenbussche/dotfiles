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

    visible: Notifications.panelOpen && root.parentWindow !== null
    color: "transparent"

    implicitWidth: 340
    implicitHeight: Math.min(500, card.implicitHeight)

    Timer {
        id: leaveTimer
        interval: 450
        repeat: false
        onTriggered: Notifications.panelOpen = false
    }

    onVisibleChanged: {
        if (visible) {
            leaveTimer.stop();
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
                } else if (Notifications.panelOpen) {
                    leaveTimer.restart();
                }
            }
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Appearance.spacingMedium
            spacing: Appearance.spacingMedium

            // ── 1. HEADER (TITLE, DND TOGGLE, CLEAR ALL) ────────────────
            Row {
                width: parent.width
                spacing: Appearance.spacingSmall

                Icon {
                    name: Notifications.dnd ? "󰂛" : "󰂚"
                    size: Appearance.iconMedium
                    color: Notifications.dnd ? Colors.error : Colors.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Notifications"
                    color: Colors.on_surface
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontNormal
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // DND Pill
                Rectangle {
                    implicitWidth: 60
                    implicitHeight: 22
                    radius: 11
                    color: Notifications.dnd ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.2) : Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.2)
                    border.color: Notifications.dnd ? Colors.error : "transparent"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: Notifications.dnd ? "DND ON" : "DND"
                        color: Notifications.dnd ? Colors.error : Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.toggleDnd()
                    }
                }

                Item {
                    // Spacer
                    width: parent.width - 240
                    height: 1
                }

                // Clear All Button
                Rectangle {
                    implicitWidth: 64
                    implicitHeight: 22
                    radius: Appearance.radiusSmall
                    color: clearHover.containsMouse ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.2) : "transparent"
                    visible: Notifications.history.length > 0
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            name: "󰆴"
                            size: 11
                            color: clearHover.containsMouse ? Colors.error : Colors.on_surface_variant
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Clear"
                            color: clearHover.containsMouse ? Colors.error : Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clearHistory()
                    }
                }
            }

            // Divider line (visible only when items exist)
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
                visible: Notifications.history.length > 0
            }

            // ── 2. SCROLLABLE HISTORY LIST ───────────────────────────────
            ListView {
                id: historyList
                width: parent.width
                height: Math.min(360, count * 72)
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                visible: Notifications.history.length > 0

                model: Notifications.history

                delegate: Rectangle {
                    id: histRow
                    required property var modelData
                    width: historyList.width
                    implicitHeight: rowCol.implicitHeight + 14
                    radius: Appearance.radiusSmall
                    color: histHover.containsMouse ? Colors.surface_container_high : Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.3)
                    border.color: modelData.isCritical ? Colors.error : "transparent"
                    border.width: modelData.isCritical ? 1 : 0

                    Column {
                        id: rowCol
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        // Header with cleanly anchored remove cross
                        Item {
                            width: parent.width
                            height: 16

                            Row {
                                anchors.left: parent.left
                                anchors.right: delBtn.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Item {
                                    width: 14
                                    height: 14
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        anchors.fill: parent
                                        source: histRow.modelData.appIcon ? Quickshell.iconPath(histRow.modelData.appIcon, 14) : ""
                                        fillMode: Image.PreserveAspectFit
                                        visible: status === Image.Ready
                                    }

                                    Icon {
                                        anchors.centerIn: parent
                                        name: "󰂚"
                                        size: 12
                                        color: Colors.primary
                                        visible: !histRow.modelData.appIcon || parent.children[0].status !== Image.Ready
                                    }
                                }

                                Text {
                                    text: histRow.modelData.appName
                                    color: Colors.on_surface_variant
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "• " + histRow.modelData.time
                                    color: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.7)
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 9
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Remove item button safely anchored inside frame
                            Rectangle {
                                id: delBtn
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                height: 16
                                radius: 8
                                color: delHover.containsMouse ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.2) : "transparent"

                                Icon {
                                    anchors.centerIn: parent
                                    name: "󰅖"
                                    size: 10
                                    color: delHover.containsMouse ? Colors.error : Colors.on_surface_variant
                                }

                                MouseArea {
                                    id: delHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Notifications.removeHistory(histRow.modelData.internalId)
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: histRow.modelData.summary
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            font.bold: true
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }

                        Text {
                            width: parent.width
                            text: histRow.modelData.body
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: 11
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }

                    MouseArea {
                        id: histHover
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
