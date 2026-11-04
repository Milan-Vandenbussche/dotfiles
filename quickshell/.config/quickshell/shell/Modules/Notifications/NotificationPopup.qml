import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root

    required property var targetScreen
    screen: targetScreen

    WlrLayershell.namespace: "qs-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }
    margins {
        top: 36
        right: 16
    }

    implicitWidth: 340
    implicitHeight: popupCol.implicitHeight
    color: "transparent"

    visible: Notifications.popups.length > 0

    Column {
        id: popupCol
        width: 340
        spacing: Appearance.spacingSmall

        Repeater {
            model: Notifications.popups

            delegate: Rectangle {
                id: notifCard
                required property var modelData
                required property int index

                width: 340
                implicitHeight: cardContent.implicitHeight + Appearance.spacingMedium * 2
                radius: Appearance.radiusMedium
                color: cardClick.containsMouse ? Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.98) : Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.95)
                border.color: cardClick.containsMouse ? Colors.primary : (modelData.isCritical ? Colors.error : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.40))
                border.width: modelData.isCritical || cardClick.containsMouse ? 2 : 1
                clip: true

                // Clickable whole-card mouse area
                MouseArea {
                    id: cardClick
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.openNotification(notifCard.modelData, notifCard.modelData.internalId)
                }

                // Auto-dismiss timer (paused on hover)
                Timer {
                    id: dismissTimer
                    interval: notifCard.modelData.timeout
                    running: !cardClick.containsMouse && !notifCard.modelData.isCritical
                    repeat: false
                    onTriggered: Notifications.dismissPopup(notifCard.modelData.internalId)
                }

                Column {
                    id: cardContent
                    anchors.fill: parent
                    anchors.margins: Appearance.spacingMedium
                    spacing: Appearance.spacingSmall

                    // ── 1. HEADER (ICON, APP NAME, TIME, CLOSE BUTTON) ──
                    Item {
                        width: parent.width
                        height: 20

                        Row {
                            anchors.left: parent.left
                            anchors.right: closeBtn.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacingSmall

                            Item {
                                width: 18
                                height: 18
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    source: notifCard.modelData.appIcon ? Quickshell.iconPath(notifCard.modelData.appIcon, 18) : ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: status === Image.Ready
                                }

                                Icon {
                                    anchors.centerIn: parent
                                    name: notifCard.modelData.isCritical ? "󰅚" : "󰂚"
                                    size: 16
                                    color: notifCard.modelData.isCritical ? Colors.error : Colors.primary
                                    visible: !notifCard.modelData.appIcon || parent.children[0].status !== Image.Ready
                                }
                            }

                            Text {
                                text: notifCard.modelData.appName
                                color: Colors.on_surface_variant
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                font.bold: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "• " + notifCard.modelData.time
                                color: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.7)
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Close Button securely anchored to right
                        Rectangle {
                            id: closeBtn
                            z: 2
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: closeHover.containsMouse ? Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15) : "transparent"

                            Icon {
                                anchors.centerIn: parent
                                name: "󰅖"
                                size: 11
                                color: Colors.on_surface_variant
                            }

                            MouseArea {
                                id: closeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.dismissPopup(notifCard.modelData.internalId)
                            }
                        }
                    }

                    // ── 2. SUMMARY (TITLE) ──────────────────────────────
                    Text {
                        width: parent.width
                        text: notifCard.modelData.summary
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }

                    // ── 3. BODY (TEXT CONTENT) ──────────────────────────
                    Text {
                        width: parent.width
                        text: notifCard.modelData.body
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        wrapMode: Text.Wrap
                        textFormat: Text.StyledText
                        visible: text.length > 0
                        maximumLineCount: 4
                        elide: Text.ElideRight
                    }

                    // ── 4. ACTIONS (IF PRESENT) ─────────────────────────
                    Row {
                        width: parent.width
                        spacing: Appearance.spacingSmall
                        visible: notifCard.modelData.actions.length > 0

                        Repeater {
                            model: notifCard.modelData.actions

                            delegate: Rectangle {
                                required property var modelData
                                z: 2
                                implicitWidth: Math.max(60, actionText.implicitWidth + 16)
                                implicitHeight: 26
                                radius: Appearance.radiusSmall
                                color: actHover.containsMouse ? Colors.primary : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15)
                                border.color: Colors.primary
                                border.width: 1

                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    text: modelData.text || modelData.identifier || "Action"
                                    color: actHover.containsMouse ? Colors.on_primary : Colors.primary
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSmall
                                    font.bold: true
                                }

                                MouseArea {
                                    id: actHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Notifications.invokeAction(modelData, notifCard.modelData.internalId)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
