pragma Singleton
import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows

QtObject {
    id: root

    property string username: ""
    property string uptime: "00:00"
    property bool locked: false

    property Process userProc: Process {
        command: ["whoami"]
        stdout: StdioCollector {
            onStreamFinished: root.username = this.text.trim()
        }
    }

    property Process uptimeProc: Process {
        command: ["/bin/bash", "-c", "awk '{print int($1/3600)\":\"int(($1%3600)/60)}' /proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(":")
                const h = parts[0].padStart(2, "0")
                const m = parts[1].padStart(2, "0")
                root.uptime = h + ":" + m
            }
        }
    }

    property Timer uptimeTimer: Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            uptimeProc.running = false
            uptimeProc.running = true
        }
    }

    Component.onCompleted: userProc.running = true

    function lock() { root.locked = true }
    function unlock() { root.locked = false }

    function suspend() { Quickshell.execDetached(["systemctl", "suspend"]) }
    function reboot() { Quickshell.execDetached(["systemctl", "reboot"]) }
    function shutdown() { Quickshell.execDetached(["systemctl", "poweroff"]) }
}
