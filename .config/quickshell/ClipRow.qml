import QtQuick
import QtQuick.Layouts

// One clipboard entry. Click copies it; the trash button deletes it.
// The "current" row (hovered, or reached with the arrow keys) is highlighted.
Rectangle {
    id: row

    required property var modelData
    required property int index
    readonly property bool current: ListView.isCurrentItem

    signal picked
    signal removed

    height: Math.max(40, label.implicitHeight + 20)
    radius: 10
    color: current ? "#34374d" : "#2b2d3f"
    border.width: 1
    border.color: current ? "#e89aa8" : "#3a3d52"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: row.ListView.view.currentIndex = row.index
        onClicked: row.picked()
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 8
        }
        spacing: 10

        Text {
            text: String.fromCodePoint(row.modelData.isImage ? 0xF0976 : 0xF09ED)   // image-outline / text-box-outline
            color: row.modelData.isImage ? "#e89aa8" : "#8a8da6"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 16
        }

        Text {
            id: label
            Layout.fillWidth: true
            text: row.modelData.preview
            color: "white"
            font.pointSize: 11
            maximumLineCount: 2
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
        }

        // delete (shown on the current row)
        Item {
            visible: row.current
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28

            Text {
                anchors.centerIn: parent
                text: String.fromCodePoint(0xF09E7)     // delete-outline
                color: trash.containsMouse ? "#ff8a8a" : "#8a8da6"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
            }

            MouseArea {
                id: trash
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: row.removed()
            }
        }
    }
}
