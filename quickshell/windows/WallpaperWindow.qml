import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Wayland
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PanelWindow {
    id: root

    property bool expanded: false
    property string searchQuery: ""
    property string activeTab: "Wallpaper"
    property bool editingDir: false

    property var targetScreen
    screen: targetScreen

    visible: root.expanded

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "wallpaper_osd"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            WallpaperService.reload();
            WallpaperService.reloadAvatars();
            searchInput.forceActiveFocus();
        } else {
            root.searchQuery = "";
            root.editingDir = false;
            searchInput.text = "";
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = false
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width: 720
        height: 520
        radius: 0
        color: Theme.base
        opacity: 0.8
        border.width: 1
        border.color: Theme.muted
        clip: true

        // Removed Noise/Grain Background

        MouseArea { anchors.fill: parent }

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Header: title, search, tabs, directory + refresh
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Wallpaper"
                    color: Theme.foreground
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 28
                    radius: 0
                    color: Theme.background
                    border.width: 1
                    border.color: searchInput.activeFocus ? Theme.accent : Theme.muted

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: "󰍉"
                            color: Theme.darkForeground
                            font.pixelSize: 12
                            font.family: Theme.iconFont
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.foreground
                            font.pixelSize: 11
                            selectByMouse: true

                            onTextChanged: root.searchQuery = text.trim().toLowerCase()

                            Text {
                                text: "Filter…"
                                color: Theme.darkForeground
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                                visible: searchInput.text.length === 0
                            }

                            Keys.onEscapePressed: root.expanded = false
                        }
                    }
                }

                Row {
                    spacing: 4

                    Repeater {
                        model: ["Wallpaper", "Avatar", "Favorites"]

                        Rectangle {
                            height: 26
                            width: tabText.implicitWidth + 18
                            radius: 0
                            color: root.activeTab === modelData ? Theme.accent : "transparent"

                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData
                                color: root.activeTab === modelData ? "#FFFFFF" : Theme.darkForeground
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeTab = modelData;
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Change directory button
                Rectangle {
                    Layout.preferredWidth: dirMouse.containsMouse || root.editingDir ? 28 + dirLabel.width + 8 : 28
                    Layout.preferredHeight: 28
                    radius: 0
                    color: dirMouse.containsMouse || root.editingDir ? Theme.background : "transparent"
                    clip: true
                    
                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰉋"
                            color: Theme.foreground
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: dirLabel
                            text: "Change Folder"
                            color: Theme.foreground
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            visible: dirMouse.containsMouse || root.editingDir
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: dirMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.editingDir = !root.editingDir;
                            if (root.editingDir)
                                dirInput.text = root.activeTab === "Avatar"
                                    ? WallpaperService.avatarDir
                                    : WallpaperService.wallpaperDir;
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: aetherMouse.containsMouse ? 28 + aetherLabel.width + 8 : 28
                    Layout.preferredHeight: 28
                    radius: 0
                    color: aetherMouse.containsMouse ? Theme.background : "transparent"
                    clip: true
                    
                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰏘"
                            color: Theme.accent
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: aetherLabel
                            text: "Aether Colors"
                            color: Theme.accent
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            visible: aetherMouse.containsMouse
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: aetherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WallpaperService.launchAetherGUI();
                            root.expanded = false;
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: carouselMouse.containsMouse ? 28 + carouselLabel.width + 8 : 28
                    Layout.preferredHeight: 28
                    radius: 0
                    color: carouselMouse.containsMouse ? Theme.background : "transparent"
                    clip: true
                    
                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰋩"
                            color: Theme.accent
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: carouselLabel
                            text: "Carousel"
                            color: Theme.accent
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            visible: carouselMouse.containsMouse
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: carouselMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WallpaperService.launchAetherCarousel();
                            root.expanded = false;
                        }
                    }
                }

                // Refresh
                Rectangle {
                    Layout.preferredWidth: refreshMouse.containsMouse ? 28 + refreshLabel.width + 8 : 28
                    Layout.preferredHeight: 28
                    radius: 0
                    color: refreshMouse.containsMouse ? Theme.background : "transparent"
                    clip: true
                    
                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰑐"
                            color: Theme.foreground
                            font.pixelSize: 13
                            font.family: Theme.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: refreshLabel
                            text: "Reload"
                            color: Theme.foreground
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            visible: refreshMouse.containsMouse
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.reload()
                    }
                }
            }

            // Directory path editor
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                visible: root.editingDir
                radius: 0
                color: Theme.background
                border.width: 1
                border.color: dirInput.activeFocus ? Theme.accent : Theme.muted

                TextInput {
                    id: dirInput
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.foreground
                    font.pixelSize: 11
                    selectByMouse: true

                    Keys.onReturnPressed: {
                        if (root.activeTab === "Avatar")
                            WallpaperService.setAvatarDir(text);
                        else
                            WallpaperService.setWallpaperDir(text);
                        root.editingDir = false;
                    }
                    Keys.onEscapePressed: root.editingDir = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.muted
            }

            // --- Wallpaper Grid Container ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.activeTab === "Wallpaper" || root.activeTab === "Favorites"
                
                GridView {
                    id: grid
                    anchors.fill: parent
                    anchors.rightMargin: 8 // Space for scrollbar
                    cellWidth: 165
                    cellHeight: 125
                    clip: true
                    
                    property real savedContentY: 0
                    
                    onModelChanged: {
                        grid.contentY = grid.savedContentY;
                    }

                    model: {
                        let all = WallpaperService.wallpapers;
                        return all.filter(item => {
                            let matchesSearch = root.searchQuery === "" || item.name.toLowerCase().includes(root.searchQuery);
                            let matchesFav = root.activeTab !== "Favorites" || item.favorite;
                            return matchesSearch && matchesFav;
                        });
                    }

                    delegate: Item {
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 4

                            Rectangle {
                                id: thumb
                                width: parent.width
                                height: parent.width * 0.62
                                radius: 0
                                color: Theme.background
                                border.width: itemMouse.containsMouse || WallpaperService.activeWallpaper === modelData.path ? 3 : 2
                                border.color: itemMouse.containsMouse || WallpaperService.activeWallpaper === modelData.path ? Theme.accent : Theme.background
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: modelData.fileUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                Rectangle {
                                    id: starBadge
                                    width: favMouse.containsMouse ? 20 + favLabel.width + 6 : 20
                                    height: 20
                                    radius: 0
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 4
                                    color: Qt.rgba(0, 0, 0, 0.5)
                                    clip: true
                                    z: 10
                                    
                                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            text: modelData.favorite ? "★" : "☆"
                                            color: modelData.favorite ? "#FFD166" : "#FFFFFF"
                                            font.pixelSize: 11
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            id: favLabel
                                            text: modelData.favorite ? "Unfavorite" : "Favorite"
                                            color: "#FFFFFF"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            visible: favMouse.containsMouse
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: favMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            grid.savedContentY = grid.contentY;
                                            WallpaperService.toggleFavorite(modelData.path);
                                        }
                                    }
                                }



                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        WallpaperService.applyWallpaper(modelData.path);
                                        root.expanded = false;
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: modelData.name
                                color: Theme.darkForeground
                                font.pixelSize: 9
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideMiddle
                            }
                        }
                    }
                }
                
                // Custom Scrollbar for Wallpapers
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: "transparent"
                    visible: grid.contentHeight > grid.height

                    Rectangle {
                        width: parent.width
                        radius: 0
                        color: Theme.accent
                        
                        height: Math.max(20, (grid.height / grid.contentHeight) * parent.height)
                        y: (grid.contentY / Math.max(1, grid.contentHeight - grid.height)) * (parent.height - height)
                    }
                }
            }

            // --- Avatar Grid Container ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.activeTab === "Avatar"
                
                GridView {
                    id: avatarGrid
                    anchors.fill: parent
                    anchors.rightMargin: 8
                    cellWidth: 100
                    cellHeight: 100
                    clip: true

                    model: WallpaperService.avatars.filter(item => root.searchQuery === "" || item.name.toLowerCase().includes(root.searchQuery))

                    delegate: Item {
                        width: avatarGrid.cellWidth
                        height: avatarGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 6
                            radius: 0
                            color: Theme.background
                            border.width: avMouse.containsMouse || WallpaperService.activeAvatar === modelData.path ? 3 : 2
                            border.color: avMouse.containsMouse || WallpaperService.activeAvatar === modelData.path ? Theme.accent : Theme.background
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: modelData.fileUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                            }

                            MouseArea {
                                id: avMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    WallpaperService.setAvatar(modelData.path);
                                    root.expanded = false;
                                }
                            }
                        }
                    }
                }
                
                // Custom Scrollbar for Avatars
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: "transparent"
                    visible: avatarGrid.contentHeight > avatarGrid.height

                    Rectangle {
                        width: parent.width
                        radius: 0
                        color: Theme.accent
                        
                        height: Math.max(20, (avatarGrid.height / avatarGrid.contentHeight) * parent.height)
                        y: (avatarGrid.contentY / Math.max(1, avatarGrid.contentHeight - avatarGrid.height)) * (parent.height - height)
                    }
                }
            }
        }
    }
}
