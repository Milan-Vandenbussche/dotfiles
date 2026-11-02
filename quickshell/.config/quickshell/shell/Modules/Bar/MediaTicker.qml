import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../../Theme"
import "../../Components"

Rectangle {
    id: root

    readonly property var activePlayer: {
        const players = Mpris.players ? Mpris.players.values : [];
        if (players.length === 0) return null;
        // Prefer playing player, else first player
        for (let i = 0; i < players.length; i++) {
            if (players[i] && players[i].playbackState === MprisPlaybackState.Playing) {
                return players[i];
            }
        }
        return players[0];
    }

    readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle !== "" || activePlayer.trackArtist !== "")
    readonly property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing

    visible: hasMedia
    implicitHeight: 22
    implicitWidth: visible ? contentRow.implicitWidth + Appearance.spacingMedium * 2 : 0
    radius: Appearance.radiusSmall
    color: mouseArea.containsMouse ? Colors.surface_container_high : "transparent"

    Behavior on color { ColorAnimation { duration: Appearance.animDurationFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Appearance.spacingSmall

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: "󰝚"
            size: Appearance.iconSmall
            color: root.isPlaying ? Colors.primary : Colors.on_surface_variant
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.activePlayer) return "";
                const title = root.activePlayer.trackTitle || "Unknown Title";
                const artist = root.activePlayer.trackArtist || "";
                const full = artist !== "" ? (title + " • " + artist) : title;
                return full.length > 32 ? full.substring(0, 30) + "…" : full;
            }
            color: Colors.on_surface
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSmall
            elide: Text.ElideRight
        }

        // Mini 4-bar equalizer that pulses when playing and freezes when paused
        Row {
            id: eqRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            height: 10

            Repeater {
                model: 4
                Rectangle {
                    id: eqBar
                    required property int index
                    width: 2
                    radius: 1
                    color: root.isPlaying ? Colors.primary : Colors.on_surface_variant
                    anchors.bottom: parent.bottom

                    height: root.isPlaying ? 8 : 3

                    SequentialAnimation on height {
                        running: root.isPlaying
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: (eqBar.index % 2 === 0 ? 3 : 9)
                            to: (eqBar.index % 2 === 0 ? 10 : 4)
                            duration: 350 + (eqBar.index * 70)
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            from: (eqBar.index % 2 === 0 ? 10 : 4)
                            to: (eqBar.index % 2 === 0 ? 3 : 9)
                            duration: 350 + (eqBar.index * 70)
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (!root.activePlayer) return;
            if (mouse.button === Qt.LeftButton) {
                root.activePlayer.playPause();
            } else if (mouse.button === Qt.RightButton) {
                root.activePlayer.next();
            }
        }
    }
}
