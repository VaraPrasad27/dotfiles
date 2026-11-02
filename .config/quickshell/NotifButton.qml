import QtQuick
import QtQuick.Layouts

// Bar bell. Turns pink with a badge while there are notifications.
// Emits clicked() so the bar can toggle the notification popup.
Item {
    id: root

    property int count: 0
    signal clicked

    Layout.fillHeight: true
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    visible: count > 0

    Text {
        id: icon
        anchors.centerIn: parent
        // bell-badge-outline when there is something to read, bell-outline otherwise
        text: String.fromCodePoint(root.count > 0 ? 0xF0178 : 0xF009C)
        color: root.count > 0 || area.containsMouse ? "#e89aa8" : "white"
        font.family: "JetBrainsMono Nerd Font Propo"
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
