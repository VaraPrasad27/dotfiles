import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking

// A layer-shell window (not a PopupWindow) so it can receive keyboard focus
// for the password field. Pinned to the top-right corner under the bar.
PanelWindow {
    id: root

    // distance from the top of the screen: bar window height + a small gap
    property int topOffset: 32

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    margins.right: 2
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:netpopup"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand   // focus when clicked

    implicitWidth: 500
    implicitHeight: 500
    visible: false
    color: "transparent"

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)

    // collapse any open row when the popup closes
    onVisibleChanged: if (!visible)
        list.expandedNetwork = null

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

            // the network whose row is currently expanded (only one at a time)
            property var expandedNetwork: null

            model: root.wifiDevice ? root.wifiDevice.networks : null

            delegate: NetRow {
                width: ListView.view.width
                expanded: list.expandedNetwork === modelData
                onToggled: list.expandedNetwork = expanded ? null : modelData
                onCollapse: list.expandedNetwork = null
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
