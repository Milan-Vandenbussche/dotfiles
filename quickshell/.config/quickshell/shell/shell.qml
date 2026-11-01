import QtQuick
import Quickshell
import "Theme"
import "Services"
import "Components"

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

            implicitHeight: 28
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Colors.surface
                border.color: Colors.outline
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: Appearance.spacingMedium

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "󰥔"
                        size: Appearance.iconSmall
                        color: Colors.primary
                    }

                    Text {
                        id: clockText
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.on_surface
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontNormal
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
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.outline
                        text: "|"
                        font.family: Appearance.fontFamily
                    }

                    // Display screen name
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.on_surface_variant
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        text: barWindow.screen ? barWindow.screen.name : ""
                    }

                    // Hardware indicator previews
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Appearance.spacingSmall

                        Icon {
                            visible: Hardware.hasBattery
                            name: "󰁹"
                            size: Appearance.iconSmall
                            color: Colors.primary
                        }

                        Icon {
                            visible: Hardware.hasBluetooth
                            name: "󰂯"
                            size: Appearance.iconSmall
                            color: Colors.on_surface_variant
                        }

                        Icon {
                            visible: Hardware.hasWifi
                            name: "󰤨"
                            size: Appearance.iconSmall
                            color: Colors.on_surface_variant
                        }
                    }
                }
            }
        }
    }
}
