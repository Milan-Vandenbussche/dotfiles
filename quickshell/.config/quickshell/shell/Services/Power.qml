pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../Theme"

Item {
    id: root

    property int batteryPercentage: 100
    property bool isCharging: false
    property bool hasBattery: false
    property int brightnessPercentage: 50

    // Read battery capacity directly from sysfs for instant 0ms latency
    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
        watchChanges: true
        onLoaded: {
            root.hasBattery = true;
            const val = parseInt(text().trim(), 10);
            if (!isNaN(val)) root.batteryPercentage = val;
        }
    }

    FileView {
        id: statusFile
        path: "/sys/class/power_supply/BAT0/status"
        watchChanges: true
        onLoaded: {
            const st = text().trim();
            root.isCharging = (st === "Charging");
        }
    }

    // Refresh timer for battery capacity
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            statusFile.reload();
        }
    }

    // Brightness adjustment on laptop
    function stepBrightness(delta) {
        if (delta > 0) {
            Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", "5%+"]);
            root.brightnessPercentage = Math.min(100, root.brightnessPercentage + 5);
        } else {
            Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", "5%-"]);
            root.brightnessPercentage = Math.max(5, root.brightnessPercentage - 5);
        }
    }

    // Power actions
    function lock() {
        Quickshell.execDetached(["hyprlock"]);
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function logout() {
        Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
    }
}
