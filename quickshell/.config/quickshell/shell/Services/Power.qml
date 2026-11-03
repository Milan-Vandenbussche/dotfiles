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
    property bool _ready: false

    signal brightnessAdjusted(int percent)

    // Initial startup suppression
    Timer {
        interval: 1200
        running: true
        onTriggered: root._ready = true
    }

    // Process to adjust or query brightness accurately from brightnessctl
    Process {
        id: brightnessProc
        running: false
        stdout: StdioCollector {
            onTextChanged: {
                if (!text) return;
                const parts = text.trim().split(",");
                if (parts.length >= 4) {
                    const raw = parts[3].replace("%", "").trim();
                    const pct = parseInt(raw, 10);
                    if (!isNaN(pct)) {
                        root.brightnessPercentage = pct;
                        if (root._ready) {
                            root.brightnessAdjusted(pct);
                        }
                    }
                }
            }
        }
    }

    // Initial brightness query on startup
    Component.onCompleted: {
        brightnessProc.command = ["brightnessctl", "-m", "info"];
        brightnessProc.running = true;
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

    // Periodic refresh for battery only (never touches brightness)
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            statusFile.reload();
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
        const clamped = Math.max(1, Math.min(100, pct));
        brightnessProc.command = ["brightnessctl", "-m", "set", clamped + "%"];
        brightnessProc.running = true;
    }

    function stepBrightness(delta) {
        if (delta > 0) {
            brightnessProc.command = ["brightnessctl", "-m", "set", "5%+"];
        } else {
            brightnessProc.command = ["brightnessctl", "-m", "set", "5%-"];
        }
        brightnessProc.running = true;
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
