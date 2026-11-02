pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Item {
    id: root

    // Track all Pipewire nodes so their audio interfaces are live
    PwObjectTracker {
        objects: Pipewire.nodes ? Pipewire.nodes.values : []
    }

    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultSource: Pipewire.defaultAudioSource

    readonly property real volume: defaultSink && defaultSink.audio ? defaultSink.audio.volume : 1.0
    readonly property bool muted: defaultSink && defaultSink.audio ? defaultSink.audio.muted : false

    readonly property real micVolume: defaultSource && defaultSource.audio ? defaultSource.audio.volume : 1.0
    readonly property bool micMuted: defaultSource && defaultSource.audio ? defaultSource.audio.muted : false

    // Output sinks (speakers, headphones, HDMI)
    readonly property var sinks: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values.filter(n => n && n.isSink && !n.isStream && n.audio);
    }

    // Input sources (microphones)
    readonly property var sources: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values.filter(n => n && !n.isSink && !n.isStream && n.audio);
    }

    // Per-application playback streams
    readonly property var streams: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values.filter(n => n && n.isStream && n.audio);
    }

    property bool panelOpen: false

    // IPC handler allowing keybinds or scripts to control audio
    IpcHandler {
        target: "audio"
        function toggle(): void {
            root.togglePanel();
        }
        function open(): void {
            root.panelOpen = true;
        }
        function close(): void {
            root.panelOpen = false;
        }
        function up(): void {
            root.stepVolume(0.05);
        }
        function down(): void {
            root.stepVolume(-0.05);
        }
        function mute(): void {
            root.toggleMute();
        }
    }

    function togglePanel() {
        root.panelOpen = !root.panelOpen;
    }

    function setVolume(val) {
        const clamped = Math.max(0.0, Math.min(1.0, val));
        if (root.defaultSink && root.defaultSink.audio) {
            root.defaultSink.audio.volume = clamped;
        }
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clamped.toFixed(2)]);
    }

    function stepVolume(delta) {
        const current = root.volume;
        const target = Math.max(0.0, Math.min(1.0, current + delta));
        root.setVolume(target);
        if (root.muted && delta > 0) {
            root.toggleMute();
        }
    }

    function toggleMute() {
        const next = !root.muted;
        if (root.defaultSink && root.defaultSink.audio) {
            root.defaultSink.audio.muted = next;
        }
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", next ? "1" : "0"]);
    }

    function setMicVolume(val) {
        const clamped = Math.max(0.0, Math.min(1.0, val));
        if (root.defaultSource && root.defaultSource.audio) {
            root.defaultSource.audio.volume = clamped;
        }
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", clamped.toFixed(2)]);
    }

    function toggleMicMute() {
        const next = !root.micMuted;
        if (root.defaultSource && root.defaultSource.audio) {
            root.defaultSource.audio.muted = next;
        }
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", next ? "1" : "0"]);
    }

    function setDefaultSink(nodeId) {
        if (!nodeId) return;
        Quickshell.execDetached(["wpctl", "set-default", nodeId.toString()]);
    }

    function setDefaultSource(nodeId) {
        if (!nodeId) return;
        Quickshell.execDetached(["wpctl", "set-default", nodeId.toString()]);
    }

    function setNodeVolume(node, val) {
        if (!node || !node.audio) return;
        const clamped = Math.max(0.0, Math.min(1.0, val));
        node.audio.volume = clamped;
        if (node.id) {
            Quickshell.execDetached(["wpctl", "set-volume", node.id.toString(), clamped.toFixed(2)]);
        }
    }

    function toggleNodeMute(node) {
        if (!node || !node.audio) return;
        const next = !node.audio.muted;
        node.audio.muted = next;
        if (node.id) {
            Quickshell.execDetached(["wpctl", "set-mute", node.id.toString(), next ? "1" : "0"]);
        }
    }
}
