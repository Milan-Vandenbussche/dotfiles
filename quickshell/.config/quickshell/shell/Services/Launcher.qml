pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool open: false
    property var historyMap: ({})

    readonly property string historyPath: {
        const stateHome = Quickshell.env("XDG_STATE_HOME");
        const base = stateHome && stateHome !== "" ? stateHome : (Quickshell.env("HOME") + "/.local/state");
        return base + "/theme/launcher-history.json";
    }

    readonly property var blacklistedApps: [
        "discord",
        "blueman-manager",
        "blueman",
        "dunst",
        "wofi",
        "waybar",
        "yad"
    ]

    function isBlacklisted(app): bool {
        if (!app) return true;
        const id = (app.id || "").toLowerCase().replace(/\.desktop$/, "");
        const name = (app.name || "").toLowerCase();
        const exec = (app.execString || "").toLowerCase();

        for (let i = 0; i < root.blacklistedApps.length; i++) {
            const b = root.blacklistedApps[i];
            if (id === b || id.startsWith(b + "-") || name === b) return true;
            if (exec.startsWith(b + " ") || exec === b || exec.includes("/" + b + " ") || exec.endsWith("/" + b)) {
                return true;
            }
        }
        return false;
    }

    FileView {
        id: historyFile
        path: root.historyPath
        watchChanges: true
        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (data && typeof data === "object") {
                    const clean = {};
                    for (const k in data) {
                        const lk = k.toLowerCase().replace(/\.desktop$/, "");
                        if (!root.blacklistedApps.includes(lk)) {
                            clean[k] = data[k];
                        }
                    }
                    root.historyMap = clean;
                }
            } catch (e) {
                root.historyMap = {};
            }
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle(); }
        function open(): void { root.open = true; }
        function close(): void { root.open = false; }
    }

    function toggle() {
        root.open = !root.open;
    }

    readonly property var allApps: {
        const raw = DesktopEntries.applications ? (DesktopEntries.applications.values || []) : [];
        const valid = [];
        for (let i = 0; i < raw.length; i++) {
            const a = raw[i];
            if (a && !a.noDisplay && a.name && a.name.trim() !== "" && !root.isBlacklisted(a)) {
                valid.push(a);
            }
        }
        return valid;
    }

    function getLaunchCount(app) {
        if (!app) return 0;
        const key = app.id || app.name || "";
        return root.historyMap[key] || 0;
    }

    function recordLaunch(app) {
        if (!app) return;
        const key = app.id || app.name || "";
        const next = Object.assign({}, root.historyMap);
        next[key] = (next[key] || 0) + 1;
        root.historyMap = next;

        // Persist to state file
        const jsonStr = JSON.stringify(next, null, 2);
        Quickshell.execDetached(["sh", "-c", "mkdir -p $(dirname '" + root.historyPath + "') && printf '%s' \"$1\" > '" + root.historyPath + "'", "_", jsonStr]);
    }

    function parseExec(execStr) {
        if (!execStr) return [];
        // Remove desktop field codes (%u, %U, %f, %F, etc.)
        const cleaned = execStr.replace(/%[a-zA-Z]/g, "").trim();
        const args = [];
        const regex = /[^\s"']+|"([^"]*)"|'([^']*)'/g;
        let match;
        while ((match = regex.exec(cleaned)) !== null) {
            args.push(match[1] || match[2] || match[0]);
        }
        return args;
    }

    function launch(app) {
        if (!app) return;
        root.recordLaunch(app);
        root.open = false;

        const cmdArgs = root.parseExec(app.execString);
        if (cmdArgs.length > 0) {
            Quickshell.execDetached(["uwsm", "app", "--", ...cmdArgs]);
        } else if (typeof app.execute === "function") {
            app.execute();
        }
    }

    function evaluateMath(raw) {
        if (!raw) return null;
        const s = raw.trim();
        if (s.length === 0) return null;

        // Must contain an operator (+ - * / % ^) or a math function call
        const hasOp = /[\+\-\*\/\%\^]/.test(s);
        const hasFunc = /\b(sqrt|cbrt|sin|cos|tan|asin|acos|atan|abs|round|floor|ceil|log|ln|exp)\s*\(/.test(s);
        if (!hasOp && !hasFunc) return null;

        // Reject dangerous characters or unauthorized identifiers
        const stripped = s.replace(/\b(sqrt|cbrt|sin|cos|tan|asin|acos|atan|abs|round|floor|ceil|log|ln|exp|pi|e)\b/gi, "");
        if (/[a-zA-Z_$]/.test(stripped)) return null;

        let expr = s.replace(/\^/g, "**");
        expr = expr.replace(/\bpi\b/gi, "Math.PI");
        expr = expr.replace(/\be\b/gi, "Math.E");
        expr = expr.replace(/\bln\s*\(/gi, "Math.log(");
        expr = expr.replace(/\b(sqrt|cbrt|sin|cos|tan|asin|acos|atan|abs|round|floor|ceil|log|exp)\s*\(/gi, "Math.$1(");

        try {
            const fn = new Function('"use strict"; return (' + expr + ');');
            const val = fn();
            if (typeof val === "number" && !isNaN(val) && isFinite(val)) {
                if (Number.isInteger(val)) return val.toString();
                return parseFloat(val.toFixed(8)).toString();
            }
        } catch (e) {
            return null;
        }
        return null;
    }

    function executeItem(item) {
        if (!item) return;
        if (item.type === "app") {
            root.launch(item.app);
        } else if (item.type === "math") {
            Quickshell.execDetached(["wl-copy", item.value]);
            root.open = false;
        } else if (item.type === "web") {
            const url = "https://search.brave.com/search?q=" + encodeURIComponent(item.value);
            Quickshell.execDetached(["uwsm", "app", "--", "brave", url]);
            root.open = false;
        }
    }

    function queryLauncher(query) {
        const raw = (query || "").trim();
        if (raw === "") {
            return [];
        }

        const items = [];

        // 1. Math calculation
        const mathRes = root.evaluateMath(raw);
        if (mathRes !== null) {
            items.push({
                id: "math-result",
                type: "math",
                name: "= " + mathRes,
                subtitle: "",
                icon: "󰃬",
                isApp: false,
                value: mathRes
            });
        }

        // 2. Filter desktop applications
        const q = raw.toLowerCase();
        const apps = root.allApps;
        const matchedApps = [];

        for (let i = 0; i < apps.length; i++) {
            const a = apps[i];
            const name = (a.name || "").toLowerCase();
            const gen = (a.genericName || "").toLowerCase();
            const comment = (a.comment || "").toLowerCase();
            const exec = (a.execString || "").toLowerCase();

            let match = false;
            if (name.includes(q)) match = true;
            else if (gen.includes(q)) match = true;
            else if (comment.includes(q)) match = true;
            else if (exec.includes(q)) match = true;
            else if (a.keywords) {
                for (let k of a.keywords) {
                    if (k && k.toLowerCase().includes(q)) {
                        match = true;
                        break;
                    }
                }
            }

            if (match) {
                matchedApps.push(a);
            }
        }

        // Sort apps: exact prefix match first, then launch count, then alphabetical
        matchedApps.sort((a, b) => {
            const aStarts = a.name.toLowerCase().startsWith(q);
            const bStarts = b.name.toLowerCase().startsWith(q);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;

            const countA = root.getLaunchCount(a);
            const countB = root.getLaunchCount(b);
            if (countB !== countA) return countB - countA;

            return a.name.localeCompare(b.name);
        });

        // Add top apps (max 6)
        const limit = Math.min(matchedApps.length, 6);
        for (let j = 0; j < limit; j++) {
            const a = matchedApps[j];
            items.push({
                id: "app-" + (a.id || a.name),
                type: "app",
                name: a.name,
                subtitle: a.comment || a.genericName || a.execString || "",
                icon: a.icon || "",
                isApp: true,
                app: a,
                value: ""
            });
        }

        // 3. Web Search Option (Brave)
        items.push({
            id: "web-search",
            type: "web",
            name: "Search Brave for \"" + raw + "\"",
            subtitle: "search.brave.com",
            icon: "󰖟",
            isApp: false,
            value: raw
        });

        return items;
    }

    function search(query) {
        const q = (query || "").trim().toLowerCase();
        const apps = root.allApps;

        if (q === "") {
            // Sort by popularity / recent launch count, then alphabetical
            return apps.slice().sort((a, b) => {
                const countA = root.getLaunchCount(a);
                const countB = root.getLaunchCount(b);
                if (countB !== countA) return countB - countA;
                return a.name.localeCompare(b.name);
            });
        }

        const filtered = [];
        for (let i = 0; i < apps.length; i++) {
            const a = apps[i];
            const name = (a.name || "").toLowerCase();
            const gen = (a.genericName || "").toLowerCase();
            const comment = (a.comment || "").toLowerCase();
            const exec = (a.execString || "").toLowerCase();

            let match = false;
            if (name.includes(q)) match = true;
            else if (gen.includes(q)) match = true;
            else if (comment.includes(q)) match = true;
            else if (exec.includes(q)) match = true;
            else if (a.keywords) {
                for (let k of a.keywords) {
                    if (k && k.toLowerCase().includes(q)) {
                        match = true;
                        break;
                    }
                }
            }

            if (match) {
                filtered.push(a);
            }
        }

        // Sort results: exact prefix match first, then launch count, then alphabetical
        return filtered.sort((a, b) => {
            const aStarts = a.name.toLowerCase().startsWith(q);
            const bStarts = b.name.toLowerCase().startsWith(q);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;

            const countA = root.getLaunchCount(a);
            const countB = root.getLaunchCount(b);
            if (countB !== countA) return countB - countA;

            return a.name.localeCompare(b.name);
        });
    }
}
