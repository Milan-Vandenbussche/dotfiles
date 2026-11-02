pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Item {
    id: root

    readonly property bool isConnected: {
        const devs = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected) return true;
        }
        return false;
    }

    readonly property bool isWifi: {
        const devs = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].type === DeviceType.Wifi && devs[i].connected) return true;
        }
        return false;
    }

    readonly property bool isEthernet: {
        const devs = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].type === DeviceType.Wired && devs[i].connected) return true;
        }
        return false;
    }

    // Wi-Fi signal strength (0.0 to 1.0)
    property real wifiStrength: 0.8
    property string activeSsid: ""

    function toggleWifi() {
        Quickshell.execDetached(["nmcli", "radio", "wifi"]);
    }

    function openNetworkEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }
}
