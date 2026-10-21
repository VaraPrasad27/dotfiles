import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Rectangle {
    id: root

    property bool open: false
    signal clicked

    color: hover.containsMouse || open ? "#322f31" : "#252324"
    visible: SystemTray.items.values.length > 0

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        anchors.centerIn: parent
        text: String.fromCodePoint(root.open ? 0xF0143 : 0xF0140)   // chevron-up / chevron-down
        color: "white"
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 20
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
