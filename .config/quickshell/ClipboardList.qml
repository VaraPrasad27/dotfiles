import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Popup content: search box + clipboard history from `cliphist`.
//
// Needs `cliphist` and `wl-clipboard`, with a watcher running, e.g. in hyprland.conf:
//   exec-once = wl-paste --type text  --watch cliphist store
//   exec-once = wl-paste --type image --watch cliphist store
Item {
    id: root

    property bool active: false             // popup is visible → (re)load history, focus search
    signal closeRequested

    property var entries: []
    property string query: ""
    property bool confirmClear: false
    property alias view: list
    property alias searchField: search

    readonly property var filtered: {
        const q = query.trim().toLowerCase();
        return q === "" ? entries : entries.filter(e => e.preview.toLowerCase().includes(q));
    }

    // `cliphist list` → "<id>\t<preview>" per line, newest first.
    function parse(text) {
        const out = [];
        for (const line of text.split("\n")) {
            const tab = line.indexOf("\t");
            if (tab < 0)
                continue;
            const id = line.slice(0, tab);
            if (!/^\d+$/.test(id))
                continue;
            const preview = line.slice(tab + 1);
            const img = preview.match(/^\[\[ binary data (.+?) (\w+) (\d+x\d+) \]\]$/);
            out.push(img ? {
                id: id,
                isImage: true,
                preview: "Image · " + img[2].toUpperCase() + " · " + img[3] + " · " + img[1]
            } : {
                id: id,
                isImage: false,
                preview: preview
            });
        }
        return out;
    }

    // `cliphist decode` takes a line starting with the id, so the bare id is enough
    function pick(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "sh", entry.id]);
        closeRequested();
    }

    function remove(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "sh", entry.id]);
        entries = entries.filter(e => e.id !== entry.id);
    }

    function clearAll() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
        confirmClear = false;
    }

    onActiveChanged: {
        if (active) {
            query = "";
            search.text = "";
            confirmClear = false;
            listProc.running = true;
            search.forceActiveFocus();
        }
    }

    onQueryChanged: list.currentIndex = 0

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = root.parse(text);
                list.currentIndex = 0;
            }
        }
    }

    // "Clear all" asks for a second click within 3 seconds
    Timer {
        id: confirmTimer
        interval: 3000
        onTriggered: root.confirmClear = false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Clipboard"
                color: "white"
                font.pointSize: 13
                font.weight: 600
            }

            Text {
                visible: root.entries.length > 0
                text: root.entries.length
                color: "#8a8da6"
                font.pointSize: 10
            }

            Item {
                Layout.fillWidth: true
            }

            NetButton {
                visible: root.entries.length > 0
                text: root.confirmClear ? "Confirm clear" : "Clear all"
                textColor: "#ff8a8a"
                onClicked: {
                    if (root.confirmClear) {
                        confirmTimer.stop();
                        root.clearAll();
                    } else {
                        root.confirmClear = true;
                        confirmTimer.restart();
                    }
                }
            }
        }

        // search
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 34
            radius: 10
            color: "#1b1c29"
            border.width: 1
            border.color: search.activeFocus ? "#e89aa8" : "#3a3d52"

            Text {
                id: lens
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: String.fromCodePoint(0xF0349)     // magnify
                color: "#8a8da6"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
            }

            TextInput {
                id: search
                anchors {
                    left: lens.right
                    right: clearSearch.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 8
                }
                verticalAlignment: TextInput.AlignVCenter
                color: "white"
                selectionColor: "#e89aa8"
                selectedTextColor: "#232534"
                font.pointSize: 11
                clip: true

                onTextChanged: root.query = text
                onAccepted: if (list.currentItem)
                    root.pick(list.currentItem.modelData)

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) {
                        list.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        list.decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        if (text.length > 0)
                            text = "";
                        else
                            root.closeRequested();
                        event.accepted = true;
                    }
                }
            }

            Text {
                visible: search.text.length === 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: lens.right
                anchors.leftMargin: 8
                text: "Search clipboard"
                color: "#8a8da6"
                font.pointSize: 11
            }

            // clear the search text
            Item {
                id: clearSearch
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                width: search.text.length > 0 ? 32 : 8

                Text {
                    visible: search.text.length > 0
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF0156)     // close
                    color: xArea.containsMouse ? "white" : "#8a8da6"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: xArea
                    anchors.fill: parent
                    enabled: search.text.length > 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        search.text = "";
                        search.forceActiveFocus();
                    }
                }
            }
        }

        // history (wrapper so the scrollbar can sit beside the list)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.filtered.length > 0

            ListView {
                id: list
                anchors.fill: parent
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: false

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                model: ScriptModel {
                    values: root.filtered
                }

                delegate: ClipRow {
                    width: ListView.view.width
                    onPicked: root.pick(modelData)
                    onRemoved: root.remove(modelData)
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

        // empty states
        ColumnLayout {
            visible: root.entries.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Item {
                Layout.fillHeight: true
            }

            Text {
                Layout.fillWidth: true
                text: "No clipboard history yet"
                color: "#8a8da6"
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                text: "Needs cliphist and wl-clipboard, with a watcher running (hyprland.conf):\nexec-once = wl-paste --type text --watch cliphist store\nexec-once = wl-paste --type image --watch cliphist store"
                color: "#6c6f88"
                font.pointSize: 9
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
            }
        }

        Text {
            visible: root.entries.length > 0 && root.filtered.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "No matches"
            color: "#8a8da6"
            font.pointSize: 11
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
