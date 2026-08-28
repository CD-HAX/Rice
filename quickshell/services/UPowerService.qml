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

    property var devices: []

    property Process listProc: Process {
        command: ["upower", "-e"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = this.text.split("\n").filter(p =>
                    p.trim() !== "" && !p.toLowerCase().includes("line_power")
                )
                root.devices = []
                for (const p of paths)
                    root.fetchDevice(p.trim())
            }
        }
    }

    function refresh() {
        listProc.running = false
        listProc.running = true
    }

    function fetchDevice(path) {
        let proc = Qt.createQmlObject(`
            import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows
            Process {
                command: ["upower", "-i", "${path}"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const text = this.text
                        const nameMatch = text.match(/native-path:\\s*(\\S+)/)
                        const modelMatch = text.match(/model:\\s*(.+)/)
                        const pctMatch = text.match(/percentage:\\s*(\\d+)%/)
                        const stateMatch = text.match(/state:\\s*(\\S+)/)

                        if (pctMatch) {
                            let list = root.devices.slice()
                            list.push({
                                name: modelMatch ? modelMatch[1].trim() : (nameMatch ? nameMatch[1] : "${path}"),
                                percentage: parseInt(pctMatch[1]),
                                state: stateMatch ? stateMatch[1] : "unknown"
                            })
                            root.devices = list
                        }
                    }
                }
            }
        `, root)
        proc.running = true
    }

    Component.onCompleted: refresh()

    property Timer refreshTimer: Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
