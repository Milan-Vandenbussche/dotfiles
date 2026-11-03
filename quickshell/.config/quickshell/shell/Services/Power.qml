pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../Theme"

Item {
    id: root

    property bool menuOpen: false

    property int batteryPercentage: 100
    property bool isCharging: false
    property bool hasBattery: false

    property int brightnessPercentage: 50
    property int maxBrightness: 15360
    property bool _ready: false

    signal brightnessAdjusted(int percent)

    // Initial startup suppression
    Timer {
        interval: 1200
        running: true
        onTriggered: root._ready = true
    }

    // Read max brightness
    FileView {
        id: maxBrightnessFile
        path: "/sys/class/backlight/intel_backlight/max_brightness"
        onLoaded: {
            const val = parseInt(text().trim(), 10);
            if (!isNaN(val) && val > 0) root.maxBrightness = val;
        }
    }

    // Read actual brightness
    FileView {
        id: actualBrightnessFile
        path: "/sys/class/backlight/intel_backlight/actual_brightness"
        watchChanges: true
        onLoaded: {
            const cur = parseInt(text().trim(), 10);
            if (!isNaN(cur) && root.maxBrightness > 0) {
                const pct = Math.round((cur / root.maxBrightness) * 100);
                if (root._ready && pct !== root.brightnessPercentage) {
                    root.brightnessPercentage = pct;
                    root.brightnessAdjusted(pct);
                } else {
                    root.brightnessPercentage = pct;
                }
            }
        }
    }

    // Read battery capacity directly from sysfs
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

    // Periodic refresh
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            statusFile.reload();
            actualBrightnessFile.reload();
        }
    }

    // IPC handlers
    IpcHandler {
        target: "power"
        function toggle(): void {
            root.toggleMenu();
        }
        function open(): void {
            root.menuOpen = true;
        }
        function close(): void {
            root.menuOpen = false;
        }
    }

    IpcHandler {
        target: "brightness"
        function up(): void {
            root.stepBrightness(5);
        }
        function down(): void {
            root.stepBrightness(-5);
        }
        function set(val: string): void {
            root.setBrightness(parseInt(val, 10));
        }
    }

    function toggleMenu() {
        root.menuOpen = !root.menuOpen;
    }

    // Brightness adjustment on laptop
    function setBrightness(pct) {
        const clamped = Math.max(5, Math.min(100, pct));
        Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", clamped + "%"]);
        root.brightnessPercentage = clamped;
        if (root._ready) {
            root.brightnessAdjusted(clamped);
        }
    }

    function stepBrightness(delta) {
        const next = Math.max(5, Math.min(100, root.brightnessPercentage + delta));
        if (delta > 0) {
            Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", "5%+"]);
        } else {
            Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", "5%-"]);
        }
        root.brightnessPercentage = next;
        if (root._ready) {
            root.brightnessAdjusted(next);
        }
    }

    // Power actions
    function lock() {
        // No lock screen installed on this machine per inventory
    }

    function suspend() {
        root.menuOpen = false;
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        root.menuOpen = false;
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        root.menuOpen = false;
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function logout() {
        root.menuOpen = false;
        Quickshell.execDetached(["uwsm", "stop"]);
    }
}
