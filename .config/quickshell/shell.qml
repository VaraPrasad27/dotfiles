import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    PanelWindow {
        id: root

        implicitHeight: 28
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 2
            left: 2
            right: 2
        }

        RowLayout {
            anchors.fill: parent
            spacing: 3

            StartMenu {
                implicitHeight: root.implicitHeight
                implicitWidth: root.implicitHeight
                radius: root.implicitHeight / 2
            }

            Workspaces {
                radius: root.implicitHeight / 2
            }

            Active {
                implicitHeight: root.implicitHeight
                radius: root.implicitHeight / 2
                color: "#252324"
            }

            Clock {
                radius: root.implicitHeight / 2
            }

            Item {
                Layout.fillWidth: true
            }

            SysTray {
                implicitWidth: root.implicitHeight
                radius: root.implicitHeight / 2
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
                    Network {
                        MouseArea {
                            anchors.fill: parent
                            onClicked: netPop.visible = !netPop.visible
                        }
                    }
                    Battery {}
                }
            }
            More {
                implicitHeight: root.implicitHeight
                implicitWidth: root.implicitHeight
                radius: root.implicitHeight / 2
            }
        }

        NetPopup {
            id: netPop
            anchor.window: root
        }
    }
}
