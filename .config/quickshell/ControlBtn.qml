import QtQuick

Rectangle {
    id: btn

    property string icon
    property color textColor: "white"
    property color fill: "#3a3d52"
    property int btnWidth
    property int btnHeight
    signal clicked

    implicitHeight: btnHeight
    implicitWidth: btnWidth
    radius: 8
    color: fill

    Text {
        anchors.centerIn: parent
        text: btn.icon
        color: btn.textColor
        // font.pointSize: 10
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
