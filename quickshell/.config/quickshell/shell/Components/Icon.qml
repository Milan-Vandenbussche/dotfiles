import QtQuick
import "../Theme"

Text {
    id: root

    property alias name: root.text
    property int size: Appearance.iconSmall

    font.family: Appearance.fontFamily
    font.pixelSize: size
    color: Colors.on_surface
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
