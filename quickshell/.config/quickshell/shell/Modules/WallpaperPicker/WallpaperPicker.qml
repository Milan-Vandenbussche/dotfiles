import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    visible: Wallpaper.pickerOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Dim backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.60)

        MouseArea {
            anchors.fill: parent
            onClicked: Wallpaper.pickerOpen = false
        }
    }

    // Main Modal Card
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: Math.min(880, parent.width - 48)
        height: Math.min(620, parent.height - 48)
        radius: Appearance.radiusLarge
        color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.95)
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
        border.width: 1
        clip: true

        // Prevent click inside dialog from closing window
        MouseArea {
            anchors.fill: parent
        }

        // ── TOP HEADER ───────────────────────────────────────────────────
        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 54

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Appearance.spacingLarge
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacingMedium

                Icon {
                    name: "󰸉"
                    size: Appearance.iconLarge
                    color: Colors.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "Wallpaper Gallery"
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontMedium
                        font.bold: true
                    }

                    Text {
                        text: Wallpaper.wallpapers.length + " wallpapers available"
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Appearance.spacingLarge
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacingMedium

                // Shuffle / Random Button
                Rectangle {
                    implicitWidth: shuffleRow.implicitWidth + Appearance.spacingMedium * 2
                    implicitHeight: 30
                    radius: Appearance.radiusSmall
                    color: shuffleHover.containsMouse ? Colors.surface_container_high : "transparent"
                    border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.4)
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: shuffleRow
                        anchors.centerIn: parent
                        spacing: 6

                        Icon {
                            name: "󰒝"
                            size: Appearance.iconSmall
                            color: Colors.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Shuffle"
                            color: Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: shuffleHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpaper.random()
                    }
                }

                // Scheme Variant Selector
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: [
                            { name: "Tonal", id: "scheme-tonal-spot" },
                            { name: "Vibrant", id: "scheme-vibrant" },
                            { name: "Expressive", id: "scheme-expressive" }
                        ]

                        Rectangle {
                            required property var modelData
                            implicitWidth: 70
                            implicitHeight: 28
                            radius: Appearance.radiusSmall
                            color: Wallpaper.selectedScheme === modelData.id ? Colors.primary : "transparent"
                            border.color: Wallpaper.selectedScheme === modelData.id ? Colors.primary : Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.3)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                color: Wallpaper.selectedScheme === modelData.id ? Colors.on_primary : Colors.on_surface_variant
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                font.bold: Wallpaper.selectedScheme === modelData.id
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Wallpaper.selectedScheme = modelData.id;
                                    if (Wallpaper.currentWallpaper) {
                                        Wallpaper.apply(Wallpaper.currentWallpaper, Wallpaper.selectedMode, modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Close Button
                IconButton {
                    icon: "󰅖"
                    iconSize: Appearance.iconMedium
                    iconColor: Colors.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: Wallpaper.pickerOpen = false
                }
            }
        }

        // Header Divider
        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
        }

        // ── THUMBNAIL GRID ───────────────────────────────────────────────
        GridView {
            id: grid
            anchors.top: header.bottom
            anchors.topMargin: Appearance.spacingMedium
            anchors.left: parent.left
            anchors.leftMargin: Appearance.spacingLarge
            anchors.right: parent.right
            anchors.rightMargin: Appearance.spacingLarge
            anchors.bottom: footer.top
            anchors.bottomMargin: Appearance.spacingSmall

            cellWidth: 270
            cellHeight: 180
            clip: true
            focus: true

            model: Wallpaper.wallpapers

            Keys.onEscapePressed: Wallpaper.pickerOpen = false
            Keys.onReturnPressed: {
                if (grid.currentIndex >= 0 && grid.currentIndex < Wallpaper.wallpapers.length) {
                    Wallpaper.apply(Wallpaper.wallpapers[grid.currentIndex]);
                }
            }

            delegate: Item {
                id: cellItem
                required property string modelData
                required property int index

                readonly property bool isCurrent: modelData === Wallpaper.currentWallpaper
                readonly property string fileName: {
                    const parts = modelData.split("/");
                    return parts[parts.length - 1];
                }

                width: 256
                height: 168

                Rectangle {
                    id: cardBorder
                    anchors.fill: parent
                    radius: Appearance.radiusMedium
                    color: Colors.surface_container_high
                    border.color: cellItem.isCurrent ? Colors.primary : (cellMouse.containsMouse ? Colors.outline : Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.3))
                    border.width: cellItem.isCurrent ? 2 : 1
                    scale: cellMouse.containsMouse ? 1.02 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    // Wallpaper Image Thumbnail
                    Image {
                        id: thumb
                        anchors.fill: parent
                        anchors.margins: 2
                        source: "file://" + cellItem.modelData
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 320
                        sourceSize.height: 180
                        asynchronous: true
                        cache: true
                    }

                    // Bottom file name banner
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 28
                        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.85)
                        radius: Appearance.radiusSmall

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Appearance.spacingSmall
                            anchors.rightMargin: Appearance.spacingSmall
                            verticalAlignment: Text.AlignVCenter
                            text: cellItem.fileName
                            color: cellItem.isCurrent ? Colors.primary : Colors.on_surface
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSmall
                            elide: Text.ElideMiddle
                        }
                    }

                    // Active badge
                    Rectangle {
                        visible: cellItem.isCurrent
                        anchors.top: parent.top
                        anchors.topMargin: 6
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        implicitHeight: 22
                        implicitWidth: badgeRow.implicitWidth + 12
                        radius: Appearance.radiusSmall
                        color: Colors.primary

                        Row {
                            id: badgeRow
                            anchors.centerIn: parent
                            spacing: 4

                            Icon {
                                name: "󰄬"
                                size: Appearance.iconSmall
                                color: Colors.on_primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Active"
                                color: Colors.on_primary
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            grid.currentIndex = cellItem.index;
                            Wallpaper.apply(cellItem.modelData);
                        }
                    }
                }
            }
        }

        // ── FOOTER / STATUS BAR ──────────────────────────────────────────
        Item {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.25)
            }

            // Pulsing busy indicator line across footer when applying
            Rectangle {
                visible: Wallpaper.busy
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Colors.primary

                SequentialAnimation on opacity {
                    running: Wallpaper.busy
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.3; to: 1.0; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.3; duration: 500; easing.type: Easing.InOutSine }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Wallpaper.busy ? "Applying wallpaper and generating dynamic palette..." : (Wallpaper.statusMessage || "Click an image to apply • Esc to close")
                color: Wallpaper.busy ? Colors.primary : Colors.on_surface_variant
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSmall
            }
        }
    }
}
