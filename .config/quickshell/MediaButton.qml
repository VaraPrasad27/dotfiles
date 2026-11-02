import QtQuick

// Small icon button for the media island. Dimmed and inert when `enabled` is false.
Item {
    id: btn

    property string glyph
    property int size: 15
    property color color: "white"
    property color hoverColor: "#e89aa8"
    signal clicked

    implicitWidth: 24
    implicitHeight: 24
    opacity: enabled ? 1 : 0.35

    Text {
        anchors.centerIn: parent
        text: btn.glyph
        color: area.containsMouse ? btn.hoverColor : btn.color
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: btn.size
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: btn.clicked()
    }
}
