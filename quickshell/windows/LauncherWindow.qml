import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Wayland
import qs.popups
import qs.widgets
import qs.windows
import QtQuick
import qs.services

PanelWindow {
    id: root

    visible: Launcher.active

    property var results: {
        const all = [...DesktopEntries.applications.values]
            .filter(d => d.name)
            .sort((a, b) => a.name.localeCompare(b.name))

        const q = search.text.trim().toLowerCase()
        if (q === "") return all

        return all.filter(d => {
            const name = (d.name || "").toLowerCase()
            const comment = (d.comment || "").toLowerCase()
            return name.includes(q) || comment.includes(q)
        })
    }

    property int currentIndex: 0
    onResultsChanged: currentIndex = 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "launcher"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Component.onCompleted: search.forceActiveFocus()

    MouseArea {
        anchors.fill: parent
        onClicked: Launcher.close()
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width: 560
        height: 420
        radius: 16
        color: Theme.background
        opacity: 0.97
        border.width: 1
        border.color: Theme.muted

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Rectangle {
                width: parent.width
                height: 40
                radius: 10
                color: Theme.lighterBackground

                TextInput {
                    id: search

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter

                    color: Theme.foreground
                    font.pixelSize: 14
                    clip: true

                    Text {
                        text: "Search apps…"
                        color: Theme.darkForeground
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text.length === 0
                    }

                    Keys.onEscapePressed: Launcher.close()

                    Keys.onDownPressed: root.currentIndex =
                        Math.min(root.currentIndex + 1, root.results.length - 1)

                    Keys.onUpPressed: root.currentIndex =
                        Math.max(root.currentIndex - 1, 0)

                    Keys.onReturnPressed: {
                        const app = root.results[root.currentIndex]
                        if (app) {
                            app.execute()
                            Launcher.close()
                        }
                    }
                }
            }

            ListView {
                width: parent.width
                height: parent.height - 52
                clip: true
                spacing: 2

                model: root.results
                currentIndex: root.currentIndex

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 44
                    radius: 8
                    color: index === root.currentIndex ? Theme.lighterBackground : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            source: Quickshell.iconPath(modelData.icon, true)
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: modelData.name
                                color: Theme.foreground
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }

                            Text {
                                text: modelData.comment ?? ""
                                color: Theme.darkForeground
                                font.pixelSize: 11
                                visible: text.length > 0
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modelData.execute()
                            Launcher.close()
                        }
                    }
                }
            }
        }
    }
}
