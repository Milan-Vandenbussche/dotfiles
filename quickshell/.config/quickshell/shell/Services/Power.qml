pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../Theme"

Item {
    id: root

    property bool menuOpen: false
    property bool batteryPanelOpen: false

    property int batteryPercentage: 100
    property string batteryStatus: "Full"
    property bool isCharging: false
    property bool hasBattery: false
    property int energyNow: 0
    property int energyFull: 0
    property int powerNow: 0
    property string timeRemainingText: "Fully charged"
    property string currentProfile: "performance"

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

    // Query active power profile via powerprofilesctl
    Process {
        id: profileQueryProc
        command: ["powerprofilesctl", "get"]
        running: false
        stdout: StdioCollector {
            onTextChanged: {
                if (!text) return;
                const p = text.trim();
                if (p.length > 0) root.currentProfile = p;
            }
        }
    }

    function queryProfile() {
        profileQueryProc.command = ["powerprofilesctl", "get"];
        profileQueryProc.running = true;
    }

    function setProfile(profileName) {
        root.currentProfile = profileName;
        Quickshell.execDetached(["powerprofilesctl", "set", profileName]);
    }

    function updateTimeRemaining() {
        const st = (root.batteryStatus || "").trim().toLowerCase();
        if (st === "full") {
            root.timeRemainingText = "Fully charged";
            return;
        }

        if (root.powerNow <= 0) {
            if (root.isCharging) {
                root.timeRemainingText = "Charging (estimating...)";
            } else {
                root.timeRemainingText = "Calculating remaining time...";
            }
            return;
        }

        if (st === "discharging") {
            const hoursFraction = root.energyNow / root.powerNow;
            const totalMinutes = Math.max(1, Math.round(hoursFraction * 60));
            const h = Math.floor(totalMinutes / 60);
            const m = totalMinutes % 60;
            if (h > 0) {
                root.timeRemainingText = h + "h " + (m < 10 ? "0" + m : m) + "m remaining";
            } else {
                root.timeRemainingText = m + "m remaining";
            }
        } else if (st === "charging") {
            const needed = Math.max(0, root.energyFull - root.energyNow);
            const hoursFraction = needed / root.powerNow;
            const totalMinutes = Math.max(1, Math.round(hoursFraction * 60));
            const h = Math.floor(totalMinutes / 60);
            const m = totalMinutes % 60;
            if (h > 0) {
                root.timeRemainingText = h + "h " + (m < 10 ? "0" + m : m) + "m until full";
            } else {
                root.timeRemainingText = m + "m until full";
            }
        } else if (st === "not charging") {
            root.timeRemainingText = "Plugged in (not charging)";
        } else {
            root.timeRemainingText = root.batteryStatus;
        }
    }

    // Initial queries on startup
    Component.onCompleted: {
        brightnessProc.command = ["brightnessctl", "-m", "info"];
        brightnessProc.running = true;
        root.queryProfile();
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
            root.batteryStatus = st;
            root.isCharging = (st === "Charging");
            root.updateTimeRemaining();
        }
    }

    FileView {
        id: energyNowFile
        path: "/sys/class/power_supply/BAT0/energy_now"
        watchChanges: true
        onLoaded: {
            const val = parseInt(text().trim(), 10);
            if (!isNaN(val)) {
                root.energyNow = val;
                root.updateTimeRemaining();
            }
        }
    }

    FileView {
        id: energyFullFile
        path: "/sys/class/power_supply/BAT0/energy_full"
        watchChanges: true
        onLoaded: {
            const val = parseInt(text().trim(), 10);
            if (!isNaN(val)) {
                root.energyFull = val;
                root.updateTimeRemaining();
            }
        }
    }

    FileView {
        id: powerNowFile
        path: "/sys/class/power_supply/BAT0/power_now"
        watchChanges: true
        onLoaded: {
            const val = parseInt(text().trim(), 10);
            if (!isNaN(val)) {
                root.powerNow = val;
                root.updateTimeRemaining();
            }
        }
    }

    // Periodic refresh for battery and power profile (every 5 seconds)
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            statusFile.reload();
            energyNowFile.reload();
            energyFullFile.reload();
            powerNowFile.reload();
            root.queryProfile();
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
