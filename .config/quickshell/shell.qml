import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    PanelWindow {
        id: root

        implicitHeight: 30
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            anchors.rightMargin: 2

            Workspaces {
                radius: root.implicitHeight / 2
            }

            Clock {
                radius: root.implicitHeight / 2
            }

            Item {
                Layout.fillWidth: true
            }

            WrapperRectangle {
                Layout.fillHeight: true
                leftMargin: 10
                rightMargin: 10
                radius: root.implicitHeight / 2
                color: "#252324"
                RowLayout {
                    spacing: 9
                    Bluetooth {}
                    Volume {}
                    Network {}
                    Battery {}
                }
            }
        }
    }
}
