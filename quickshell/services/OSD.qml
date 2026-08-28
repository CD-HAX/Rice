pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool active: false
    property string label: ""
    property string icon: ""
    property real value: 0
    property real maximum: 100
    property var screen: null

    function show(targetScreen, newIcon, newLabel, newValue, newMax) {
        screen = targetScreen
        icon = newIcon
        label = newLabel
        value = newValue
        maximum = newMax
        active = true
        hideTimer.restart()
    }

    property Timer hideTimer: Timer {
        interval: 2000
        onTriggered: root.active = false
    }
}
