import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Launcher.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: Launcher.open

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    readonly property var currentResults: Launcher.queryLauncher(searchInput.text)

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            resultsList.currentIndex = 0;
            searchInput.forceActiveFocus();
        } else {
            searchInput.focus = false;
        }
    }

    // Dim backdrop (clicking outside closes the launcher)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)

        MouseArea {
            anchors.fill: parent
            onClicked: Launcher.open = false
        }
    }

    // Single Unified Bubble (The popup IS the textbox bubble)
    Rectangle {
        id: dialogCard
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 116 // 14px above the OSD pill (ends at 102px from bottom)
        width: 420 // Shorter compact length

        readonly property int inputHeight: 46
        readonly property int cardPadding: 6
        readonly property int contentListHeight: root.currentResults.length > 0
            ? Math.min(root.currentResults.length * 40, 240)
            : 0

        height: inputHeight + (root.currentResults.length > 0 ? (contentListHeight + 1 + cardPadding * 2) : 0)

        radius: Appearance.radiusLarge
        color: Colors.surface_container
        border.color: searchInput.activeFocus ? Colors.primary : Colors.outline_variant
        border.width: 1
        clip: true

        Behavior on height {
            NumberAnimation { duration: Appearance.animDurationFast; easing.type: Easing.OutCubic }
        }

        // Prevent clicking inside bubble from closing
        MouseArea {
            anchors.fill: parent
        }

        // ── 1. SCROLLABLE RESULTS LIST (Top of bubble when active) ────
        ListView {
            id: resultsList
            anchors.top: parent.top
            anchors.bottom: divider.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: dialogCard.cardPadding
            visible: root.currentResults.length > 0
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds

            model: root.currentResults

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                policy: ScrollBar.AsNeeded
                active: resultsList.moving || resultsList.flicking
                width: 5

                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: 2
                    color: scrollBar.pressed ? Colors.primary : Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.4)
                }
            }

            delegate: Rectangle {
                id: rowCard
                required property var modelData
                required property int index

                readonly property bool isSelected: resultsList.currentIndex === index

                width: resultsList.width - (scrollBar.visible ? 7 : 0)
                height: 38
                radius: Appearance.radiusMedium
                color: rowCard.isSelected
                    ? Colors.surface_container_high
                    : (rowHover.containsMouse ? Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.5) : "transparent")
                border.color: rowCard.isSelected ? Colors.primary : "transparent"
                border.width: rowCard.isSelected ? 1 : 0

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    // Left Icon
                    Item {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        // Desktop Application Icon
                        Image {
                            anchors.fill: parent
                            source: (rowCard.modelData.isApp && rowCard.modelData.icon) ? Quickshell.iconPath(rowCard.modelData.icon, 24) : ""
                            fillMode: Image.PreserveAspectFit
                            visible: rowCard.modelData.isApp && status === Image.Ready
                        }

                        // Math Calculator Icon
                        Icon {
                            anchors.centerIn: parent
                            name: "󰃬"
                            size: 20
                            color: Colors.primary
                            visible: rowCard.modelData.type === "math"
                        }

                        // Web Search Icon
                        Icon {
                            anchors.centerIn: parent
                            name: "󰖟"
                            size: 18
                            color: Colors.primary
                            visible: rowCard.modelData.type === "web"
                        }

                        // Fallback Generic App Icon
                        Icon {
                            anchors.centerIn: parent
                            name: "󰣆"
                            size: 20
                            color: rowCard.isSelected ? Colors.primary : Colors.on_surface_variant
                            visible: rowCard.modelData.isApp && (!rowCard.modelData.icon || parent.children[0].status !== Image.Ready)
                        }
                    }

                    // App / Item Title (Clean single line, no description)
                    Text {
                        width: parent.width - 34
                        anchors.verticalCenter: parent.verticalCenter
                        text: rowCard.modelData.name
                        color: rowCard.modelData.type === "math" ? Colors.primary : Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        font.bold: rowCard.isSelected
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        resultsList.currentIndex = rowCard.index;
                        Launcher.executeItem(rowCard.modelData);
                    }
                }
            }
        }

        // ── 2. DIVIDER (Separates results from textbox) ───────────────
        Rectangle {
            id: divider
            anchors.bottom: searchRow.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            visible: root.currentResults.length > 0
            color: Qt.rgba(Colors.outline_variant.r, Colors.outline_variant.g, Colors.outline_variant.b, 0.4)
        }

        // ── 3. SEARCH INPUT (Directly in bubble, bottom section) ──────
        Item {
            id: searchRow
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: dialogCard.inputHeight

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Icon {
                    name: "󰍉"
                    size: 20
                    color: searchInput.activeFocus ? Colors.primary : Colors.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 30
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.on_surface
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontNormal
                    selectByMouse: true
                    autoScroll: true
                    clip: true

                    Text {
                        visible: searchInput.text === "" && !searchInput.activeFocus
                        text: "Search..."
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                    }

                    Keys.onDownPressed: (event) => {
                        if (resultsList.count > 0) {
                            resultsList.currentIndex = Math.min(resultsList.count - 1, resultsList.currentIndex + 1);
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }

                    Keys.onUpPressed: (event) => {
                        if (resultsList.count > 0) {
                            resultsList.currentIndex = Math.max(0, resultsList.currentIndex - 1);
                            resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }

                    Keys.onReturnPressed: (event) => {
                        const res = root.currentResults;
                        if (res.length > 0) {
                            const idx = (resultsList.currentIndex >= 0 && resultsList.currentIndex < res.length)
                                ? resultsList.currentIndex : 0;
                            Launcher.executeItem(res[idx]);
                        }
                        event.accepted = true;
                    }

                    Keys.onEscapePressed: (event) => {
                        Launcher.open = false;
                        event.accepted = true;
                    }

                    onTextChanged: {
                        resultsList.currentIndex = 0;
                    }
                }
            }
        }
    }
}
