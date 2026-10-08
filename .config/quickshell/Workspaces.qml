import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets

WrapperRectangle {
    Layout.fillHeight: true
    leftMargin: 10
    rightMargin: 10
    color: "#252324"

    RowLayout {
        spacing: 6

        Repeater {
            model: 9

            Rectangle {
                id: wsButton
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                implicitHeight: 10
                implicitWidth: 10
                radius: 10
                color: isActive ? "#3dd1b0" : (ws ? "#693dd1b1" : '#103dd1b1')

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
