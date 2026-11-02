pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root

    readonly property bool hasAdapter: Bluetooth.defaultAdapter !== null
    readonly property bool isEnabled: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    readonly property bool isConnected: {
        if (!Bluetooth.defaultAdapter) return false;
        const devs = Bluetooth.defaultAdapter.devices ? Bluetooth.defaultAdapter.devices.values : [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected) return true;
        }
        return false;
    }

    function togglePower() {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
        }
    }

    function openManager() {
        Quickshell.execDetached(["blueman-manager"]);
    }
}
