import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Hyprland
import qs.popups
import qs.widgets
import qs.windows
import QtQuick
import qs.services

Item {
    id: root

    property var screen

    readonly property int itemHeight: 18
    readonly property int inactiveWidth: 18
    readonly property int activeWidth: 32
    readonly property int itemSpacing: 5

    implicitWidth: workspaceRow.width
    implicitHeight: itemHeight

    Row {
        id: workspaceRow

        spacing: root.itemSpacing
        height: root.itemHeight

        Repeater {
            model: Hyprland.workspaces.values.filter(workspace => root.screen && workspace.monitor && workspace.monitor.name === root.screen.name && workspace.id > 0)

            delegate: Rectangle {
                required property var modelData

                readonly property bool isActive: modelData.active
                readonly property bool hasWindows: modelData.toplevels && modelData.toplevels.values ? modelData.toplevels.values.length > 0 : false

                width: isActive ? root.activeWidth : root.inactiveWidth

                height: root.itemHeight
                radius: 0

                color: isActive ? Theme.accent : (hasWindows ? Theme.lighterBackground : Theme.darkBackground)

                opacity: isActive ? 1.0 : 0.85

                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Hyprland.dispatch('hl.dsp.focus({ workspace = "' + modelData.id + '" })')
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: modelData.id

                    color: isActive ? Theme.background : (hasWindows ? Theme.lightForeground : Theme.brightForeground)

                    font.pixelSize: 11
                    font.family: Theme.uiFont

                    font.weight: isActive ? Font.Bold : Font.Normal
                }
            }
        }
    }
}
