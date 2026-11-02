import QtQuick
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

    visible: Audio.panelOpen && root.parentWindow !== null
    color: "transparent"

    implicitWidth: 320
    implicitHeight: card.implicitHeight

    Shortcut {
        enabled: Audio.panelOpen
        sequence: "Escape"
        onActivated: Audio.panelOpen = false
    }

    Timer {
        id: leaveTimer
        interval: 450
        repeat: false
        onTriggered: Audio.panelOpen = false
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
                } else if (Audio.panelOpen) {
                    leaveTimer.restart();
                }
            }
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Appearance.spacingMedium
            spacing: Appearance.spacingMedium

            // ── 1. OUTPUT (SINK) ─────────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                // Output header: icon + name + mute button
                Row {
                    width: parent.width
                    spacing: Appearance.spacingSmall

                    Icon {
                        name: Audio.muted ? "󰝟" : "󰕾"
                        size: Appearance.iconMedium
                        color: Audio.muted ? Colors.error : Colors.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        width: parent.width - 60
                        text: Audio.defaultSink ? (Audio.defaultSink.description || Audio.defaultSink.name || "Output") : "Speaker"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        implicitWidth: 26
                        implicitHeight: 26
                        radius: Appearance.radiusSmall
                        color: outMuteHover.containsMouse ? Colors.surface_container_high : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Icon {
                            anchors.centerIn: parent
                            name: Audio.muted ? "󰝟" : "󰕾"
                            size: Appearance.iconSmall
                            color: Audio.muted ? Colors.error : Colors.on_surface_variant
                        }

                        MouseArea {
                            id: outMuteHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Audio.toggleMute()
                        }
                    }
                }

                // Volume slider & percentage
                Row {
                    width: parent.width
                    spacing: Appearance.spacingSmall

                    Slider {
                        width: parent.width - 44
                        anchors.verticalCenter: parent.verticalCenter
                        value: Audio.volume
                        onValueMoved: (val) => Audio.setVolume(val)
                    }

                    Text {
                        width: 36
                        text: Math.round(Audio.volume * 100) + "%"
                        color: Audio.muted ? Colors.on_surface_variant : Colors.primary
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Output Device Selector
                Column {
                    width: parent.width
                    spacing: 2
                    visible: Audio.sinks && Audio.sinks.length > 1

                    Repeater {
                        model: Audio.sinks

                        delegate: Rectangle {
                            id: sinkRow
                            required property var modelData
                            width: parent.width
                            implicitHeight: 24
                            radius: Appearance.radiusSmall
                            readonly property bool isSelected: modelData && Audio.defaultSink && (modelData.id === Audio.defaultSink.id)
                            color: sinkHover.containsMouse ? Colors.surface_container_high : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Appearance.spacingSmall
                                anchors.rightMargin: Appearance.spacingSmall
                                spacing: 6

                                Icon {
                                    name: sinkRow.isSelected ? "󰄬" : " "
                                    size: Appearance.iconSmall
                                    color: Colors.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width - 24
                                    text: sinkRow.modelData.description || sinkRow.modelData.name || "Device"
                                    color: sinkRow.isSelected ? Colors.primary : Colors.on_surface_variant
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSmall
                                    font.bold: sinkRow.isSelected
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: sinkHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Audio.setDefaultSink(sinkRow.modelData.id)
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

            // ── 2. INPUT (MICROPHONE) ────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                // Mic header: icon + name + mute button
                Row {
                    width: parent.width
                    spacing: Appearance.spacingSmall

                    Icon {
                        name: Audio.micMuted ? "󰍭" : "󰍬"
                        size: Appearance.iconMedium
                        color: Audio.micMuted ? Colors.error : Colors.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        width: parent.width - 60
                        text: Audio.defaultSource ? (Audio.defaultSource.description || Audio.defaultSource.name || "Microphone") : "Microphone"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: true
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        implicitWidth: 26
                        implicitHeight: 26
                        radius: Appearance.radiusSmall
                        color: micMuteHover.containsMouse ? Colors.surface_container_high : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Icon {
                            anchors.centerIn: parent
                            name: Audio.micMuted ? "󰍭" : "󰍬"
                            size: Appearance.iconSmall
                            color: Audio.micMuted ? Colors.error : Colors.on_surface_variant
                        }

                        MouseArea {
                            id: micMuteHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Audio.toggleMicMute()
                        }
                    }
                }

                // Mic volume slider & percentage
                Row {
                    width: parent.width
                    spacing: Appearance.spacingSmall

                    Slider {
                        width: parent.width - 44
                        anchors.verticalCenter: parent.verticalCenter
                        value: Audio.micVolume
                        onValueMoved: (val) => Audio.setMicVolume(val)
                    }

                    Text {
                        width: 36
                        text: Math.round(Audio.micVolume * 100) + "%"
                        color: Audio.micMuted ? Colors.on_surface_variant : Colors.primary
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── 3. APPLICATIONS (PER-APP STREAMS) ────────────────────────
            Column {
                width: parent.width
                spacing: 6
                visible: Audio.streams && Audio.streams.length > 0

                // Divider line
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
                }

                Text {
                    text: "Application Audio"
                    color: Colors.on_surface_variant
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                    font.bold: true
                }

                Repeater {
                    model: Audio.streams

                    delegate: Column {
                        id: appStreamCol
                        required property var modelData
                        width: parent.width
                        spacing: 4

                        Row {
                            width: parent.width
                            spacing: Appearance.spacingSmall

                            Icon {
                                name: "󰝚"
                                size: Appearance.iconSmall
                                color: Colors.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: parent.width - 60
                                text: appStreamCol.modelData.description || appStreamCol.modelData.name || "App"
                                color: Colors.on_surface
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                implicitWidth: 22
                                implicitHeight: 22
                                radius: Appearance.radiusSmall
                                color: appMuteHover.containsMouse ? Colors.surface_container_high : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Icon {
                                    anchors.centerIn: parent
                                    name: (appStreamCol.modelData.audio && appStreamCol.modelData.audio.muted) ? "󰝟" : "󰕾"
                                    size: Appearance.iconSmall
                                    color: (appStreamCol.modelData.audio && appStreamCol.modelData.audio.muted) ? Colors.error : Colors.on_surface_variant
                                }

                                MouseArea {
                                    id: appMuteHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Audio.toggleNodeMute(appStreamCol.modelData)
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Appearance.spacingSmall

                            Slider {
                                width: parent.width - 44
                                anchors.verticalCenter: parent.verticalCenter
                                value: appStreamCol.modelData.audio ? appStreamCol.modelData.audio.volume : 1.0
                                onValueMoved: (val) => Audio.setNodeVolume(appStreamCol.modelData, val)
                            }

                            Text {
                                width: 36
                                text: Math.round((appStreamCol.modelData.audio ? appStreamCol.modelData.audio.volume : 1.0) * 100) + "%"
                                color: Colors.primary
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
