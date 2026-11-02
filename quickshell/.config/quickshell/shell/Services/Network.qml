pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

Item {
    id: root

    property bool panelOpen: false

    // IPC handler allowing keybinds to toggle network panel
    IpcHandler {
        target: "network"
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
        if (root.panelOpen && root.wifiDevice) {
            root.wifiDevice.scannerEnabled = true;
        }
    }

    readonly property var wifiDevice: {
        const devs = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].type === DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    readonly property var wiredDevice: {
        const devs = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].type === DeviceType.Wired) return devs[i];
        }
        return null;
    }

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool isConnected: (wiredDevice && wiredDevice.connected) || (wifiDevice && wifiDevice.connected)
    readonly property bool isEthernet: wiredDevice && wiredDevice.connected
    readonly property bool isWifi: wifiDevice && wifiDevice.connected

    // Active connection details
    readonly property var connectedWifi: {
        if (!wifiDevice || !wifiDevice.networks) return null;
        const nets = wifiDevice.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected) return nets[i];
        }
        return null;
    }

    readonly property string activeSsid: connectedWifi ? connectedWifi.name : ""
    readonly property real wifiStrength: connectedWifi ? connectedWifi.signalStrength : 0.0

    // Deduplicated & sorted Wi-Fi networks
    readonly property var networks: {
        if (!wifiDevice || !wifiDevice.networks) return [];
        const raw = wifiDevice.networks.values;
        const seen = {};
        const list = [];
        for (let i = 0; i < raw.length; i++) {
            const n = raw[i];
            if (!n || !n.name || n.name.trim() === "") continue;
            if (!seen[n.name] || n.signalStrength > seen[n.name].signalStrength) {
                seen[n.name] = n;
            }
        }
        for (const k in seen) {
            list.push(seen[k]);
        }
        list.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.known !== b.known) return a.known ? -1 : 1;
            return b.signalStrength - a.signalStrength;
        });
        return list;
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function scan() {
        if (wifiDevice) {
            wifiDevice.scannerEnabled = false;
            wifiDevice.scannerEnabled = true;
        }
        Quickshell.execDetached(["nmcli", "dev", "wifi", "rescan"]);
    }

    function connect(net, psk) {
        if (!net) return;
        if (psk && psk !== "") {
            if (typeof net.connectWithPsk === "function") {
                net.connectWithPsk(psk);
            } else {
                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", net.name, "password", psk]);
            }
        } else {
            if (typeof net.connect === "function") {
                net.connect();
            } else {
                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", net.name]);
            }
        }
    }

    function disconnect(net) {
        if (!net) return;
        if (typeof net.disconnect === "function") {
            net.disconnect();
        } else {
            Quickshell.execDetached(["nmcli", "con", "down", "id", net.name]);
        }
    }

    function forget(net) {
        if (!net) return;
        if (typeof net.forget === "function") {
            net.forget();
        } else {
            Quickshell.execDetached(["nmcli", "con", "delete", "id", net.name]);
        }
    }

    function openTui() {
        root.panelOpen = false;
        Quickshell.execDetached(["kitty", "nmtui"]);
    }
}
