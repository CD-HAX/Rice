import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Widgets
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Services.SystemTray
import qs.popups
import qs.widgets
import qs.windows
import qs.services

Item {
    id: root

    property var screen
    property var parentWindow: null
    property bool popupOpen: false

    implicitWidth: background.width
    implicitHeight: background.height

    Rectangle {
        id: background

        width: mainRow.implicitWidth + 16
        height: 26
        radius: 0
        color: Theme.base
        border.width: 2
        border.color: Theme.darkForeground

        Row {
            id: mainRow
            anchors.centerIn: parent
            spacing: 8

            // System Tray Items Block
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: SystemTray.items

                    delegate: Item {
                        id: itemDelegate
                        required property var modelData

                        width: 20
                        height: 20

                        // Check if this item is NetworkManager / Network
                        property bool isNetworkItem: {
                            const idStr = (modelData.id || modelData.title || "").toLowerCase();
                            return idStr.includes("network") || idStr.includes("nm-applet");
                        }

                        // 1. Force Font Glyph for NetworkManager
                        Text {
                            anchors.centerIn: parent
                            text: "󰈀"
                            color: Theme.foreground
                            font.pixelSize: 14
                            visible: itemDelegate.isNetworkItem || trayIcon.status !== Image.Ready
                        }

                        // 2. Regular Icon for everything else
                        IconImage {
                            id: trayIcon
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            source: itemDelegate.modelData.icon
                            visible: !itemDelegate.isNetworkItem && status === Image.Ready
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: mouse => {
                                const targetWin = root.parentWindow ?? root.Window.window;
                                if (mouse.button === Qt.RightButton) {
                                    if (modelData.hasMenu && targetWin) {
                                        const globalPos = mapToItem(targetWin.contentItem, mouse.x, mouse.y);
                                        modelData.display(targetWin, globalPos.x, globalPos.y);
                                    }
                                } else if (mouse.button === Qt.LeftButton) {
                                    modelData.activate();
                                }
                            }
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 14
                color: Theme.muted
                anchors.verticalCenter: parent.verticalCenter
                visible: SystemTray.items.length > 0
            }

            // Speed Block with Fixed Widths
            Item {
                implicitWidth: speedsRow.implicitWidth
                implicitHeight: speedsRow.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: speedsRow
                    spacing: 6
                    anchors.centerIn: parent

                    Text {
                        text: "󰇚 " + NetworkService.rxRate
                        color: Theme.foreground
                        font.pixelSize: 11
                        font.family: Theme.monoFont
                        width: 65
                        horizontalAlignment: Text.AlignLeft
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "󰕒 " + NetworkService.txRate
                        color: Theme.foreground
                        font.pixelSize: 11
                        font.family: Theme.monoFont
                        width: 65
                        horizontalAlignment: Text.AlignLeft
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.popupOpen = !root.popupOpen
                }
            }
        }
    }

    NetworkPopup {
        id: popup
        anchorItem: background
        targetScreen: root.screen
        expanded: root.popupOpen

        onClosed: root.popupOpen = false
    }
}
