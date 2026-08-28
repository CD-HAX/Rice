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

Item {
    id: root

    property var screen

    implicitWidth: background.width
    implicitHeight: background.height



    Rectangle {
        id: background

        width: audioRow.implicitWidth + 20
        height: 26
        radius: 0
        color: Theme.base
        border.width: 2
        border.color: Theme.darkForeground

        Row {
            id: audioRow

            anchors.centerIn: parent
            spacing: 10

            property var sink: Pipewire.defaultAudioSink
            property var source: Pipewire.defaultAudioSource

            PwObjectTracker {
                objects: [audioRow.sink, audioRow.source]
            }

            // OUT TEXT & CONTROLS
            Text {
                text: {
                    if (!audioRow.sink)
                        return "OUT --"

                    if (audioRow.sink.audio.muted)
                        return "󰖁 MUTED"

                    return "󰕾 " + Math.round(audioRow.sink.audio.volume * 100) + "%"
                }

                color: Theme.foreground
                font.pixelSize: 12
                font.weight: Font.Medium

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        if (!audioRow.sink)
                            return

                        if (mouse.button === Qt.LeftButton) {
                            audioPopup.expanded = !audioPopup.expanded
                        } else if (mouse.button === Qt.RightButton) {
                            audioRow.sink.audio.muted = !audioRow.sink.audio.muted
                        } else if (mouse.button === Qt.MiddleButton) {
                            Quickshell.execDetached([
                                "pavucontrol"
                            ])



                            OSD.show(
                                root.screen,
                                audioRow.sink.audio.muted ? "󰖁" : "󰕾",
                                "Volume",
                                audioRow.sink.audio.muted ? 0 : Math.round(audioRow.sink.audio.volume * 100),
                                100
                            )
                        }
                    }

                    onWheel: wheel => {
                        if (!audioRow.sink)
                            return

                        var volume = audioRow.sink.audio.volume

                        if (wheel.angleDelta.y > 0) {
                            volume = Math.min(volume + 0.05, 1.0)
                        } else if (wheel.angleDelta.y < 0) {
                            volume = Math.max(volume - 0.05, 0.0)
                        }

                        audioRow.sink.audio.volume = volume

                        OSD.show(
                            root.screen,
                            "󰕾",
                            "Volume",
                            Math.round(volume * 100),
                            100
                        )
                    }
                }
            }

            // MIC TEXT & CONTROLS
            Text {
                text: {
                    if (!audioRow.source)
                        return "MIC --"

                    if (audioRow.source.audio.muted)
                        return "󰍭 MUTED"

                    return " " + Math.round(audioRow.source.audio.volume * 100) + "%"
                }

                color: Theme.foreground
                font.pixelSize: 12
                font.weight: Font.Medium

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        if (!audioRow.source)
                            return

                        if (mouse.button === Qt.LeftButton) {
                            audioPopup.expanded = !audioPopup.expanded
                        } else if (mouse.button === Qt.RightButton) {
                            audioRow.source.audio.muted = !audioRow.source.audio.muted
                        } else if (mouse.button === Qt.MiddleButton) {
                            Quickshell.execDetached([
                                "pavucontrol", "-t", "4"
                            ])


                            OSD.show(
                                root.screen,
                                audioRow.source.audio.muted ? "󰍭" : "󰍬",
                                "Microphone",
                                audioRow.source.audio.muted ? 0 : Math.round(audioRow.source.audio.volume * 100),
                                100
                            )
                        }
                    }

                    onWheel: wheel => {
                        if (!audioRow.source)
                            return

                        var volume = audioRow.source.audio.volume

                        if (wheel.angleDelta.y > 0) {
                            volume = Math.min(volume + 0.05, 1.0)
                        } else if (wheel.angleDelta.y < 0) {
                            volume = Math.max(volume - 0.05, 0.0)
                        }

                        audioRow.source.audio.volume = volume

                        OSD.show(
                            root.screen,
                            "󰖩",
                            "Microphone",
                            Math.round(volume * 100),
                            100
                        )
                    }
                }
            }
        }
    }

    AudioPopup {
        id: audioPopup
        anchorItem: background
    }
}
