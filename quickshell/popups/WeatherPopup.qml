import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PopupWindow {
    id: root

    property var anchorItem
    property var targetScreen
    property bool expanded: false
    property bool editingLocation: false
    property int selectedIndex: -1

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 18

    implicitWidth: 380
    implicitHeight: 180
    color: "transparent"

    grabFocus: true
    visible: root.expanded && root.anchorItem !== null

    onVisibleChanged: {
        if (!visible) {
            root.editingLocation = false;
            suggestModel.clear();
        }
    }

    ListModel {
        id: suggestModel
    }

    Process {
        id: dbProc
        command: ["/bin/bash", "-c", dbProc.queryScript]
        property string queryScript: ""

        stdout: StdioCollector {
            onStreamFinished: {
                suggestModel.clear()
                const lines = this.text.split("\n").filter(l => l.trim() !== "")
                for (const line of lines)
                    suggestModel.append({ "cityName": line.trim() })
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "")
                    console.error("SQLite Error:", this.text)
            }
        }
    }

    function updateSuggestions(query) {
        suggestModel.clear();
        root.selectedIndex = -1;

        if (!query || query.trim() === "") return;

        let cleanQuery = query.trim().replace(/'/g, "''");
        let dbPath = `${Quickshell.shellDir}/assets/cities.db`.replace(/^file:\/\//, "");

        dbProc.queryScript = `sqlite3 "${dbPath}" "SELECT DISTINCT name FROM cities WHERE name LIKE '${cleanQuery}%' ORDER BY name ASC LIMIT 6;"`;

        dbProc.running = false;
        dbProc.running = true;
    }

    Rectangle {
        id: mainCard
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

            Row {
                width: parent.width

                Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: WeatherService.weatherIcon
                        color: Theme.foreground
                        font.pixelSize: 42
                        font.family: Theme.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: WeatherService.currentTemp
                        color: Theme.foreground
                        font.pixelSize: 40
                        font.weight: Font.Bold
                        font.family: Theme.monoFont
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item {
                    width: parent.width - 290
                    height: 1
                }

                Column {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        width: 130
                        height: 20
                        anchors.right: parent.right
                        z: 10

                        Row {
                            spacing: 4
                            anchors.right: parent.right

                            Text {
                                text: "󰍎"
                                color: Theme.darkForeground
                                font.pixelSize: 11
                                font.family: Theme.iconFont
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                visible: !root.editingLocation
                                text: WeatherService.location
                                color: Theme.foreground
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                font.letterSpacing: 1
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.editingLocation = true;
                                        locInput.text = WeatherService.location;
                                        locInput.forceActiveFocus();
                                        root.updateSuggestions(locInput.text);
                                    }
                                }
                            }

                            Rectangle {
                                id: inputContainer
                                visible: root.editingLocation
                                width: 130
                                height: 20
                                radius: 0
                                color: Theme.background
                                border.width: 1
                                border.color: Theme.accent
                                anchors.verticalCenter: parent.verticalCenter

                                TextInput {
                                    id: locInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 4
                                    anchors.rightMargin: 4
                                    verticalAlignment: Text.AlignVCenter
                                    color: Theme.foreground
                                    font.pixelSize: 10
                                    selectByMouse: true

                                    onTextChanged: {
                                        if (root.editingLocation) {
                                            root.updateSuggestions(text);
                                        }
                                    }

                                    Keys.onDownPressed: {
                                        if (suggestModel.count > 0) {
                                            root.selectedIndex = (root.selectedIndex + 1) % suggestModel.count;
                                        }
                                    }

                                    Keys.onUpPressed: {
                                        if (suggestModel.count > 0) {
                                            root.selectedIndex = (root.selectedIndex - 1 + suggestModel.count) % suggestModel.count;
                                        }
                                    }

                                    Keys.onReturnPressed: selectAndSubmit()
                                    Keys.onEnterPressed: selectAndSubmit()

                                    function selectAndSubmit() {
                                        if (root.selectedIndex >= 0 && root.selectedIndex < suggestModel.count) {
                                            WeatherService.updateLocation(suggestModel.get(root.selectedIndex).cityName);
                                        } else if (text.trim() !== "") {
                                            WeatherService.updateLocation(text);
                                        }
                                        root.editingLocation = false;
                                        suggestModel.clear();
                                    }

                                    Keys.onEscapePressed: {
                                        root.editingLocation = false;
                                        suggestModel.clear();
                                    }
                                }

                                // Anchored dropdown directly beneath inputContainer with solid background
                                Rectangle {
                                    id: suggestBox
                                    visible: root.editingLocation && suggestModel.count > 0
                                    width: parent.width
                                    height: Math.min(suggestModel.count * 24, 120)

                                    anchors.top: parent.bottom
                                    anchors.topMargin: 4
                                    anchors.left: parent.left

                                    property color themedBg: Theme.background
                                    color: themedBg

                                    opacity: 1.0
                                    border.width: 1
                                    border.color: Theme.accent
                                    radius: 0
                                    clip: true
                                    z: 99999
                                    ListView {
                                        id: suggestList
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        model: suggestModel
                                        clip: true
                                        currentIndex: root.selectedIndex

                                        delegate: Rectangle {
                                            width: ListView.view.width
                                            radius: 0
                                            height: 24
                                            color: index === root.selectedIndex ? Theme.accent : (itemMouse.containsMouse ? Theme.lighterBackground : "transparent")

                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: 6
                                                anchors.rightMargin: 6
                                                verticalAlignment: Text.AlignVCenter
                                                text: model.cityName
                                                color: index === root.selectedIndex ? "#FFFFFF" : Theme.foreground
                                                font.pixelSize: 9
                                                elide: Text.ElideRight
                                            }

                                            MouseArea {
                                                id: itemMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: {
                                                    WeatherService.updateLocation(model.cityName);
                                                    root.editingLocation = false;
                                                    suggestModel.clear();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 14
                        anchors.right: parent.right

                        DetailColumn { label: "FEELS"; value: WeatherService.feelsLike }
                        DetailColumn { label: "WIND"; value: WeatherService.windSpeed }
                        DetailColumn { label: "HUMID"; value: WeatherService.humidity }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.muted
            }

            Row {
                width: parent.width
                spacing: 0

                Repeater {
                    model: WeatherService.forecast

                    delegate: Item {
                        width: parent.width / 3
                        height: 40

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: modelData.icon
                                color: Theme.foreground
                                font.pixelSize: 22
                                font.family: Theme.iconFont
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: modelData.day
                                    color: Theme.darkForeground
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }

                                Row {
                                    spacing: 4

                                    Text {
                                        text: modelData.high
                                        color: Theme.foreground
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: modelData.low
                                        color: Theme.darkForeground
                                        font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DetailColumn: Column {
        property string label: ""
        property string value: ""

        spacing: 2

        Text {
            text: label
            color: Theme.darkForeground
            font.pixelSize: 8
            font.weight: Font.Bold
            font.letterSpacing: 1
        }

        Text {
            text: value
            color: Theme.foreground
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.family: Theme.monoFont
        }
    }
}
