import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import QtQuick
import Quickshell._Window
import qs.popups
import qs.widgets
import qs.windows

import qs.services

Item {
    id: root

    width: content.width + 16
    height: 26

    property bool hovered: mouseArea.containsMouse

    Rectangle {
        anchors.fill: parent
        height: 26

        radius: 0

        color: Theme.base
        border.width: 2
        border.color: Theme.darkForeground



        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    Row {
        id: content

        anchors.centerIn: parent

        spacing: 10



        Text {
            text: "󰍛 " + Hardware.cpuTemperature.toFixed(0) + "°C"

            color: Theme.foreground

            font.pixelSize: 13
            font.weight: Font.Medium
        }

        Text {
            text: "󰢮 " + Hardware.gpuTemperature.toFixed(0) + "°C"

            color: Theme.foreground

            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true
    }

    TempPopup {
        id: tooltip
        anchorItem: root
        hovered: root.hovered
    }
}
