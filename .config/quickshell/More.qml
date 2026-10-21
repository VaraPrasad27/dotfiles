import QtQuick
import QtQuick.Layouts

FlaredRect {
    color: "#252324"
    topLeft: "flare"
    topRight: "square"
    bottomLeft: "round"
    bottomRight: "square"

    Text {
        anchors.centerIn: parent
        text: ""
        color: "white"
        // 󰇙
    }
}
