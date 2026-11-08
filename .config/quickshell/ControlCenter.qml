import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    signal clicked

    color: "#252324"

    Text {
        anchors.centerIn: parent
        text: ""
        color: "white"
        // 󰇙
    }
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
