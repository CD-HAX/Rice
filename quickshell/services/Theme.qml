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
import QtCore

Singleton {
    id: theme
    property color background: "#040606"
    property color darkBackground: "#030505"
    property color darkerBackground: "#020303"
    property color lighterBackground: "#1d1f1f"
    property color base: "#1d1f1f"
    property color surface: "#626a6a"
    property color overlay: "#b0ada4"
    property color foreground: "#EBE6DA"
    property color darkForeground: "#b0ada4"
    property color lightForeground: "#eeeae0"
    property color brightForeground: "#f0ece3"
    property color accent: "#00889c"
    property color selection: "#1d1f1f"
    property color muted: "#626a6a"
    property color red: "#d45640"
    property color blue: "#00889c"
    property color green: "#a7715c"
    property color yellow: "#f1d079"
    property color magenta: "#ef6066"
    property color cyan: "#009aa3"
    property color orange: "#da6f5d"
    property color brown: "#834338"

    property string uiFont: "Roboto"
    property string monoFont: "Maple Mono"
    property string iconFont: "Symbols Nerd Font Mono"

    property string aetherFile:
        StandardPaths.writableLocation(
            StandardPaths.HomeLocation
        ) + "/.config/quickshell/services/aether-colors.conf"

    FileView {
        id: aetherWatcher
        path: theme.aetherFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const lines = text().split("\n")
            for (const line of lines)
                theme.parseLine(line)
            WallpaperService.syncFromAether()
        }
    }

    function parseLine(line) {
        line = line.trim()

        if (!line || line.startsWith("#"))
            return

        const separator = line.indexOf("=")

        if (separator === -1)
            return

        const key = line.substring(0, separator).trim()

        let value = line.substring(separator + 1).trim()

        value = value.replace(/^["']|["']$/g, "")

        if (!value.startsWith("#"))
            return

        switch (key) {
        case "background":
            theme.background = value
            break

        case "dark_background":
            theme.darkBackground = value
            break

        case "darker_background":
            theme.darkerBackground = value
            break

        case "lighter_background":
            theme.lighterBackground = value
            break

        case "foreground":
            theme.foreground = value
            break

        case "dark_foreground":
            theme.darkForeground = value
            break

        case "light_foreground":
            theme.lightForeground = value
            break

        case "bright_foreground":
            theme.brightForeground = value
            break

        case "accent":
            theme.accent = value
            break

        case "selection":
            theme.selection = value
            break

        case "muted":
            theme.muted = value
            break

        case "red":
            theme.red = value
            break

        case "blue":
            theme.blue = value
            break

        case "green":
            theme.green = value
            break

        case "yellow":
            theme.yellow = value
            break

        case "magenta":
            theme.magenta = value
            break

        case "cyan":
            theme.cyan = value
            break

        case "orange":
            theme.orange = value
            break

        case "brown":
            theme.brown = value
            break

        case "base":
            theme.base = value
            break

        case "surface":
            theme.surface = value
            break

        case "overlay":
            theme.overlay = value
            break
        }
    }
}
