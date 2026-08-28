//@ pragma UseQApplication

import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Hyprland
import qs.popups
import qs.widgets
import qs.windows
import Quickshell._Window
import qs.popups
import qs.widgets
import qs.windows
import QtQuick

import qs.windows
import qs.popups
import qs.widgets
import qs.services

ShellRoot {
    LockScreen {}

    Variants {
        model: Quickshell.screens

        delegate: Bar {
            property var modelData

            screen: modelData
            barScreen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: OSDWindow {
            property var modelData

            targetScreen: modelData
        }
    }

    // Launcher Window Loader
    LazyLoader {
        active: Launcher.active

        LauncherWindow {}
    }

    // Media Player Window (Static instantiation per screen - no dynamic destruction crashes)
    Variants {
        model: Quickshell.screens
        delegate: MediaPlayerWindow {
            property var modelData
            targetScreen: modelData
        }
    }
}
