pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io

Item {
    id: root

    property bool dnd: false
    property bool panelOpen: false
    property var popups: []
    property var history: []
    property int nextId: 1

    readonly property int unreadCount: history.length

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: (notif) => {
            root.handleNotification(notif);
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.togglePanel(); }
        function open(): void { root.panelOpen = true; }
        function close(): void { root.panelOpen = false; }
        function dnd(): void { root.toggleDnd(); }
        function clear(): void { root.clearHistory(); }
    }

    function togglePanel() {
        root.panelOpen = !root.panelOpen;
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }

    function clearHistory() {
        root.history = [];
    }

    function dismissPopup(id) {
        for (let i = 0; i < root.popups.length; i++) {
            if (root.popups[i].internalId === id) {
                if (root.popups[i].notifObj && typeof root.popups[i].notifObj.dismiss === "function") {
                    root.popups[i].notifObj.dismiss();
                }
                break;
            }
        }
        root.removePopup(id);
    }

    function removePopup(id) {
        const next = [];
        for (let i = 0; i < root.popups.length; i++) {
            if (root.popups[i].internalId !== id) {
                next.push(root.popups[i]);
            }
        }
        root.popups = next;
    }

    function removeHistory(id) {
        const next = [];
        for (let i = 0; i < root.history.length; i++) {
            if (root.history[i].internalId !== id) {
                next.push(root.history[i]);
            }
        }
        root.history = next;
    }

    function invokeAction(action, popupId) {
        if (action && typeof action.invoke === "function") {
            action.invoke();
        }
        if (popupId !== undefined) {
            root.dismissPopup(popupId);
        }
    }

    function handleNotification(notif) {
        if (!notif) return;

        const isCrit = (notif.urgency === 2) || (typeof NotificationUrgency !== "undefined" && notif.urgency === NotificationUrgency.Critical);

        const actionsList = [];
        if (notif.actions) {
            for (let i = 0; i < notif.actions.length; i++) {
                actionsList.push(notif.actions[i]);
            }
        }

        const item = {
            internalId: root.nextId++,
            notifObj: notif,
            appName: notif.appName || "Notification",
            appIcon: notif.appIcon || "",
            summary: notif.summary || "",
            body: notif.body || "",
            urgency: notif.urgency,
            actions: actionsList,
            time: new Date().toLocaleTimeString(Qt.locale(), "hh:mm"),
            timeout: (notif.expireTimeout && notif.expireTimeout > 0) ? notif.expireTimeout : 5000,
            isCritical: isCrit
        };

        // Record into history
        root.history = [item, ...root.history.slice(0, 49)];

        // If not in Do Not Disturb mode, pop up on screen
        if (!root.dnd) {
            root.popups = [...root.popups, item];
        }
    }
}
