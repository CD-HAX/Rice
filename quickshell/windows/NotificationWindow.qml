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

    property bool expanded: false
    visible: root.expanded
    property var targetScreen
    screen: targetScreen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "notif_center"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    
    // Close on any keypress
    Item {
        focus: true
        anchors.fill: parent
        Keys.onPressed: (event) => {
            root.expanded = false;
            // Let the event propagate if needed
            event.accepted = false;
        }
    }

    onVisibleChanged: {
        if (visible) {
            NotificationStore.markAllRead();
        }
    }

    // removed onActiveFocusChanged

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = false
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width: 500
        height: 600
        radius: 0
        color: Theme.base
        opacity: 0.8
        border.width: 1
        border.color: Theme.muted
        clip: true

        MouseArea { anchors.fill: parent }

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Notifications"
                    color: Theme.foreground
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 100
                    height: 30
                    radius: 0
                    color: clearMouse.containsMouse ? Theme.accent : Theme.lighterBackground
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: clearMouse.containsMouse ? Theme.base : Theme.foreground
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            NotificationStore.clearHistory();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.muted
            }

            // Empty state
            Text {
                text: "No new notifications"
                color: Theme.darkForeground
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: NotificationStore.history.length === 0
            }

            // History List
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                visible: NotificationStore.history.length > 0

                model: NotificationStore.history

                delegate: Rectangle {
                    width: listView.width
                    radius: 0
                    color: Theme.lighterBackground
                    
                    // We need a property to track expanded state
                    property bool isExpanded: false
                    
                    height: col.implicitHeight + 24

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
                                    text: modelData.timestamp
                                    color: Theme.darkForeground
                                    font.pixelSize: 10
                                }

                                Item { width: 8; height: 1 }

                                Text {
                                    text: "󰅖"
                                    color: Theme.darkForeground
                                    font.pixelSize: 14
                                    font.family: Theme.iconFont
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NotificationStore.removeHistory(modelData.notifId)
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
                                elide: isExpanded ? Text.ElideNone : Text.ElideRight
                                maximumLineCount: isExpanded ? 100 : 2
                                visible: text.length > 0
                            }
                            
                            // Expand/Collapse Button
                            Text {
                                text: isExpanded ? "Show less" : "Show more"
                                color: Theme.accent
                                font.pixelSize: 11
                                visible: modelData.body && modelData.body.length > 80
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: isExpanded = !isExpanded
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                        onClicked: {
                            if (typeof modelData.invokeDefault === "function") {
                                modelData.invokeDefault();
                            }
                            root.expanded = false;
                        }
                    }
                }
            }
        }
    }
}
