import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

// Popup content: power switch, scan status and the device list.
Item {
    id: root

    property bool active: false             // popup is visible → scan for devices
    property var expandedDevice: null       // device whose row is expanded (one at a time)
    property alias view: list

    readonly property var adapter: Bluetooth.defaultAdapter

    // connected first, then paired, then nearby; alphabetical inside each group
    readonly property var devices: {
        if (!adapter)
            return [];
        const rank = d => d.connected ? 0 : d.paired ? 1 : 2;
        return adapter.devices.values.slice().sort((a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name));
    }

    onActiveChanged: if (!active)
        expandedDevice = null

    // only scan while the popup is open
    Binding {
        target: root.adapter
        property: "discovering"
        value: root.active && !!root.adapter?.enabled
        when: root.adapter !== undefined && root.adapter !== null
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Bluetooth"
                color: "white"
                font.pointSize: 13
                font.weight: 600
            }

            Text {
                visible: root.adapter?.discovering ?? false
                text: "Scanning…"
                color: "#8a8da6"
                font.pointSize: 10
            }

            Item {
                Layout.fillWidth: true
            }

            // power switch
            Rectangle {
                id: power
                readonly property bool on: root.adapter?.enabled ?? false

                visible: root.adapter !== undefined && root.adapter !== null
                implicitWidth: 42
                implicitHeight: 24
                radius: 12
                color: on ? "#e89aa8" : "#3a3d52"

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
                    onClicked: root.adapter.enabled = !root.adapter.enabled
                }
            }
        }

        // wrapper so the scrollbar can sit beside the list (outside the layout)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !!root.adapter?.enabled

            ListView {
                id: list
                anchors.fill: parent
                spacing: 10
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                // ScriptModel keeps existing rows alive when the list is re-sorted,
                // so a row mid-pairing isn't destroyed when `paired` flips
                model: ScriptModel {
                    values: root.devices
                }

                delegate: BtRow {
                    width: ListView.view.width
                    expanded: root.expandedDevice === modelData
                    onToggled: root.expandedDevice = expanded ? null : modelData
                    onCollapse: root.expandedDevice = null
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
            visible: root.adapter === undefined || root.adapter === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "No Bluetooth adapter found"
            color: "#8a8da6"
            font.pointSize: 11
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: !!root.adapter && !root.adapter.enabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "Bluetooth is turned off"
            color: "#8a8da6"
            font.pointSize: 11
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
