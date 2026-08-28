import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services
Item {
    id: root
    height: 32
    width: 32
    property var popupWindow
    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 0

        color: mouseArea.containsMouse ? Theme.accent : "transparent"

        Text {
            anchors.centerIn: parent

            text: "󰸉"

            color: mouseArea.containsMouse ? Theme.background : Theme.foreground

            font.pixelSize: 16
            font.family: Theme.iconFont
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.popupWindow)
                    root.popupWindow.expanded = !root.popupWindow.expanded;
            }
        }
    }
}
