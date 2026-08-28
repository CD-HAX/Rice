import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Services.Pipewire
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PopupWindow {
    id: root

    property var anchorItem
    property bool expanded: false
    property bool outputDeviceListOpen: false
    property bool inputDeviceListOpen: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property var outputDevices: Pipewire.nodes.values.filter(n => n.audio && n.type === PwNodeType.AudioSink)
    readonly property var inputDevices: Pipewire.nodes.values.filter(n => n.audio && n.type === PwNodeType.AudioSource)

    PwObjectTracker {
        objects: [root.sink, root.source, ...root.outputDevices, ...root.inputDevices]
    }

    Component.onCompleted: {
        if (outputDevices.length > 0)
            console.log("sample output device:", JSON.stringify({
                description: outputDevices[0].description,
                nickname: outputDevices[0].nickname,
                type: outputDevices[0].type
            }));
    }

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 18

    implicitWidth: 320
    implicitHeight: 340
    color: "transparent"

    grabFocus: true
    visible: root.expanded && root.anchorItem !== null

    onVisibleChanged: {
        if (!visible) {
            root.outputDeviceListOpen = false;
            root.inputDeviceListOpen = false;
        }
    }

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
            spacing: 16

            // Header
            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: (root.sink && root.sink.audio.muted) ? "󰖁" : "󰕾"
                    color: Theme.accent
                    font.pixelSize: 22
                    font.family: Theme.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: "Audio"
                        color: Theme.foreground
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.sink ? (root.sink.description || root.sink.nickname || "").toUpperCase() : ""
                        color: Theme.darkForeground
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }
                }

                Item {
                    width: parent.width - 220
                    height: 1
                }

                // mute-everything toggle
                Rectangle {
                    id: muteToggle
                    width: 40
                    height: 22
                    radius: 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: (root.sink && root.sink.audio.muted) ? Theme.muted : Theme.accent

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 0
                        color: "#FFFFFF"
                        y: 2
                        x: (root.sink && root.sink.audio.muted) ? 2 : parent.width - width - 2

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !(root.sink && root.sink.audio.muted);
                            if (root.sink)
                                root.sink.audio.muted = newState;
                            if (root.source)
                                root.source.audio.muted = newState;
                        }
                    }
                }
            }

            // OUTPUT section
            Column {
                width: parent.width
                spacing: 8

                Row {
                    width: parent.width

                    Text {
                        text: "OUTPUT"
                        color: Theme.darkForeground
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }

                    Item {
                        width: parent.width - 120
                        height: 1
                    }

                    Text {
                        text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"
                        color: Theme.darkForeground
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }

                VolumeSlider {
                    width: parent.width
                    value: root.sink ? root.sink.audio.volume : 0
                    onMoved: newValue => {
                        if (root.sink) {
                            root.sink.audio.muted = false;
                            root.sink.audio.volume = newValue;
                        }
                    }
                }

                DeviceSelector {
                    width: parent.width
                    icon: "󰓃"
                    label: root.sink ? (root.sink.description || root.sink.nickname || "Unknown") : "No device"
                    listOpen: root.outputDeviceListOpen
                    onToggle: root.outputDeviceListOpen = !root.outputDeviceListOpen
                    devices: root.outputDevices
                    activeDevice: root.sink
                    onSelectDevice: node => {
                        Pipewire.preferredDefaultAudioSink = node;
                        root.outputDeviceListOpen = false;
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.muted
            }

            // INPUT section
            Column {
                width: parent.width
                spacing: 8

                Row {
                    width: parent.width

                    Text {
                        text: "INPUT"
                        color: Theme.darkForeground
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }

                    Item {
                        width: parent.width - 120
                        height: 1
                    }

                    Text {
                        text: root.source ? Math.round(root.source.audio.volume * 100) + "%" : "--"
                        color: Theme.darkForeground
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }

                VolumeSlider {
                    width: parent.width
                    value: root.source ? root.source.audio.volume : 0
                    onMoved: newValue => {
                        if (root.source) {
                            root.source.audio.muted = false;
                            root.source.audio.volume = newValue;
                        }
                    }
                }

                DeviceSelector {
                    width: parent.width
                    icon: "󰍬"
                    label: root.source ? (root.source.description || root.source.nickname || "Unknown") : "No device"
                    listOpen: root.inputDeviceListOpen
                    onToggle: root.inputDeviceListOpen = !root.inputDeviceListOpen
                    devices: root.inputDevices
                    activeDevice: root.source
                    onSelectDevice: node => {
                        Pipewire.preferredDefaultAudioSource = node;
                        root.inputDeviceListOpen = false;
                    }
                }
            }
        }
    }

    component VolumeSlider: Item {
        id: slider
        height: 22

        property real value: 0
        signal moved(real newValue)

        function updateFromX(x) {
            const pct = Math.max(0, Math.min(1, x / width));
            moved(pct);
        }

        Rectangle {
            id: track
            width: parent.width
            height: 6
            radius: 0
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.background

            Rectangle {
                width: track.width * slider.value
                height: parent.height
                radius: 0
                color: Theme.accent
            }

            Rectangle {
                width: 14
                height: 14
                radius: 0
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                x: track.width * slider.value - width / 2
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => slider.updateFromX(mouse.x)
            onPositionChanged: mouse => {
                if (pressed)
                    slider.updateFromX(mouse.x);
            }
        }
    }

    component DeviceSelector: Column {
        id: selector
        spacing: 4

        property string icon: ""
        property string label: ""
        property bool listOpen: false
        property var devices: []
        property var activeDevice: null
        property int keyboardIndex: -1

        signal toggle
        signal selectDevice(var node)

        onListOpenChanged: {
            if (listOpen) {
                selector.keyboardIndex = Math.max(0, selector.devices.indexOf(selector.activeDevice));
                keyNav.forceActiveFocus();
            }
        }

        Rectangle {
            width: parent.width
            height: 34
            radius: 0
            color: Theme.background

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: selector.icon
                    color: Theme.accent
                    font.pixelSize: 13
                    font.family: Theme.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    width: parent.width - 40
                    text: selector.label
                    color: Theme.foreground
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: selector.listOpen ? "󰅃" : "󰅀"
                    color: Theme.darkForeground
                    font.pixelSize: 10
                    font.family: Theme.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: selector.toggle()
            }
        }

        Item {
            id: keyNav
            width: parent.width
            height: listCol.height
            visible: selector.listOpen
            focus: selector.listOpen

            Keys.onDownPressed: selector.keyboardIndex = Math.min(selector.keyboardIndex + 1, selector.devices.length - 1)
            Keys.onUpPressed: selector.keyboardIndex = Math.max(selector.keyboardIndex - 1, 0)
            Keys.onReturnPressed: {
                if (selector.keyboardIndex >= 0 && selector.keyboardIndex < selector.devices.length)
                    selector.selectDevice(selector.devices[selector.keyboardIndex]);
            }
            Keys.onEnterPressed: {
                if (selector.keyboardIndex >= 0 && selector.keyboardIndex < selector.devices.length)
                    selector.selectDevice(selector.devices[selector.keyboardIndex]);
            }
            Keys.onEscapePressed: selector.listOpen = false

            Column {
                id: listCol
                width: parent.width
                spacing: 2

                Repeater {
                    model: selector.devices

                    Rectangle {
                        id: devRow
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 28
                        radius: 0

                        color: {
                            if (modelData === selector.activeDevice)
                                return Theme.accent;
                            if (index === selector.keyboardIndex)
                                return Theme.muted;
                            if (devMouse.containsMouse)
                                return Theme.lighterBackground;
                            return "transparent";
                        }

                        border.width: index === selector.keyboardIndex ? 1 : 0
                        border.color: Theme.accent

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            text: devRow.modelData.description || devRow.modelData.nickname || "Unknown"
                            color: devRow.modelData === selector.activeDevice ? "#FFFFFF" : Theme.foreground
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: devMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: selector.keyboardIndex = devRow.index
                            onClicked: selector.selectDevice(devRow.modelData)
                        }
                    }
                }
            }
        }
    }
}
