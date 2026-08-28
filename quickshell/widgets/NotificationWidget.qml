import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

Item {
    id: root
    height: 26
    width: 32
    
    property var popupWindow

    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 0
        border.width: 2
        border.color: Theme.darkForeground

        color: mouseArea.containsMouse ? Theme.accent : Theme.base

        Text {
            anchors.centerIn: parent
            text: NotificationStore.unreadCount > 0 ? NotificationStore.unreadCount.toString() : "󰂚"
            color: mouseArea.containsMouse ? Theme.background : Theme.foreground
            font.pixelSize: NotificationStore.unreadCount > 0 ? 12 : 15
            font.family: NotificationStore.unreadCount > 0 ? Theme.font : Theme.iconFont
            font.weight: NotificationStore.unreadCount > 0 ? Font.Bold : Font.Normal
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    NotificationStore.clearHistory();
                } else {
                    if (root.popupWindow)
                        root.popupWindow.expanded = !root.popupWindow.expanded;
                    NotificationStore.markAllRead();
                }
            }
        }
    }
}
