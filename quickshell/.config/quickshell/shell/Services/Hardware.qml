pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io

Item {
    id: root

    // Battery Detection
    readonly property bool hasBattery: {
        if (!UPower.displayDevice) return false;
        return UPower.displayDevice.type === UPowerDeviceType.Battery;
    }

    // Bluetooth Detection
    readonly property bool hasBluetooth: {
        return Bluetooth.defaultAdapter !== null;
    }

    // Wi-Fi Detection
    readonly property bool hasWifi: {
        if (!Networking.devices || !Networking.devices.values) return false;
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].type === DeviceType.Wifi) return true;
        }
        return false;
    }

    // Backlight Detection
    property bool hasBacklight: false

    Process {
        id: backlightProbe
        command: ["sh", "-c", "test -d /sys/class/backlight && [ \"$(ls -A /sys/class/backlight 2>/dev/null)\" ]"]
        running: true
        onExited: (code) => {
            root.hasBacklight = (code === 0);
        }
    }

    // Screens helper
    readonly property var screens: Quickshell.screens
    readonly property int screenCount: Quickshell.screens ? Quickshell.screens.length : 0
}
