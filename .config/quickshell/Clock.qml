import QtQuick
import Quickshell
import QtQuick.Layouts

FlaredRect {
    Layout.fillHeight: true
    implicitWidth: clockDisplay.implicitWidth + 20
    color: "#252324"
    topLeft: "flare"
    topRight: "flare"
    bottomLeft: "round"
    bottomRight: "round"

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    RowLayout {
        id: clockDisplay
        anchors.centerIn: parent
        spacing: 9

        Text {
            id: dateDisplay
            visible: false
            text: Qt.formatDateTime(clock.date, "ddd, d MMM")
            color: "white"
            font {
                family: "SF Mono"
                wordSpacing: -3
                pixelSize: 15
                weight: 600
            }
        }

        Rectangle {
            id: dot
            visible: false
            width: 8
            height: 8
            radius: 4
            color: "white"
        }

        Text {
            id: timeDisplay
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            color: "white"

            font {
                family: "SF Mono"
                wordSpacing: -3
                pixelSize: 15
                weight: 600
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            dateDisplay.visible = true;
            dot.visible = true;
        }

        onExited: {
            dateDisplay.visible = false;
            dot.visible = false;
        }
    }
}
