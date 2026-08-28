import QtQuick
import QtQuick.Layouts
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
    screen: targetScreen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notif_toasts"
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; right: true }
    
    // Give it enough margin to sit under the bar
    
    color: "transparent"

    implicitWidth: 320
    implicitHeight: layout.contentHeight

    ListView {
        id: layout
        width: parent.width
        height: contentHeight
        spacing: 12
        interactive: false // It's just a stack of toasts, not scrollable
        
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "x"; from: 20; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        
        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
            NumberAnimation { property: "x"; to: 20; duration: 200; easing.type: Easing.InCubic }
        }
        
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
        }

        model: NotificationStore.activeToasts

        delegate: Rectangle {
            width: layout.width
            height: col.implicitHeight + 24
            radius: 0
            color: Theme.base
            opacity: 0.95
            border.width: 1
            border.color: Theme.accent

            // A timer to dismiss the toast automatically
            Timer {
                interval: 1000
                running: !mouseArea.containsMouse
                onTriggered: NotificationStore.removeToast(modelData.notifId)
            }

            RowLayout {
                id: col
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Image {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    source: modelData.appIcon ? (modelData.appIcon.startsWith("file://") || modelData.appIcon.startsWith("/") ? "file://" + modelData.appIcon.replace("file://", "") : Quickshell.iconPath(modelData.appIcon, true)) : ""
                    sourceSize: Qt.size(48, 48)
                    
                    Text {
                        anchors.centerIn: parent
                        visible: parent.status !== Image.Ready
                        text: "󰂚"
                        color: Theme.accent
                        font.pixelSize: 24
                        font.family: Theme.iconFont
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: modelData.appName || "Notification"
                            color: Theme.accent
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "󰅖"
                            color: Theme.darkForeground
                            font.pixelSize: 14
                            font.family: Theme.iconFont
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NotificationStore.removeToast(modelData.notifId)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary
                        color: Theme.foreground
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.body
                        color: Theme.darkForeground
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: -1
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        NotificationStore.removeToast(modelData.notifId);
                    } else {
                        if (typeof modelData.invokeDefault === "function") {
                            modelData.invokeDefault();
                        }
                        NotificationStore.removeToast(modelData.notifId);
                    }
                }
            }
        }
    }
}
