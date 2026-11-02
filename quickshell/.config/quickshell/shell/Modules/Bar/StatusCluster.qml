import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../Theme"
import "../../Services"
import "../../Components"

Row {
    id: root
    spacing: Appearance.spacingMedium
    anchors.verticalCenter: parent.verticalCenter

    signal wallpaperPickerRequested()

    // ── 1. Wallpaper Picker Button ───────────────────────────────────────
    IconButton {
        id: wpBtn
        icon: "󰸉"
        iconSize: Appearance.iconMedium
        iconColor: hovered ? Colors.primary : Colors.on_surface_variant
        onClicked: root.wallpaperPickerRequested()
    }

    // ── 2. System Tray ───────────────────────────────────────────────────
    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacingSmall
        visible: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0

        Repeater {
            model: SystemTray.items ? SystemTray.items.values : []

            delegate: Item {
                id: trayDelegate
                required property var modelData
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: trayDelegate.modelData ? (trayDelegate.modelData.icon || "") : ""
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (!trayDelegate.modelData) return;
                        if (mouse.button === Qt.LeftButton) {
                            trayDelegate.modelData.activate(mouse.x, mouse.y);
                        } else if (mouse.button === Qt.RightButton && trayDelegate.modelData.menu) {
                            trayDelegate.modelData.menu.open(mouse.x, mouse.y);
                        }
                    }
                }
            }
        }
    }

    // ── 3. Network (Wi-Fi / Ethernet) ───────────────────────────────────
    Rectangle {
        id: netItem
        implicitWidth: 26
        implicitHeight: 24
        radius: Appearance.radiusSmall
        color: netHover.containsMouse ? Colors.surface_container_high : "transparent"

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        readonly property string netIcon: {
            if (Network.isEthernet) return "󰀂";
            if (!Network.isConnected) return "󰤮";
            const s = Network.wifiStrength;
            if (s > 0.75) return "󰤨";
            if (s > 0.50) return "󰤥";
            if (s > 0.25) return "󰤢";
            return "󰤟";
        }

        Icon {
            anchors.centerIn: parent
            name: netItem.netIcon
            size: Appearance.iconMedium
            color: Network.isConnected ? Colors.on_surface : Colors.on_surface_variant
        }

        MouseArea {
            id: netHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Network.toggleWifi();
                } else {
                    Network.openNetworkEditor();
                }
            }
        }
    }

    // ── 4. Bluetooth (Laptop only) ──────────────────────────────────────
    Rectangle {
        id: btItem
        visible: Hardware.hasBluetooth
        implicitWidth: 26
        implicitHeight: 24
        radius: Appearance.radiusSmall
        color: btHover.containsMouse ? Colors.surface_container_high : "transparent"

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        readonly property string btIcon: {
            if (!Bluetooth.isEnabled) return "󰂲";
            if (Bluetooth.isConnected) return "󰂱";
            return "󰂯";
        }

        Icon {
            anchors.centerIn: parent
            name: btItem.btIcon
            size: Appearance.iconMedium
            color: Bluetooth.isConnected ? Colors.primary : (Bluetooth.isEnabled ? Colors.on_surface : Colors.on_surface_variant)
        }

        MouseArea {
            id: btHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Bluetooth.togglePower();
                } else {
                    Bluetooth.openManager();
                }
            }
        }
    }

    // ── 5. Volume (with Scroll & Right-click Mute) ───────────────────────
    Rectangle {
        id: volItem
        implicitWidth: 26
        implicitHeight: 24
        radius: Appearance.radiusSmall
        color: volHover.containsMouse ? Colors.surface_container_high : "transparent"

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        readonly property string volIcon: {
            if (Audio.muted) return "󰝟";
            const v = Audio.volume;
            if (v > 0.66) return "󰕾";
            if (v > 0.33) return "󰖀";
            return "󰕿";
        }

        Icon {
            anchors.centerIn: parent
            name: volItem.volIcon
            size: Appearance.iconMedium
            color: Audio.muted ? Colors.on_surface_variant : Colors.on_surface
        }

        MouseArea {
            id: volHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onWheel: (wheel) => {
                Audio.stepVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05);
            }

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Audio.toggleMute();
                } else {
                    Audio.openMixer();
                }
            }
        }
    }

    // ── 6. Battery (with Brightness Scroll) ──────────────────────────────
    Rectangle {
        id: batItem
        visible: Hardware.hasBattery && Power.hasBattery
        implicitWidth: 26
        implicitHeight: 24
        radius: Appearance.radiusSmall
        color: batHover.containsMouse ? Colors.surface_container_high : "transparent"

        Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

        readonly property int pct: Power.batteryPercentage
        readonly property bool charging: Power.isCharging

        readonly property string batIcon: {
            const p = batItem.pct;
            if (batItem.charging) {
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

        Icon {
            anchors.centerIn: parent
            name: batItem.batIcon
            size: Appearance.iconMedium
            color: batItem.pct <= 20 && !batItem.charging ? Colors.error : (batItem.charging ? Colors.primary : Colors.on_surface)
        }

        MouseArea {
            id: batHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // Scroll on battery icon adjusts laptop brightness!
            onWheel: (wheel) => {
                Power.stepBrightness(wheel.angleDelta.y > 0 ? 5 : -5);
            }
        }
    }
}
