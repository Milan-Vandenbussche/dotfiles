import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Wallpaper.pickerOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: Wallpaper.pickerOpen

    onVisibleChanged: {
        if (visible) {
            grid.forceActiveFocus();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Escape shortcut that reliably fires on the very first press
    Shortcut {
        enabled: Wallpaper.pickerOpen
        sequence: "Escape"
        onActivated: Wallpaper.pickerOpen = false
    }

    // Dim backdrop (clicking outside closes the picker)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)

        MouseArea {
            anchors.fill: parent
            onClicked: Wallpaper.pickerOpen = false
        }
    }

    // Main Modal Card (opaque dark glass, no background blur)
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: Math.min(880, parent.width - 48)
        height: Math.min(620, parent.height - 48)
        radius: Appearance.radiusLarge
        color: Colors.surface_container
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.40)
        border.width: 1
        clip: true

        // Prevent clicking inside the card from closing the dialog
        MouseArea {
            anchors.fill: parent
        }

        // ── SCROLLABLE THUMBNAIL GRID ────────────────────────────────────
        GridView {
            id: grid
            anchors.top: parent.top
            anchors.topMargin: Appearance.spacingLarge
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
            boundsBehavior: Flickable.StopAtBounds

            model: Wallpaper.wallpapers

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                policy: ScrollBar.AsNeeded
                active: grid.moving || grid.flicking
                width: 6

                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: scrollBar.pressed ? Colors.primary : Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.4)
                }
            }

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

                    // Thumbnail image
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

                    // Bottom file name label
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

        // ── BOTTOM BAR (Shuffle Icon Button Only) ────────────────────────
        Item {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48

            // Subtle pulsing busy line when a theme is actively applying
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
                    NumberAnimation { from: 0.3; to: 1.0; duration: 400; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.3; duration: 400; easing.type: Easing.InOutSine }
                }
            }

            // Shuffle Button: Icon only, centered
            Rectangle {
                anchors.centerIn: parent
                implicitWidth: 36
                implicitHeight: 36
                radius: Appearance.radiusSmall
                color: shuffleHover.containsMouse ? Colors.surface_container_high : "transparent"
                border.color: shuffleHover.containsMouse ? Colors.primary : Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.3)
                border.width: 1

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                Icon {
                    anchors.centerIn: parent
                    name: "󰒝"
                    size: Appearance.iconLarge
                    color: shuffleHover.containsMouse ? Colors.on_surface : Colors.primary
                }

                MouseArea {
                    id: shuffleHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpaper.random()
                }
            }
        }
    }
}
