pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string wallpapersFolder: {
        const home = Quickshell.env("HOME");
        return home + "/Pictures/wallpapers";
    }

    readonly property string statePath: {
        const stateHome = Quickshell.env("XDG_STATE_HOME");
        const base = stateHome && stateHome !== "" ? stateHome : (Quickshell.env("HOME") + "/.local/state");
        return base + "/theme/state.json";
    }

    // Live state tracking
    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true

        JsonAdapter {
            id: stateJson
            property string wallpaper: ""
            property string mode: "dark"
            property string scheme: "scheme-tonal-spot"
        }
    }

    readonly property string currentWallpaper: stateJson.wallpaper || ""
    property string selectedMode: stateJson.mode || "dark"
    property string selectedScheme: stateJson.scheme || "scheme-tonal-spot"

    property var wallpapers: []
    property bool busy: false
    property bool pickerOpen: false
    property string statusMessage: ""

    // IPC handler allowing Hyprland keybinds (e.g. Super+W) or CLI to control picker
    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            root.togglePicker();
        }
        function open(): void {
            root.pickerOpen = true;
        }
        function close(): void {
            root.pickerOpen = false;
        }
        function random(): void {
            root.random();
        }
        function shuffle(): void {
            root.shuffle();
        }
    }

    function togglePicker() {
        if (!root.pickerOpen) {
            root.scan();
        }
        root.pickerOpen = !root.pickerOpen;
    }

    // Scan wallpaper folder for images sorted by color/hue
    Process {
        id: scanner
        command: ["wallpaper-sort"]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                if (!text) return;
                const lines = text.trim().split("\n").filter(l => l.length > 0);
                root.wallpapers = lines;
            }
        }
    }

    function scan() {
        scanner.running = true;
    }

    // Apply wallpaper via theme-apply wrapper process
    Process {
        id: applyProc
        running: false
        onExited: (code) => {
            root.busy = false;
            if (code === 0) {
                root.statusMessage = "Theme applied successfully";
                stateFile.reload();
            } else {
                root.statusMessage = "Failed to apply theme (code " + code + ")";
            }
        }
    }

    function apply(path, mode, scheme) {
        if (!path || root.busy) return;
        const targetMode = mode || root.selectedMode || "dark";
        const targetScheme = scheme || root.selectedScheme || "scheme-tonal-spot";

        // Instantly trigger awww image crossfade with 0ms delay on click
        Quickshell.execDetached(["awww", "img", path, "--transition-type", "fade", "--transition-duration", "0.5", "--transition-fps", "60"]);

        root.busy = true;
        root.statusMessage = "Generating palette and applying theme...";
        applyProc.command = ["theme-apply", path, "--mode", targetMode, "--scheme", targetScheme];
        applyProc.running = true;
    }

    function random() {
        if (!root.wallpapers || root.wallpapers.length === 0) return;
        const current = root.currentWallpaper;
        const available = root.wallpapers.filter(p => p !== current);
        const list = available.length > 0 ? available : root.wallpapers;
        const chosen = list[Math.floor(Math.random() * list.length)];
        root.apply(chosen);
    }

    function shuffle() {
        root.random();
    }
}
