import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

// Bar indicator. Emits clicked() so the bar can toggle the Bluetooth popup.
Item {
    id: root

    signal clicked

    Layout.fillHeight: true
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Text {
        id: icon
        anchors.centerIn: parent
        color: "white"
        font.family: "JetBrainsMono Nerd Font Propo"
        text: {
            if (!Bluetooth.defaultAdapter?.enabled)
                return String.fromCodePoint(0xF00B2);   // off
            if (Bluetooth.devices.values.some(d => d.connected))
                return String.fromCodePoint(0xF00B1);   // connected
            return String.fromCodePoint(0xF00AF);       // on, nothing connected
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
