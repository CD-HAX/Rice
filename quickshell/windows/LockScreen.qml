import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import QtQuick.Effects
import Quickshell.Wayland
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Services.Pam
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Services.Mpris
import qs.popups
import qs.widgets
import qs.windows
import qs.services

WlSessionLock {
    id: lock

    locked: Session.locked
    onLockedChanged: {
        if (!locked) Session.unlock()
    }

    Connections {
        target: Session
        function onLockedChanged() {
            lock.locked = Session.locked
        }
    }

    WlSessionLockSurface {
        id: surface

        property string username: Session.username
        property string password: ""
        property string errorText: ""
        property bool authenticating: false
        property bool editingUsername: false

        property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

        PamContext {
            id: pam

            onPamMessage: {
                console.log("PAM message:", this.message, "responseRequired:", this.responseRequired)
                if (!this.responseRequired) return
                this.respond(surface.password)
            }

            onCompleted: result => {
                console.log("PAM completed, result:", result)
                surface.authenticating = false
                if (result === PamResult.Success) {
                    Session.locked = false
                    surface.password = ""
                    surface.errorText = ""
                } else {
                    surface.errorText = "Incorrect password"
                    surface.password = ""
                    passwordInput.text = ""
                }
            }
        }

        function tryUnlock() {
            if (surface.authenticating) return
            surface.authenticating = true
            surface.errorText = ""
            pam.user = surface.username
            pam.start()
        }

        // background: wallpaper + blur
        Image {
            id: wallpaperImg
            anchors.fill: parent
            source: WallpaperService.activeWallpaper
                ? ("file://" + WallpaperService.activeWallpaper + "?v=" + WallpaperService.aetherVersion)
                : ""
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: wallpaperImg
            visible: wallpaperImg.source.toString().length > 0
            blurEnabled: true
            blur: 0.6
            blurMax: 48
            brightness: -0.15
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            opacity: wallpaperImg.source.toString().length > 0 ? 0.35 : 1.0
        }

        Column {
            anchors.centerIn: parent
            spacing: 22
            width: 340

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Text {
                    id: clockText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: "#FFFFFF"
                    font.pixelSize: 76
                    font.weight: Font.Bold

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                    color: "#DDDDDD"
                    font.pixelSize: 13
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 100
                radius: 50
                color: Qt.rgba(1, 1, 1, 0.08)
                clip: true
                border.width: 2
                border.color: Qt.rgba(1, 1, 1, 0.25)

                Image {
                    anchors.fill: parent
                    source: WallpaperService.activeAvatar ? ("file://" + WallpaperService.activeAvatar) : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source.toString().length > 0
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰀄"
                    font.pixelSize: 42
                    color: "#FFFFFF"
                    visible: !WallpaperService.activeAvatar
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                visible: surface.player !== null

                Rectangle {
                    width: 38
                    height: 38
                    radius: 9
                    color: Qt.rgba(1, 1, 1, 0.08)
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: surface.player && surface.player.trackArtUrl ? surface.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: surface.player ? (surface.player.trackTitle || "") : ""
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: 220
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                width: parent.width

                // username — click to edit, defaults to current session user
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: usernameInput.activeFocus ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(1, 1, 1, 0.15)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "󰀉"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: usernameInput
                            width: parent.width - 30
                            anchors.verticalCenter: parent.verticalCenter
                            text: surface.username
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            selectByMouse: true
                            onTextChanged: surface.username = text
                            KeyNavigation.tab: passwordInput
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: passwordInput.activeFocus ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(1, 1, 1, 0.15)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "󰌾"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: passwordInput
                            width: parent.width - 30
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            echoMode: TextInput.Password
                            focus: true
                            selectByMouse: true

                            onTextChanged: surface.password = text
                            Keys.onReturnPressed: surface.tryUnlock()
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: surface.authenticating ? "Checking…" : surface.errorText
                    color: surface.errorText ? "#ff6b6b" : "#DDDDDD"
                    font.pixelSize: 11
                    height: 16
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                visible: UPowerService.devices.length > 0

                Repeater {
                    model: UPowerService.devices

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Text {
                            text: modelData.state === "charging" ? "󰂄" : "󰁹"
                            color: "#DDDDDD"
                            font.pixelSize: 12
                        }
                        Text {
                            text: modelData.name + " — " + modelData.percentage + "%"
                            color: "#DDDDDD"
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: passwordInput.forceActiveFocus()
            z: -1
        }
    }
}
