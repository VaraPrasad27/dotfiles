import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// Popup content: header with "Clear all", then the notifications (newest first).
Item {
    id: root

    property var notifications: []          // array of Notification
    property var arrival: ({})              // notification id → arrival time (ms)
    property bool active: false             // popup is visible
    property real now: Date.now()
    property alias view: list

    readonly property var newestFirst: notifications.slice().reverse()

    function clearAll() {
        notifications.slice().forEach(n => n.dismiss());
    }

    // keep the "2m" style timestamps fresh while the popup is open
    onActiveChanged: if (active)
        now = Date.now()

    Timer {
        interval: 30000
        repeat: true
        running: root.active
        onTriggered: root.now = Date.now()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Notifications"
                color: "white"
                font.pointSize: 13
                font.weight: 600
            }

            Text {
                visible: root.notifications.length > 0
                text: root.notifications.length
                color: "#8a8da6"
                font.pointSize: 10
            }

            Item {
                Layout.fillWidth: true
            }

            NetButton {
                visible: root.notifications.length > 0
                text: "Clear all"
                textColor: "#ff8a8a"
                onClicked: root.clearAll()
            }
        }

        // list (wrapper so the scrollbar can sit beside it)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifications.length > 0

            ListView {
                id: list
                anchors.fill: parent
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                // ScriptModel keeps existing cards alive as notifications come and go
                model: ScriptModel {
                    values: root.newestFirst
                }

                delegate: NotifRow {
                    width: ListView.view.width
                    arrival: root.arrival
                    now: root.now
                }

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

        // empty state
        ColumnLayout {
            visible: root.notifications.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Item {
                Layout.fillHeight: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: String.fromCodePoint(0xF009C)     // bell-outline
                color: "#3a3d52"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 40
            }

            Text {
                Layout.fillWidth: true
                text: "No notifications"
                color: "#8a8da6"
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
