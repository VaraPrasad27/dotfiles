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

                readonly property string iconName: DesktopEntries.heuristicLookup(modelData.appId)?.icon ?? modelData.appId

                implicitHeight: act1.implicitHeight
                implicitWidth: act1.implicitHeight
                radius: 15
                color: modelData.activated ? "#45475a" : hover.containsMouse ? "#313244" : "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    sourceSize: Qt.size(44, 44)
                    source: Quickshell.iconPath(item.iconName, "application-x-execuatable")
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
