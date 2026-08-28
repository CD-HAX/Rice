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
import Quickshell.Services.Mpris
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PanelWindow {
    id: root

    property var targetScreen
    property bool shouldShow: Player.expanded && Player.screen === root.targetScreen
    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property real localPosition: 0

    screen: root.targetScreen

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    implicitHeight: 500
    color: "transparent"
    visible: true
    mask: root.shouldShow ? null : emptyMask

    Region {
        id: emptyMask
    }

    Timer {
        id: posTimer
        interval: 1000
        repeat: true
        running: Boolean(root.player && root.player.isPlaying) && root.shouldShow
        onTriggered: {
            if (root.player)
                root.localPosition = Math.min(root.localPosition + 1, root.player.length || 0);
        }
    }

    Connections {
        target: root.player
        function onPositionChanged() {
            root.localPosition = root.player.position;
        }
        function onTrackTitleChanged() {
            root.localPosition = root.player ? root.player.position : 0;
        }
    }

    onShouldShowChanged: {
        if (shouldShow) {
            dismissArea.forceActiveFocus();
            if (root.player)
                root.localPosition = root.player.position;
        }
    }

    // click or press any key outside the card to dismiss
    Item {
        id: dismissArea
        anchors.fill: parent
        z: 0

        Keys.onPressed: event => {
            Player.close();
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.shouldShow
            onClicked: Player.close()
        }
    }

    Rectangle {
        id: card
        z: 1

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.shouldShow ? 48 : -300
        width: 340
        height: 280
        radius: 0
        color: Theme.base
        opacity: root.shouldShow ? 0.97 : 0
        border.width: 1
        border.color: Theme.muted

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        MouseArea {
            anchors.fill: parent
            z: 0
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.4
            shadowBlur: 0.7
            shadowVerticalOffset: 8
        }

        Behavior on y {
            NumberAnimation {
                duration: root.shouldShow ? 500 : 200
                easing.type: root.shouldShow ? Easing.OutBack : Easing.InQuad
                easing.overshoot: 1.3
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14
            visible: root.player !== null

            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    id: artFrame

                    width: 84
                    height: 84

                    radius: 0

                    color: Theme.lighterBackground

                    clip: true

                    Image {
                        id: albumArt

                        anchors.fill: parent

                        source: root.player ? root.player.trackArtUrl : ""

                        fillMode: Image.PreserveAspectCrop

                        asynchronous: true

                        cache: false

                        visible: status === Image.Ready

                        onStatusChanged: {
                            console.log("MPRIS artwork:", source, "status:", status);
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: "󰝚"

                        color: Theme.darkForeground

                        font.pixelSize: 28
                        font.family: Theme.iconFont

                        visible: albumArt.status !== Image.Ready
                    }
                }

                Column {
                    width: parent.width - 84 - 12
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        width: parent.width
                        text: root.player ? (root.player.trackTitle || "Unknown Title") : ""
                        color: Theme.foreground
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.player ? (root.player.trackArtist || "Unknown Artist") : ""
                        color: Theme.darkForeground
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: 3
                        topPadding: 6

                        Repeater {
                            model: 12

                            Rectangle {
                                width: 3
                                radius: 1.5
                                color: Theme.accent
                                height: 4

                                Timer {
                                    running: Boolean(root.player && root.player.isPlaying)
                                    repeat: true
                                    interval: 180 + Math.random() * 140
                                    onTriggered: parent.height = 4 + Math.random() * 20
                                }

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Rectangle {
                    id: seekTrack
                    width: parent.width
                    height: 6
                    radius: 0
                    color: Theme.lighterBackground

                    Rectangle {
                        width: (root.player && root.player.length > 0) ? seekTrack.width * Math.max(0, Math.min(1, root.localPosition / root.player.length)) : 0
                        height: parent.height
                        radius: 0
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (root.player && root.player.length > 0) {
                                const newPos = (mouse.x / width) * root.player.length;
                                root.player.position = newPos;
                                root.localPosition = newPos;
                            }
                        }
                    }
                }

                Row {
                    width: parent.width

                    Text {
                        text: formatTime(root.localPosition)
                        color: Theme.darkForeground
                        font.pixelSize: 10
                    }

                    Item {
                        width: parent.width - 80
                        height: 1
                    }

                    Text {
                        text: root.player ? formatTime(root.player.length) : "0:00"
                        color: Theme.darkForeground
                        font.pixelSize: 10
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24

                Text {
                    text: "󰒮"
                    color: Boolean(root.player && root.player.canGoPrevious) ? Theme.foreground : Theme.darkForeground
                    font.pixelSize: 20
                    font.family: Theme.iconFont

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player && root.player.canGoPrevious)
                            root.player.previous()
                    }
                }

                Text {
                    text: Boolean(root.player && root.player.isPlaying) ? "󰏤" : "󰐊"
                    color: Theme.accent
                    font.pixelSize: 26
                    font.family: Theme.iconFont

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player)
                            root.player.togglePlaying()
                    }
                }

                Text {
                    text: "󰒭"
                    color: Boolean(root.player && root.player.canGoNext) ? Theme.foreground : Theme.darkForeground
                    font.pixelSize: 20
                    font.family: Theme.iconFont

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player && root.player.canGoNext)
                            root.player.next()
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: "󰕾"
                    color: Theme.foreground
                    font.pixelSize: 14
                    font.family: Theme.iconFont
                }

                Rectangle {
                    id: volTrack
                    width: parent.width - 30
                    height: 6
                    radius: 0
                    color: Theme.lighterBackground
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: root.player ? volTrack.width * (root.player.volume ?? 0) : 0
                        height: parent.height
                        radius: 0
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (root.player)
                                root.player.volume = Math.max(0, Math.min(1, mouse.x / width));
                        }

                        onWheel: wheel => {
                            if (!root.player)
                                return;
                            const step = 0.05;
                            const delta = wheel.angleDelta.y > 0 ? step : -step;
                            root.player.volume = Math.max(0, Math.min(1, (root.player.volume ?? 0) + delta));
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "No media playing"
            color: Theme.darkForeground
            font.pixelSize: 13
            visible: root.player === null
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
}
