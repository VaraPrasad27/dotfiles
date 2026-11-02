import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property int topOffset: 32

    property int btnWidth: 60
    property int btnHeight: 40
    property int btnRadius: 5

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    margins.right: 3
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:controlpopup"

    implicitHeight: 300
    implicitWidth: 300
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        ColumnLayout {
            id: controls
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            RowLayout {
                spacing: 10
                Layout.fillWidth: parent
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰖩"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰂯"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: ""
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰌪"
                }
                // wifi, blu, airplain, battery saver, nigth light, hot, projecr
            }
            RowLayout {
                spacing: 10
                Layout.fillWidth: parent
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰀝"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰀃"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󱠏"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: ""
                }
            }
        }
    }
}
