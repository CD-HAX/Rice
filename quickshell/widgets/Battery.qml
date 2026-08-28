import QtQuick
import qs.services

Item {
    id: root

    readonly property var primary: UPowerService.devices.length > 0 ? UPowerService.devices[0] : null

    implicitWidth: background.width
    implicitHeight: 26
    visible: root.primary !== null

    Rectangle {
        id: background
        width: row.implicitWidth + 20
        height: 26
        radius: 0
        color: Theme.base
        border.width: 2
        border.color: Theme.darkForeground

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.primary && root.primary.state === "charging" ? "󰂄" : "󰁹"
                color: Theme.accent
                font.pixelSize: 13
                font.family: Theme.iconFont
            }

            Text {
                text: root.primary ? root.primary.percentage + "%" : ""
                color: Theme.foreground
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }
    }
}
