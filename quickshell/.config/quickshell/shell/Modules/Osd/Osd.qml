import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"
import "../../Components"

PanelWindow {
    id: root



    WlrLayershell.namespace: "qs-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Click-through: mouse clicks pass through the window completely
    mask: Region {}

    anchors {
        bottom: true
    }
    margins {
        bottom: 56
    }

    implicitWidth: 230
    implicitHeight: 46
    color: "transparent"

    property real osdOpacity: 0.0
    visible: osdOpacity > 0.001

    property string iconName: "󰕾"
    property real displayValue: 0.5
    property string displayText: "50%"
    property bool isMuted: false

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.osdOpacity = 0.0
    }

    function showOsd(icon, val, txt, muted) {
        root.iconName = icon;
        root.displayValue = Math.max(0.0, Math.min(1.0, val));
        root.displayText = txt;
        root.isMuted = muted;
        root.osdOpacity = 1.0;
        hideTimer.restart();
    }

    Connections {
        target: Audio
        function onVolumeAdjusted(vol, isMuted) {
            const icon = isMuted ? "󰝟" : (vol > 0.66 ? "󰕾" : (vol > 0.33 ? "󰖀" : "󰕿"));
            const txt = isMuted ? "Muted" : Math.round(vol * 100) + "%";
            root.showOsd(icon, vol, txt, isMuted);
        }
    }

    Connections {
        target: Power
        function onBrightnessAdjusted(pct) {
            const icon = pct > 66 ? "󰃠" : (pct > 33 ? "󰃟" : "󰃞");
            const val = pct / 100.0;
            const txt = pct + "%";
            root.showOsd(icon, val, txt, false);
        }
    }

    // Pill Card
    Rectangle {
        anchors.fill: parent
        radius: 23
        opacity: root.osdOpacity
        color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.92)
        border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
        border.width: 1

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Row {
            anchors.centerIn: parent
            spacing: Appearance.spacingMedium

            // Icon
            Icon {
                name: root.iconName
                size: Appearance.iconMedium
                color: root.isMuted ? Colors.error : Colors.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            // Progress Bar Track
            Rectangle {
                width: 100
                height: 6
                radius: 3
                color: Colors.surface_container_highest
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Rectangle {
                    width: Math.max(0, parent.width * root.displayValue)
                    height: parent.height
                    radius: 3
                    color: root.isMuted ? Colors.error : Colors.primary

                    Behavior on width {
                        NumberAnimation { duration: Appearance.animDurationFast; easing.type: Easing.OutCubic }
                    }
                }
            }

            // Text
            Text {
                width: 44
                text: root.displayText
                color: Colors.on_surface
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSmall
                font.bold: true
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
