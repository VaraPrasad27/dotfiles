import QtQuick
import QtQuick.Layouts

// Bar button. Emits clicked() so the bar can toggle the clipboard popup.
Item {
    id: root

    signal clicked

    Layout.fillHeight: true
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Text {
        id: icon
        anchors.centerIn: parent
        text: String.fromCodePoint(0xF0A38)     // clipboard-text-outline
        color: area.containsMouse ? "#e89aa8" : "white"
        font.family: "JetBrainsMono Nerd Font Propo"
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
