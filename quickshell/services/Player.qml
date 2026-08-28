pragma Singleton
import QtQuick

QtObject {
property bool expanded: false
property var screen: null
property var anchorItem: null

function toggle(targetScreen, item) {
    if (expanded && screen === targetScreen) {
        close()
        return
    }


    screen = targetScreen
    anchorItem = item
    expanded = true
}


function close() {
    expanded = false
    screen = null
    anchorItem = null
}

}
