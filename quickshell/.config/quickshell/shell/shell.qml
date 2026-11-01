import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Height for initial parallel testing
            // (Waybar is 26px; we can use 28px or temporarily bottom/top)
            height: 28

            color: "#111111"

            Rectangle {
                anchors.fill: parent
                color: "#181825"

                border {
                    color: "#313244"
                    width: 1
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        id: clockText
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        text: Qt.formatDateTime(new Date(), "ddd dd MMM  hh:mm:ss")

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: {
                                clockText.text = Qt.formatDateTime(new Date(), "ddd dd MMM  hh:mm:ss")
                            }
                        }
                    }

                    Text {
                        color: "#89b4fa"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        text: "• " + (barWindow.screen ? barWindow.screen.name : "")
                    }
                }
            }
        }
    }
}
