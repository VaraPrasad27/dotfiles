import QtQuick
import Quickshell
import QtQuick.Layouts

Rectangle {
    Layout.fillHeight: true
    implicitWidth: lable.implicitWidth + 20
    color: "#252324"
    anchors.centerIn: parent

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        id: lable
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: "#3dd1b0"
        anchors.centerIn: parent

        font {
            family: "SF Mono"
            letterSpacing: -0.5
            pixelSize: 15
            weight: 600
        }
    }
}
