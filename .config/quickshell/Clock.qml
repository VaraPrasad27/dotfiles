import QtQuick
import Quickshell
import QtQuick.Layouts

FlaredRect {
    Layout.fillHeight: true
    implicitWidth: lable.implicitWidth + 20
    color: "#252324"
    topLeft: "flare"
    topRight: "flare"
    bottomLeft: "round"
    bottomRight: "round"

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        id: lable
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: "white"
        anchors.centerIn: parent

        font {
            family: "SF Mono"
            letterSpacing: -0.5
            pixelSize: 15
            weight: 600
        }
    }
}
