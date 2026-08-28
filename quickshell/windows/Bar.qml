import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import QtQuick
import qs.popups
import qs.widgets
import qs.services

PanelWindow {
    id: barWindow
    screen: barScreen
    

    property var barScreen

    anchors {
        top: true
        left: false
        right: false
    }

    implicitHeight: 40
    width: 1920
    exclusiveZone: implicitHeight
    color: "transparent"
    
    
    Rectangle {
      anchors.fill: parent
      color: Theme.background

       // left island: launcher + workspaces
      Rectangle {
          id: leftIsland

          anchors {
              left: parent.left
              verticalCenter: parent.verticalCenter
              leftMargin: 8
          }

          height: implicitHeight + 28
          width: leftRow.implicitWidth + 16
          radius: 0
          color: Theme.base
          border.width: 2
          border.color: Theme.darkForeground
          z: 99

          Row {
              id: leftRow
              anchors.centerIn: parent
              spacing: 2

              LauncherButton {}

              PowerMenuButton {
                  id: powerMenuButton
                  popupWindow: powerMenu
              }

              WallpaperWidget {
              id: wallpaperButton

              popupWindow: wallpaperPopup

              }


              Workspaces {
                  screen: barWindow.barScreen
                  anchors.verticalCenter: parent.verticalCenter
              }
          }
      }

      // Center row

    Row {
        anchors.centerIn: parent
        

        Mpris {
          anchors {
              horizontalCenter: parent.width / 2
              verticalCenter: parent.width / 2
          }
          screen: barWindow.barScreen
       }
    }



      PowerMenu {
          id: powerMenu
          anchorItem: powerMenuButton
      }



      WallpaperWindow {
      id: wallpaperPopup
      targetScreen: barWindow.barScreen
      }



      NotificationToasts {
          targetScreen: barWindow.barScreen
      }



      // right cluster: each widget is already its own pill,
      // so a plain Row with spacing gives the separated-island look
      Row {
          anchors {
              right: parent.right
              verticalCenter: parent.verticalCenter
              rightMargin: 8
          }

          spacing: 8


        NotificationWindow {
            id: notifWindow
            targetScreen: barWindow.barScreen
        }

          TrayNetwork {
              screen: barWindow.barScreen
              parentWindow: barWindow
          }
          Battery {}

          NotificationWidget {
              popupWindow: notifWindow
          }

          Clock {}

          Audio {}

          Temp {}
      }



      }

   }
