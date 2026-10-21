import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

PopupWindow {
    id: root
    property int openMenus: 0
    required property Item target   // the toggle button to hang under

    anchor.item: target
    anchor.rect.x: target.width
    anchor.rect.y: target.height + 4
    anchor.gravity: Edges.Bottom | Edges.Left   // grows down and to the left

    implicitWidth: grid.implicitWidth + 24
    implicitHeight: grid.implicitHeight + 24
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        GridLayout {
            id: grid
            anchors.centerIn: parent
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    id: cell
                    required property SystemTrayItem modelData

                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 8
                    color: cellHover.containsMouse ? "#2b2d3f" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize: Qt.size(40, 40)
                        source: cell.modelData.icon
                    }

                    QsMenuAnchor {
                        id: menuAnchor
                        menu: cell.modelData.menu
                        anchor.window: QsWindow.window
                        anchor.item: cell
                        onVisibleChanged: root.openMenus += visible ? 1 : -1
                    }

                    MouseArea {
                        id: cellHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (cell.modelData.onlyMenu && cell.modelData.hasMenu)
                                    menuAnchor.open();
                                else
                                    cell.modelData.activate();
                            } else if (mouse.button === Qt.MiddleButton) {
                                cell.modelData.secondaryActivate();
                            } else if (cell.modelData.hasMenu) {
                                menuAnchor.open();
                            }
                        }
                        onWheel: w => cell.modelData.scroll(w.angleDelta.y, false)
                    }
                }
            }
        }
    }
}
