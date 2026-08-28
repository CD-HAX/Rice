import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PopupWindow {
    id: root

    property var anchorItem
    property bool expanded: false

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 18

    implicitWidth: 260
    implicitHeight: 220
    color: "transparent"
    grabFocus: true
    visible: root.expanded && root.anchorItem !== null

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: Theme.base
        border.width: 1
        border.color: Theme.muted

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            Rectangle {
                width: 64
                height: 64
                radius: 0
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.background
                clip: true
                border.width: 2
                border.color: Theme.accent

                Image {
                    anchors.fill: parent
                    source: WallpaperService.activeAvatar ? ("file://" + WallpaperService.activeAvatar) : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source.toString().length > 0
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Session.username
                color: Theme.foreground
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Uptime " + Session.uptime
                color: Theme.darkForeground
                font.pixelSize: 11
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                component PowerButton: Rectangle {
                    property string icon: ""
                    signal activated()

                    width: 44
                    height: 44
                    radius: 0
                    color: pMouse.containsMouse ? Theme.background : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: parent.icon
                        color: pMouse.containsMouse ? Theme.accent : Theme.foreground
                        font.pixelSize: 18
                        font.family: Theme.iconFont
                    }

                    MouseArea {
                        id: pMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.activated()
                    }
                }

                PowerButton {
                    icon: "󰌾"
                    onActivated: {
                        Session.lock()
                        root.expanded = false
                    }
                }
                PowerButton {
                    icon: "󰤄"
                    onActivated: Session.suspend()
                }
                PowerButton {
                    icon: "󰜉"
                    onActivated: Session.reboot()
                }
                PowerButton {
                    icon: "󰐥"
                    onActivated: Session.shutdown()
                }
            }
        }
    }
}
