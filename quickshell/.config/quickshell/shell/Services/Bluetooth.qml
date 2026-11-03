pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

Item {
    id: root

    property bool panelOpen: false

    // IPC handler allowing keybinds to toggle bluetooth panel
    IpcHandler {
        target: "bluetooth"
        function toggle(): void {
            root.togglePanel();
        }
        function open(): void {
            root.panelOpen = true;
        }
        function close(): void {
            root.panelOpen = false;
        }
    }

    function togglePanel() {
        root.panelOpen = !root.panelOpen;
        if (root.panelOpen && root.isEnabled && !root.isDiscovering) {
            root.startDiscovery();
        }
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: adapter !== null
    readonly property bool isEnabled: adapter ? adapter.enabled : false
    readonly property bool isDiscovering: adapter ? adapter.discovering : false

    // All known devices reactively from Quickshell.Bluetooth
    readonly property var devices: {
        if (Bluetooth.devices && Bluetooth.devices.values) return Bluetooth.devices.values;
        if (adapter && adapter.devices && adapter.devices.values) return adapter.devices.values;
        return [];
    }

    // Paired devices
    readonly property var pairedDevices: {
        const list = root.devices || [];
        return list.filter(d => d && d.paired);
    }

    // Unpaired / Discovered devices (with non-empty names)
    readonly property var availableDevices: {
        const list = root.devices || [];
        return list.filter(d => d && !d.paired && d.name && d.name.trim() !== "");
    }

    readonly property bool isConnected: {
        const list = root.devices || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].connected) return true;
        }
        return false;
    }

    readonly property var connectedDevice: {
        const list = root.devices || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].connected) return list[i];
        }
        return null;
    }

    function togglePower() {
        if (root.adapter) {
            root.adapter.enabled = !root.adapter.enabled;
        } else {
            Quickshell.execDetached(["bluetoothctl", "power", root.isEnabled ? "off" : "on"]);
        }
    }

    // Auto-stop discovery timer to save laptop battery
    Timer {
        id: discoveryTimer
        interval: 15000
        repeat: false
        onTriggered: {
            if (root.adapter && root.adapter.discovering) {
                root.adapter.discovering = false;
            }
        }
    }

    function startDiscovery() {
        if (root.adapter && root.isEnabled) {
            root.adapter.discovering = true;
            discoveryTimer.restart();
        }
    }

    function stopDiscovery() {
        if (root.adapter) {
            root.adapter.discovering = false;
            discoveryTimer.stop();
        }
    }

    function toggleDiscovery() {
        if (root.isDiscovering) {
            root.stopDiscovery();
        } else {
            root.startDiscovery();
        }
    }

    function connectDevice(dev) {
        if (!dev) return;
        if (typeof dev.connect === "function") {
            dev.connect();
        } else if (dev.address) {
            Quickshell.execDetached(["bluetoothctl", "connect", dev.address]);
        }
    }

    function disconnectDevice(dev) {
        if (!dev) return;
        if (typeof dev.disconnect === "function") {
            dev.disconnect();
        } else if (dev.address) {
            Quickshell.execDetached(["bluetoothctl", "disconnect", dev.address]);
        }
    }

    function pairDevice(dev) {
        if (!dev) return;
        if (typeof dev.pair === "function") {
            dev.pair();
        } else if (dev.address) {
            Quickshell.execDetached(["bluetoothctl", "pair", dev.address]);
        }
    }

    function forgetDevice(dev) {
        if (!dev) return;
        if (typeof dev.forget === "function") {
            dev.forget();
        } else if (dev.address) {
            Quickshell.execDetached(["bluetoothctl", "remove", dev.address]);
        }
    }

    function openManager() {
        root.panelOpen = false;
        Quickshell.execDetached(["blueman-manager"]);
    }
}
