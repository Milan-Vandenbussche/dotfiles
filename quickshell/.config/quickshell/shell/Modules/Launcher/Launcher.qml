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

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            appsList.currentIndex = 0;
            searchInput.forceActiveFocus();
        } else {
            searchInput.focus = false;
        }
    }

    // Dim backdrop (clicking outside closes the launcher)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)

        MouseArea {
            anchors.fill: parent
            onClicked: Launcher.open = false
        }
    }

    // Main Modal Card
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: 580
        height: 490
        radius: Appearance.radiusLarge
        color: Colors.surface_container
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.40)
        border.width: 1
        clip: true

        // Prevent clicking inside card from closing
        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: Appearance.spacingLarge
            spacing: Appearance.spacingMedium

            // ── 1. SEARCH INPUT BAR ──────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 46
                radius: Appearance.radiusMedium
                color: Colors.surface_container_high
                border.color: searchInput.activeFocus ? Colors.primary : Colors.outline_variant
                border.width: searchInput.activeFocus ? 2 : 1

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
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
                        selectByMouse: true
                        clip: true

                        Text {
                            visible: searchInput.text === "" && !searchInput.activeFocus
                            text: "Search applications..."
                            color: Colors.on_surface_variant
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontNormal
                        }

                        Keys.onDownPressed: (event) => {
                            if (appsList.count > 0) {
                                appsList.currentIndex = Math.min(appsList.count - 1, appsList.currentIndex + 1);
                                appsList.positionViewAtIndex(appsList.currentIndex, ListView.Contain);
                            }
                            event.accepted = true;
                        }

                        Keys.onUpPressed: (event) => {
                            if (appsList.count > 0) {
                                appsList.currentIndex = Math.max(0, appsList.currentIndex - 1);
                                appsList.positionViewAtIndex(appsList.currentIndex, ListView.Contain);
                            }
                            event.accepted = true;
                        }

                        Keys.onReturnPressed: (event) => {
                            const results = Launcher.search(searchInput.text);
                            if (results.length > 0 && appsList.currentIndex >= 0 && appsList.currentIndex < results.length) {
                                Launcher.launch(results[appsList.currentIndex]);
                            }
                            event.accepted = true;
                        }

                        Keys.onEscapePressed: (event) => {
                            Launcher.open = false;
                            event.accepted = true;
                        }

                        onTextChanged: {
                            appsList.currentIndex = 0;
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

            // ── 2. SCROLLABLE APPS LIST ──────────────────────────────────
            ListView {
                id: appsList
                width: parent.width
                height: parent.height - 76
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds

                model: Launcher.search(searchInput.text)

                ScrollBar.vertical: ScrollBar {
                    id: scrollBar
                    policy: ScrollBar.AsNeeded
                    active: appsList.moving || appsList.flicking
                    width: 6

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: 3
                        color: scrollBar.pressed ? Colors.primary : Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.4)
                    }
                }

                delegate: Rectangle {
                    id: rowCard
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: appsList.currentIndex === index

                    width: appsList.width - 10
                    height: 50
                    radius: Appearance.radiusSmall
                    color: rowCard.isSelected ? Colors.surface_container_high : (rowHover.containsMouse ? Qt.rgba(Colors.surface_container_high.r, Colors.surface_container_high.g, Colors.surface_container_high.b, 0.5) : "transparent")
                    border.color: rowCard.isSelected ? Colors.primary : "transparent"
                    border.width: rowCard.isSelected ? 1 : 0

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        // App Icon
                        Item {
                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.fill: parent
                                source: rowCard.modelData.icon ? Quickshell.iconPath(rowCard.modelData.icon, 32) : ""
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "󰣆"
                                size: 24
                                color: rowCard.isSelected ? Colors.primary : Colors.on_surface_variant
                                visible: !rowCard.modelData.icon || parent.children[0].status !== Image.Ready
                            }
                        }

                        // App Title & Subtitle
                        Column {
                            width: parent.width - 60
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: rowCard.modelData.name
                                color: Colors.on_surface
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontNormal
                                font.bold: rowCard.isSelected
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: rowCard.modelData.genericName || rowCard.modelData.comment || rowCard.modelData.execString || ""
                                color: Colors.on_surface_variant
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSmall
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }
                    }

                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appsList.currentIndex = rowCard.index;
                            Launcher.launch(rowCard.modelData);
                        }
                    }
                }
            }
        }
    }
}
