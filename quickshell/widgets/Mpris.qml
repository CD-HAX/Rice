import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Services.Mpris
import qs.popups
import qs.widgets
import qs.windows
import qs.services

Item {
    id: root

    property var screen
    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    implicitWidth: background.width
    implicitHeight: 26
    visible: root.player !== null

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
            spacing: 8

            Rectangle {
                id: thumbFrame
                width: 18
                height: 18
                radius: 9
                color: Theme.background
                clip: true
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.fill: parent
                    source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source.toString().length > 0
                }

                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.isPlaying ? "󰐊" : "󰏤"
                    color: Theme.accent
                    font.pixelSize: 10
                    font.family: Theme.iconFont
                    visible: !(root.player && root.player.trackArtUrl)
                }
            }

            Text {
                text: {
                    if (!root.player)
                        return "No player"
                    const title = root.player.trackTitle || "Unknown"
                    return title.length > 24 ? title.substring(0, 24) + "…" : title
                }
                color: Theme.foreground
                font.pixelSize: 12
                font.family: Theme.uiFont
                font.weight: Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    Player.toggle(root.screen)
                } else if (mouse.button === Qt.MiddleButton && root.player) {
                    root.player.togglePlaying()
                }
            }

            onWheel: wheel => {
                if (!root.player)
                    return

                if (wheel.angleDelta.y > 0 && root.player.canGoNext)
                    root.player.next()
                else if (wheel.angleDelta.y < 0 && root.player.canGoPrevious)
                    root.player.previous()
            }
        }
    }
}
