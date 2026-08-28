pragma Singleton

import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows
import QtQuick

Scope {
    id: root

    property bool active: false

    function toggle() { root.active = !root.active }
    function open() { root.active = true }
    function close() { root.active = false }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
    }
}
