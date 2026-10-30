import QtQuick

// Small pill button used inside NetRow.
Rectangle {
    id: btn

    property string text
    property color textColor: "white"
    property color fill: "#3a3d52"
    signal clicked

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 28
    radius: 8
    color: fill
    opacity: !enabled ? 0.45 : area.containsMouse ? 0.85 : 1

    Text {
        id: label
        anchors.centerIn: parent
        text: btn.text
        color: btn.textColor
        font.pointSize: 10
        font.weight: 600
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
