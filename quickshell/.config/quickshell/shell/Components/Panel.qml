import QtQuick
import "../Theme"

Rectangle {
    id: root

    default property alias content: contentLayout.data
    property int padding: Appearance.spacingMedium
    property alias contentItem: contentLayout

    color: Colors.surface_container
    radius: Appearance.radiusMedium
    border.color: Colors.outline
    border.width: 1

    Item {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
