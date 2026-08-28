import QtQuick
import QtQuick.Effects
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Wayland
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PanelWindow {
    id: root

    property var targetScreen
    property bool shouldShow: OSD.active && OSD.screen === root.targetScreen

    screen: root.targetScreen

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    implicitHeight: 140
    color: "transparent"
    visible: true

    mask: Region {}

    Rectangle {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.shouldShow ? 58 : -100
        width: 280
        height: 60
        radius: 0
        color: Theme.base
        opacity: root.shouldShow ? 0.94 : 0
        border.width: 1
        border.color: Theme.muted

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.4
            shadowBlur: 0.7
            shadowVerticalOffset: 8
            shadowHorizontalOffset: 0
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: OSD.icon
                color: Theme.accent
                font.pixelSize: 24
                font.family: Theme.iconFont
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: OSD.label
                    color: Theme.foreground
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Rectangle {
                    width: 180
                    height: 6
                    radius: 0
                    color: Theme.lighterBackground

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, OSD.value / OSD.maximum))
                        height: parent.height
                        radius: 0
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(OSD.value / OSD.maximum * 100) + "%"
                color: Theme.foreground
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: root.shouldShow ? 600 : 180
                easing.type: root.shouldShow ? Easing.OutBounce : Easing.InQuad
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: root.shouldShow ? 150 : 180 }
        }
    }
}
