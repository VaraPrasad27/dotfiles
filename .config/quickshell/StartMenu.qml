import QtQuick
import Quickshell

Rectangle {
    color: "#262324"

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
