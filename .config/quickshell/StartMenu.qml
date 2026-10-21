import QtQuick
import Quickshell

FlaredRect {
    color: "#262324"
    topLeft: "square"
    topRight: "flare"
    bottomLeft: "square"
    bottomRight: "round"

    Text {
        anchors.centerIn: parent
        text: "󰣇"
        color: "white"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["rofi", "-show", "drun", "-show-icons"])
    }
}
