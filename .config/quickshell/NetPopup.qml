import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking

// A layer-shell window (not a PopupWindow) so it can receive keyboard focus
// for the password field. Pinned to the top-right corner under the bar.
PanelWindow {
    id: root

    // distance from the top of the screen: bar window height + a small gap
    property int topOffset: 32

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    margins.right: 3
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:netpopup"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand   // focus when clicked

    implicitWidth: 500
    implicitHeight: 500
    visible: false
    color: "transparent"

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    readonly property bool wifiOn: Networking.wifiEnabled

    // collapse any open row when the popup closes
    onVisibleChanged: if (!visible)
        list.expandedNetwork = null

    // only scan for networks while the popup is open
    Binding {
        target: root.wifiDevice ?? null
        property: "scannerEnabled"
        value: root.visible
        when: root.wifiDevice !== undefined && root.wifiDevice !== null
    }

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            // header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Wi-Fi"
                    color: "white"
                    font.pointSize: 13
                    font.weight: 600
                }

                Text {
                    visible: root.wifiOn && (root.wifiDevice?.scannerEnabled ?? false)
                    text: "Scanning…"
                    color: "#8a8da6"
                    font.pointSize: 10
                }

                Item {
                    Layout.fillWidth: true
                }

                // power switch (dimmed and inert while a hardware kill switch is on)
                Rectangle {
                    id: power
                    readonly property bool on: root.wifiOn

                    implicitWidth: 42
                    implicitHeight: 24
                    radius: 12
                    color: on ? "#e89aa8" : "#3a3d52"
                    opacity: Networking.wifiHardwareEnabled ? 1 : 0.45

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        y: 3
                        x: power.on ? 21 : 3
                        color: power.on ? "#232534" : "white"

                        Behavior on x {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Networking.wifiHardwareEnabled)
                            Networking.wifiEnabled = !Networking.wifiEnabled
                    }
                }
            }

            // network list (wrapper so the scrollbar can sit beside it, outside the layout)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.wifiOn && !!root.wifiDevice

                ListView {
                    id: list
                    anchors.fill: parent
                    spacing: 10
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    // the network whose row is currently expanded (only one at a time)
                    property var expandedNetwork: null

                    model: root.wifiDevice ? root.wifiDevice.networks : null

                    delegate: NetRow {
                        width: ListView.view.width
                        expanded: list.expandedNetwork === modelData
                        onToggled: list.expandedNetwork = expanded ? null : modelData
                        onCollapse: list.expandedNetwork = null
                    }

                    // only shown when the list actually scrolls; sits in the popup's right margin
                    ScrollBar.vertical: ScrollBar {
                        parent: list.parent
                        anchors.top: list.top
                        anchors.bottom: list.bottom
                        anchors.left: list.right
                        anchors.leftMargin: 3
                        visible: size < 1.0
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: "#e89aa8"
                            opacity: parent.active ? 0.9 : 0.4
                        }
                        background: Item {}
                    }
                }
            }

            // empty states
            Text {
                visible: !root.wifiOn
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: Networking.wifiHardwareEnabled ? "Wi-Fi is turned off" : "Wi-Fi is blocked by a hardware switch"
                color: "#8a8da6"
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                visible: root.wifiOn && !root.wifiDevice
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "No Wi-Fi device found"
                color: "#8a8da6"
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
