import QtQuick
import Quickshell
import Quickshell.Wayland

// Bluetooth popup: a layer-shell window pinned to the top-right, under the bar
// (same placement as NetPopup).
PanelWindow {
    id: root

    // distance from the top of the screen: bar window height + a small gap
    property int topOffset: 32

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    margins.right: 3
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:btpopup"

    implicitWidth: 420
    implicitHeight: 460
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        BtList {
            anchors.fill: parent
            anchors.margins: 15
            active: root.visible
        }
    }
}
