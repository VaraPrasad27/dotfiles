import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets

WrapperRectangle {
    id: root

    leftMargin: 5
    rightMargin: 5
    color: "#252324"

    readonly property var workspaces: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id)

    RowLayout {
        spacing: 4

        Repeater {
            model: root.workspaces

            delegate: Rectangle {
                id: btn
                required property var modelData
                property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id

                implicitHeight: 20
                implicitWidth: 20
                radius: 10
                color: isActive ? "#3dd1b0" : area.containsMouse ? "#903dd1b1" : "#693dd1b1"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: btn.modelData.id
                    color: btn.isActive ? "#1e1e2e" : "#e8f5f1"
                    font {
                        family: "SF Pro Display"
                        pixelSize: 11
                        weight: btn.isActive ? 700 : 500
                    }
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: btn.modelData.activate()
                }
            }
        }
    }
}
