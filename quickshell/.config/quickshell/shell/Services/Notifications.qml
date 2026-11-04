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

    function openNotification(item, popupId) {
        if (!item) return;

        if (popupId !== undefined) {
            root.dismissPopup(popupId);
        }

        // 1. Invoke default/open action if registered by client application
        if (item.actions && item.actions.length > 0) {
            let targetAct = null;
            for (let i = 0; i < item.actions.length; i++) {
                const a = item.actions[i];
                if (a && (a.identifier === "default" || a.identifier === "open" || a.identifier === "")) {
                    targetAct = a;
                    break;
                }
            }
            if (!targetAct && item.actions.length === 1) {
                targetAct = item.actions[0];
            }
            if (targetAct && typeof targetAct.invoke === "function") {
                try {
                    targetAct.invoke();
                } catch (e) {
                    console.warn("Failed to invoke notification action:", e);
                }
            }
        }

        const bodyStr = item.body || "";
        const summaryStr = item.summary || "";
        const appNameStr = (item.appName || "").toLowerCase();
        const desktopEntryStr = (item.desktopEntry || "").toLowerCase().replace(/\.desktop$/, "");
        const appIconStr = (item.appIcon || "");
        const fullText = summaryStr + " " + bodyStr;

        // 2. Check for web URL
        const urlMatch = fullText.match(/(https?:\/\/[^\s<>"'\n]+)/i);
        if (urlMatch) {
            Quickshell.execDetached(["xdg-open", urlMatch[1]]);
            return;
        }

        // 3. Check for file path in body, summary, or appIcon (e.g. screenshots)
        let filePath = "";
        const pathMatch = fullText.match(/(?:file:\/\/)?(\/(?:[^\s<>"'\n]+))/);
        if (pathMatch) {
            filePath = pathMatch[1];
        } else if (appIconStr.startsWith("/")) {
            filePath = appIconStr;
        }

        if (filePath && filePath.startsWith("/")) {
            Quickshell.execDetached([
                "sh", "-c",
                "if [ -f \"$1\" ]; then if command -v nautilus >/dev/null 2>&1; then nautilus --select \"$1\" >/dev/null 2>&1 || nautilus \"$(dirname \"$1\")\" >/dev/null 2>&1; else xdg-open \"$(dirname \"$1\")\" >/dev/null 2>&1; fi; elif [ -d \"$1\" ]; then if command -v nautilus >/dev/null 2>&1; then nautilus \"$1\" >/dev/null 2>&1; else xdg-open \"$1\" >/dev/null 2>&1; fi; fi",
                "_", filePath
            ]);
            return;
        }

        // 4. Check if it's a screenshot notification without an explicit path
        if (appNameStr.includes("screenshot") || summaryStr.toLowerCase().includes("screenshot")) {
            const home = Quickshell.env("HOME") || "/home/ciganycenter";
            const ssDir = home + "/Pictures/Screenshots";
            Quickshell.execDetached([
                "sh", "-c",
                "if command -v nautilus >/dev/null 2>&1; then nautilus \"$1\" >/dev/null 2>&1; else xdg-open \"$1\" >/dev/null 2>&1; fi",
                "_", ssDir
            ]);
            return;
        }

        // 5. Application targeting and window focusing in Hyprland
        let pattern = "";
        let launchApp = "";

        if (appNameStr.includes("vesktop") || appNameStr.includes("discord") || desktopEntryStr.includes("vesktop") || desktopEntryStr.includes("discord")) {
            pattern = "vesktop|discord";
            launchApp = "vesktop";
        } else if (appNameStr.includes("spotify") || desktopEntryStr.includes("spotify")) {
            pattern = "spotify";
            launchApp = "spotify";
        } else if (appNameStr.includes("steam") || desktopEntryStr.includes("steam")) {
            pattern = "steam";
            launchApp = "steam";
        } else if (appNameStr.includes("brave") || desktopEntryStr.includes("brave")) {
            pattern = "brave-browser";
            launchApp = "brave";
        } else if (appNameStr.includes("kitty") || desktopEntryStr.includes("kitty")) {
            pattern = "kitty";
            launchApp = "kitty";
        } else if (desktopEntryStr !== "") {
            pattern = desktopEntryStr;
            launchApp = desktopEntryStr;
        } else if (appNameStr !== "" && appNameStr !== "notification" && appNameStr !== "notify-send") {
            pattern = appNameStr;
            launchApp = appNameStr;
        }

        if (pattern !== "") {
            Quickshell.execDetached([
                "sh", "-c",
                `if hyprctl clients -j 2>/dev/null | grep -Ei '"class": *"([^"]*('"$1"')[^"]*)"' >/dev/null 2>&1; then
                    hyprctl dispatch "hl.dsp.focus({ window = \\"class:.*$1.*\\" })" >/dev/null 2>&1
                elif [ -n "$2" ] && command -v "$2" >/dev/null 2>&1; then
                    uwsm app -- "$2" >/dev/null 2>&1 || "$2" >/dev/null 2>&1 &
                fi`,
                "_", pattern, launchApp
            ]);
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
            desktopEntry: notif.desktopEntry || "",
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
