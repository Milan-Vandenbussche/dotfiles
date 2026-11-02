import QtQuick
import "../../Theme"

Rectangle {
    id: root

    property date currentDate: new Date()

    implicitWidth: 230
    implicitHeight: 220
    radius: Appearance.radiusMedium
    color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.95)
    border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
    border.width: 1

    Column {
        anchors.fill: parent
        anchors.margins: Appearance.spacingMedium
        spacing: Appearance.spacingSmall

        // Header: Full date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.currentDate, "dddd, d MMMM yyyy")
            color: Colors.primary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontNormal
            font.bold: true
        }

        // Subheader: Month & Year
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.currentDate, "MMMM yyyy")
            color: Colors.on_surface_variant
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSmall
        }

        // Days of week header
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Text {
                    required property string modelData
                    width: 22
                    text: modelData
                    color: Colors.primary
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Calendar Grid
        Grid {
            id: calGrid
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 7
            spacing: 6

            readonly property int year: root.currentDate.getFullYear()
            readonly property int month: root.currentDate.getMonth()
            readonly property int today: root.currentDate.getDate()

            // Calculate first day of month (0 = Sunday, 1 = Monday ...)
            readonly property int firstDayIndex: {
                const day = new Date(year, month, 1).getDay();
                return day === 0 ? 6 : (day - 1); // Normalize so Monday = 0
            }
            readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

            Repeater {
                model: 42 // 6 rows of 7 days

                delegate: Rectangle {
                    required property int index
                    readonly property int dayNumber: index - calGrid.firstDayIndex + 1
                    readonly property bool isCurrentMonth: dayNumber >= 1 && dayNumber <= calGrid.daysInMonth
                    readonly property bool isToday: isCurrentMonth && dayNumber === calGrid.today

                    width: 22
                    height: 20
                    radius: Appearance.radiusSmall
                    color: isToday ? Colors.primary : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: isCurrentMonth ? dayNumber.toString() : ""
                        color: isToday ? Colors.on_primary : (isCurrentMonth ? Colors.on_surface : "transparent")
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSmall
                        font.bold: isToday
                    }
                }
            }
        }
    }
}
