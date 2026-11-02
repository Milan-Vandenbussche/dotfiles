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

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: root.activePlayer ? (root.activePlayer.trackTitle || "Unknown Title") : ""
                color: Colors.on_surface
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSmall
                font.weight: Font.Medium
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                visible: root.activePlayer && root.activePlayer.trackArtist !== ""
                text: root.activePlayer && root.activePlayer.trackArtist !== "" ? ("• " + root.activePlayer.trackArtist) : ""
                color: Colors.primary
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSmall
                elide: Text.ElideRight
                maximumLineCount: 1
            }
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
                if (root.activePlayer.canTogglePlaying) {
                    root.activePlayer.togglePlaying();
                } else if (root.activePlayer.isPlaying) {
                    root.activePlayer.pause();
                } else {
                    root.activePlayer.play();
                }
            } else if (mouse.button === Qt.RightButton) {
                if (root.activePlayer.canGoNext) {
                    root.activePlayer.next();
                }
            }
        }
    }
}
