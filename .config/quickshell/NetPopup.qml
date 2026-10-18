import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

PopupWindow {
    id: root

    anchor.rect.x: anchor.window ? anchor.window.width : 0
    anchor.rect.y: anchor.window ? anchor.window.height + 2 : 0

    implicitWidth: 500
    implicitHeight: 500
    visible: false
    color: "transparent"

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.visible
        when: root.wifiDevice !== undefined && root.wifiDevice !== null
    }

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            model: root.wifiDevice ? root.wifiDevice.networks : null

            delegate: Rectangle {
                required property var modelData

                width: ListView.view.width
                implicitHeight: label.implicitHeight + 16
                radius: 10
                color: "#2b2d3f"
                border.width: 1
                border.color: modelData.connected ? "#e89aa8" : "#3a3d52"

                Text {
                    id: label
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: parent.modelData.name
                    color: "white"
                    font.pointSize: 12
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: "#e89aa8"
                    opacity: parent.active ? 0.9 : 0.4
                }
                background: Item {}
            }
        }
    }
}
