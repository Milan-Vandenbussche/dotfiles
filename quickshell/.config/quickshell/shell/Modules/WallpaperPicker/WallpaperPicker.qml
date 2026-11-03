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
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    Component.onCompleted: {
        grid.forceActiveFocus();
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

        focus: true
        Keys.onEscapePressed: (event) => {
            Wallpaper.pickerOpen = false;
            event.accepted = true;
        }

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

            Keys.onEscapePressed: (event) => {
                Wallpaper.pickerOpen = false;
                event.accepted = true;
            }
            Keys.onReturnPressed: (event) => {
                if (grid.currentIndex >= 0 && grid.currentIndex < Wallpaper.wallpapers.length) {
                    Wallpaper.apply(Wallpaper.wallpapers[grid.currentIndex]);
                }
                event.accepted = true;
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
                    border.color: cellItem.isCurrent ? Colors.primary : (thumbHover.containsMouse ? Colors.outline_variant : "transparent")
                    border.width: cellItem.isCurrent ? 2 : 1

                    Behavior on border.color { ColorAnimation { duration: Appearance.animDurationFast } }

                    Image {
                        id: thumb
                        anchors.fill: parent
                        anchors.margins: 4
                        source: cellItem.modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 320
                        sourceSize.height: 200

                        Rectangle {
                            anchors.fill: parent
                            color: Colors.surface_container_highest
                            visible: thumb.status === Image.Loading

                            Text {
                                anchors.centerIn: parent
                                text: "󰸉"
                                color: Colors.on_surface_variant
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.iconMedium
                            }
                        }
                    }

                    // Active checkmark badge
                    Rectangle {
                        visible: cellItem.isCurrent
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: 24
                        height: 24
                        radius: 12
                        color: Colors.primary

                        Icon {
                            anchors.centerIn: parent
                            name: "󰄬"
                            size: 14
                            color: Colors.on_primary
                        }
                    }

                    MouseArea {
                        id: thumbHover
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

        // ── BOTTOM BAR (MINIMAL SHUFFLE BUTTON ONLY) ──────────────────────
        Item {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52

            Rectangle {
                id: shuffleBtn
                anchors.centerIn: parent
                width: 44
                height: 44
                radius: 22
                color: shuffleHover.containsMouse ? Colors.primary : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15)
                border.color: Colors.primary
                border.width: 1

                Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

                Icon {
                    anchors.centerIn: parent
                    name: "󰒝"
                    size: 20
                    color: shuffleHover.containsMouse ? Colors.on_primary : Colors.primary
                }

                MouseArea {
                    id: shuffleHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpaper.shuffle()
                }
            }
        }
    }
}
