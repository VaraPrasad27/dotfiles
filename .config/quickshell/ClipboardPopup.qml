import QtQuick
import Quickshell
import Quickshell.Wayland

// Clipboard history popup: a layer-shell window pinned to the top-right, under the bar.
// Takes the keyboard while open so you can type to search straight away.
PanelWindow {
    id: root

    // distance from the top of the screen: bar window height + a small gap
    property int topOffset: 42

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:clipboard"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    implicitWidth: 460
    implicitHeight: 520
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        ClipboardList {
            anchors.fill: parent
            anchors.margins: 15
            active: root.visible
            onCloseRequested: root.visible = false
        }
    }
}
