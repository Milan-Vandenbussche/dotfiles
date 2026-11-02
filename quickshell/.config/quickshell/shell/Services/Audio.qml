pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Item {
    id: root

    // Reactive Pipewire integration with wpctl fallback
    property real volume: 0.5
    property bool muted: false

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        function onVolumeChanged() {
            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                root.volume = Pipewire.defaultAudioSink.audio.volume;
            }
        }
        function onMutedChanged() {
            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                root.muted = Pipewire.defaultAudioSink.audio.muted;
            }
        }
    }

    // Process to read initial volume via wpctl
    Process {
        id: wpctlReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                const text = this.text.trim();
                // Output format: "Volume: 0.65" or "Volume: 0.65 [MUTED]"
                const match = text.match(/Volume:\s+([0-9.]+)(\s+\[MUTED\])?/);
                if (match) {
                    root.volume = parseFloat(match[1]);
                    root.muted = !!match[2];
                }
            }
        }
    }

    function stepVolume(delta) {
        if (delta > 0) {
            Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"]);
            root.volume = Math.min(1.0, root.volume + 0.05);
        } else {
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]);
            root.volume = Math.max(0.0, root.volume - 0.05);
        }
        root.muted = false;
    }

    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
        root.muted = !root.muted;
    }

    function openMixer() {
        Quickshell.execDetached(["kitty", "wiremix"]);
    }
}
