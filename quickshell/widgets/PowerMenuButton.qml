import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

Item {
    id: root

    property var popupWindow

    width: 32
    height: 32

    Rectangle {
        anchors.centerIn: parent
        width: 22
        height: 18
        radius: 0
        color: mouseArea.containsMouse ? Theme.accent : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        color: Theme.foreground
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
