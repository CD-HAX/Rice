import QtQuick
import qs.services

Item {
    id: root

    width: 32
    height: 32

    property bool hovered: mouseArea.containsMouse

    Rectangle {
        height: 24
        width: 24
        anchors.centerIn: parent
        radius: 0
        color: mouseArea.containsMouse ? Theme.accent : "transparent"


        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󱗼"
        color: Theme.foreground
        font.pixelSize: 16
        font.family: Theme.iconFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Launcher.toggle()
    }
}
