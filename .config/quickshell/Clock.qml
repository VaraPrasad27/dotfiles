import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

WrapperRectangle {
    Layout.fillHeight: true
    leftMargin: 10
    rightMargin: 10
    topMargin: 6
    color: "#252324"
    anchors.centerIn: parent

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: "#3dd1b0"

        font {
            family: "SF Mono"
            letterSpacing: -0.5
            pixelSize: 15
            weight: 600
        }
    }
}
