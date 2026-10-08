import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Bluetooth

WrapperRectangle {
    color: "#252324"

    RowLayout {
        id: root
        readonly property string icon: {
            if (!Bluetooth.defaultAdapter.enabled)
                return "󰂲";
            if (Bluetooth.devices.values.some(d => d.connected))
                return "󰂱";
            return "󰂯"; // enabled, nothing connected
        }

        Text {
            text: root.icon
            color: "white"
        }
    }
}
