import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.UPower

WrapperRectangle {
    color: "#252325"
    RowLayout {
        id: root
        spacing: 6

        property var battery: UPower.displayDevice
        property bool charging: battery.state === UPowerDeviceState.Charging
        readonly property int level: Math.round(battery.percentage * 100)
        readonly property string icon: {
            if (charging)
                return String.fromCodePoint(0xF0084);
            if (level >= 100)
                return String.fromCodePoint(0xF0079);
            if (level < 10)
                return String.fromCodePoint(0xF0083);
            return String.fromCodePoint(0xF007A + (Math.floor(level / 10) - 1));
        }
        Text {
            text: root.icon
            color: root.charging ? "#7ad9a8" : root.level <= 15 ? "#ffa478" : "#7ad9a8"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
        }
        Text {
            text: root.level + "%"
            color: "#f4e2c5"
            font.family: "SF Pro Display"
            font.weight: 500
        }
    }
}
