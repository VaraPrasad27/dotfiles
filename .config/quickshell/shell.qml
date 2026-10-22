import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland

ShellRoot {
    PanelWindow {
        id: root

        readonly property int barHeight: 30
        readonly property int flareSize: 10

        implicitHeight: barHeight + flareSize
        exclusiveZone: barHeight
        mask: Region {
            item: row
        }
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 0
            left: 0
            right: 0
        }

        RowLayout {
            id: row
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                // bottom: parent.bottom
            }
            height: root.barHeight
            spacing: 3

            FlaredRect {
                Layout.fillHeight: true
                implicitWidth: ri.implicitWidth + 3
                topLeft: "square"
                topRight: "flare"
                bottomLeft: "flare"
                bottomRight: "round"

                RowLayout {
                    id: ri
                    anchors.centerIn: parent
                    spacing: 3
                    StartMenu {
                        implicitHeight: root.barHeight - 2
                        implicitWidth: root.barHeight - 2
                        radius: root.barHeight / 2
                    }
                    Workspaces {
                        implicitHeight: root.barHeight - 2
                        radius: root.barHeight / 2
                    }
                }
            }

            Active {
                Layout.leftMargin: -8
                implicitHeight: root.barHeight - 2
                radius: root.barHeight / 2
                color: "#252324"
            }

            Clock {
                anchors.centerIn: parent
                radius: root.barHeight / 2
            }

            Item {
                Layout.fillWidth: true
            }

            WrapperRectangle {
                Layout.rightMargin: -8
                implicitHeight: root.barHeight - 2
                leftMargin: 10
                rightMargin: 10
                radius: root.barHeight / 2
                color: "#252324"
                RowLayout {
                    spacing: 9
                    Bluetooth {}
                    Volume {}
                    Network {
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                trayPop.visible = false;
                                netPop.visible = !netPop.visible;
                            }
                        }
                    }
                    Battery {}
                }
            }

            FlaredRect {
                Layout.fillHeight: true
                implicitWidth: li.implicitWidth + 3
                topLeft: "flare"
                topRight: "square"
                bottomLeft: "round"
                bottomRight: "flare"

                RowLayout {
                    id: li
                    anchors.centerIn: parent
                    spacing: 3
                    SysTray {
                        id: trayBtn
                        implicitHeight: root.barHeight - 2
                        implicitWidth: root.barHeight - 2
                        radius: root.barHeight / 2
                        open: trayPop.visible
                        onClicked: {
                            netPop.visible = false;
                            trayPop.visible = !trayPop.visible;
                        }
                    }

                    More {
                        implicitHeight: root.barHeight - 2
                        implicitWidth: root.barHeight - 2
                        radius: root.barHeight / 2
                    }
                }
            }
        }

        NetPopup {
            id: netPop
            anchor.window: root
            onVisibleChanged: root.syncGrab()
        }

        SysTrayPopup {
            id: trayPop
            anchor.window: root
            target: trayBtn
            onVisibleChanged: root.syncGrab()
            onOpenMenusChanged: if (openMenus === 0)
                root.syncGrab()
        }

        HyprlandFocusGrab {
            id: grab
            windows: [root, trayPop, netPop]   // clicks on any of these don't count as "outside"

            onCleared: {
                if (trayPop.openMenus > 0)     // a tray right-click menu is up, so leave things alone
                    return;
                trayPop.visible = false;
                netPop.visible = false;
            }
        }
        Timer {
            id: grabTimer
            interval: 50
            onTriggered: grab.active = trayPop.visible || netPop.visible
        }

        function syncGrab() {
            if (trayPop.visible || netPop.visible) {
                grabTimer.restart();     // give the popup's window time to exist
            } else {
                grabTimer.stop();
                grab.active = false;
            }
        }
    }
}
