import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Rectangle {
    id: act1
    implicitWidth: act2.implicitWidth
    RowLayout {
        id: act2
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: ToplevelManager.toplevels

            delegate: Rectangle {
                id: item
                required property var modelData

                readonly property string appId: modelData.appId ?? ""

                // reading `applications` makes this re-run once the desktop entries have
                // finished loading (right after login they often aren't ready yet)
                readonly property var entry: {
                    DesktopEntries.applications.values.length;
                    return DesktopEntries.heuristicLookup(appId);
                }

                implicitHeight: act1.implicitHeight
                implicitWidth: act1.implicitHeight
                radius: act1.implicitHeight / 2
                color: modelData.activated ? "#45475a" : hover.containsMouse ? "#313244" : "transparent"

                AppIcon {
                    anchors.centerIn: parent
                    size: 22
                    // the desktop entry's icon, then the window class as written, lower-cased,
                    // and its last dotted part (org.mozilla.Thunderbird -> thunderbird)
                    names: [item.entry?.icon, item.appId, item.appId.toLowerCase(), item.appId.split(".").pop().toLowerCase()]
                    letter: item.entry?.name || item.appId
                }

                Rectangle {
                    visible: item.modelData.activated
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 2
                    }
                    width: 12
                    height: 3
                    radius: 2
                    color: "#89b4fa"
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton)
                            item.modelData.close();
                        else
                            item.modelData.activate();
                    }
                }
            }
        }
    }
}
