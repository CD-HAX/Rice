import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

Item {
    id: root

    property var screen
    property bool popupOpen: false
    property bool showDetailedTime: false

    implicitWidth: background.width
    implicitHeight: background.height

    property string timeStr: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const date = new Date();
            const daysShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            const daysFull = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
            const monthsShort = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

            const hours = String(date.getHours()).padStart(2, '0');
            const mins = String(date.getMinutes()).padStart(2, '0');
            const secs = String(date.getSeconds()).padStart(2, '0');

            if (root.showDetailedTime) {
                // Detailed format: Fri, 21 Aug, 21:24:26
                const dayShort = daysShort[date.getDay()];
                const dayNum = String(date.getDate()).padStart(2, '0');
                const monthShort = monthsShort[date.getMonth()];

                root.timeStr = `${dayShort}, ${dayNum} ${monthShort}, ${hours}:${mins}:${secs}`;
            } else {
                // Default format: Friday 21:24
                const dayFull = daysFull[date.getDay()];
                root.timeStr = `${dayFull} ${hours}:${mins}`;
            }
        }
    }

    Rectangle {
        id: background

        width: pillRow.implicitWidth + 16
        height: 26
        radius: 8
        color: Theme.lighterBackground
        border.width: 1
        border.color: Theme.muted

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: root.timeStr
                color: Theme.foreground
                font.pixelSize: 11
                font.family: Theme.monoFont
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: WeatherService.weatherIcon
                color: Theme.foreground
                font.pixelSize: 13
                font.family: Theme.iconFont // <-- ADD THIS LINE
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    // Left-click opens/closes Weather OSD
                    root.popupOpen = !root.popupOpen;
                } else if (mouse.button === Qt.RightButton) {
                    // Right-click toggles detailed date format
                    root.showDetailedTime = !root.showDetailedTime;
                }
            }
        }
    }

    WeatherPopup {
        id: popup
        anchorItem: background
        targetScreen: root.screen
        expanded: root.popupOpen

        onClosed: root.popupOpen = false
    }
}
