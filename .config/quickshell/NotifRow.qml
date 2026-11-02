import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// One notification card.
//   click card   → runs the app's "default" action (if it has one)
//   close button → dismisses it
//   buttons      → the notification's other actions
Rectangle {
    id: card

    required property var modelData         // Notification
    property var arrival: ({})              // notification id → arrival time (ms)
    property real now: Date.now()

    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
    readonly property bool low: modelData.urgency === NotificationUrgency.Low

    // `actions` is a list<>, not a real JS array, so copy it first
    readonly property var actionList: Array.from(modelData.actions ?? [])
    readonly property var defaultAction: actionList.find(a => a.identifier === "default")
    readonly property var extraActions: actionList.filter(a => a.identifier !== "default")

    readonly property string iconSource: {
        if (modelData.image !== "")
            return modelData.image;
        const ic = modelData.appIcon;
        if (ic.startsWith("/"))
            return "file://" + ic;
        return Quickshell.iconPath(ic !== "" ? ic : "dialog-information", "dialog-information");
    }

    function ago(t, now) {
        if (!t)
            return "";
        const s = Math.max(0, Math.floor((now - t) / 1000));
        if (s < 60)
            return "now";
        const m = Math.floor(s / 60);
        if (m < 60)
            return m + "m";
        const h = Math.floor(m / 60);
        return h < 24 ? h + "h" : Math.floor(h / 24) + "d";
    }

    implicitHeight: content.implicitHeight + 24
    radius: 10
    clip: true
    color: area.containsMouse && defaultAction ? "#34374d" : "#2b2d3f"
    border.width: 1
    border.color: critical ? "#ff8a8a" : "#3a3d52"
    opacity: low ? 0.8 : 1

    // urgent notifications get a red edge
    Rectangle {
        visible: card.critical
        width: 3
        height: parent.height
        color: "#ff8a8a"
    }

    // whole card is clickable; declared first so the controls sit on top of it
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: card.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (card.defaultAction)
            card.defaultAction.invoke()
    }

    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 14
            rightMargin: 8
            topMargin: 12
        }
        spacing: 12

        Image {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            sourceSize: Qt.size(64, 64)
            fillMode: Image.PreserveAspectFit
            source: card.iconSource
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: card.modelData.appName
                    color: "#8a8da6"
                    font.pointSize: 9
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                }

                Text {
                    text: card.ago(card.arrival[card.modelData.id], card.now)
                    color: "#6c6f88"
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Text {
                Layout.fillWidth: true
                text: card.modelData.summary
                color: "white"
                font.pointSize: 11
                font.weight: 600
                textFormat: Text.PlainText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                visible: card.modelData.body !== ""
                Layout.fillWidth: true
                text: card.modelData.body
                color: "#c9c9d6"
                font.pointSize: 10
                textFormat: Text.PlainText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            Flow {
                visible: card.extraActions.length > 0
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 8

                Repeater {
                    model: card.extraActions

                    delegate: NetButton {
                        required property var modelData
                        text: modelData.text
                        onClicked: modelData.invoke()
                    }
                }
            }
        }

        // dismiss
        Item {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24

            Text {
                anchors.centerIn: parent
                text: String.fromCodePoint(0xF0156)     // close
                color: closeArea.containsMouse ? "#ff8a8a" : "#8a8da6"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 14
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: card.modelData.dismiss()
            }
        }
    }
}
