import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Notification center popup, pinned to the top-right under the bar.
//
// This file also runs the notification daemon (NotificationServer), so it is always
// loaded even while the popup is hidden. Stop any other daemon (mako, dunst, swaync)
// or Quickshell won't be able to claim org.freedesktop.Notifications.
PanelWindow {
    id: root

    // distance from the top of the screen: bar window height + a small gap
    property int topOffset: 42

    // number of notifications waiting (for the bar bell)
    readonly property int count: server.trackedNotifications.values.length

    // notification id → time it arrived (the Notification object has no timestamp)
    property var arrival: ({})

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:notifications"

    implicitWidth: 420
    implicitHeight: 520
    visible: false
    color: "transparent"

    NotificationServer {
        id: server

        // capabilities are not advertised unless asked for
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true      // we keep them in the list until dismissed

        onNotification: n => {
            root.arrival[n.id] = Date.now();    // before tracking, so the card can read it
            n.tracked = true;                   // otherwise the notification is discarded
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        NotificationList {
            anchors.fill: parent
            anchors.margins: 15
            active: root.visible
            arrival: root.arrival
            notifications: server.trackedNotifications.values
        }
    }
}
