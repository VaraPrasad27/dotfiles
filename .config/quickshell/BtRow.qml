import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

// One Bluetooth device in the popup list.
//
//   collapsed + paired   →  icon  name / status ........ [Connect | Disconnect]
//   collapsed + unpaired →  icon  name / status
//   expanded  + paired   →  icon  name / status
//                           [Connect | Disconnect] [Forget]
//   expanded  + unpaired →  icon  name / status
//                           [Pair]
//
// The whole card is clickable and toggles between collapsed and expanded.
Rectangle {
    id: card

    required property var modelData
    property bool expanded: false

    signal toggled      // the card was clicked
    signal collapse     // the row asks to be collapsed (after connect / forget)

    // ── state ───────────────────────────────────────────────────
    readonly property bool paired: modelData.paired
    readonly property bool connected: modelData.connected
    readonly property bool pairing: modelData.pairing
    readonly property bool connecting: modelData.state === BluetoothDeviceState.Connecting
    readonly property bool disconnecting: modelData.state === BluetoothDeviceState.Disconnecting
    readonly property bool busy: connecting || disconnecting

    property bool connectAfterPair: false   // pair() was requested from this row
    property string error: ""

    readonly property string subtitle: {
        if (pairing)
            return "Pairing…";
        if (connecting)
            return "Connecting…";
        if (disconnecting)
            return "Disconnecting…";
        if (connected)
            return modelData.batteryAvailable ? "Connected · " + Math.round(modelData.battery * 100) + "%" : "Connected";
        return paired ? "Paired" : "Not paired";
    }

    readonly property string toggleText: connecting ? "Connecting…" : disconnecting ? "Disconnecting…" : connected ? "Disconnect" : "Connect"

    // shown instead of an icon when your theme has none for this kind of device
    function deviceGlyph(icon) {
        const i = icon ?? "";
        if (i.includes("headset") || i.includes("headphone"))
            return String.fromCodePoint(0xF02CB);   // headphones
        if (i.includes("speaker") || i.includes("audio-card"))
            return String.fromCodePoint(0xF04C3);   // speaker
        if (i.includes("keyboard"))
            return String.fromCodePoint(0xF030C);   // keyboard
        if (i.includes("mouse") || i.includes("pointing"))
            return String.fromCodePoint(0xF037D);   // mouse
        if (i.includes("gaming"))
            return String.fromCodePoint(0xF0297);   // gamepad
        if (i.includes("phone"))
            return String.fromCodePoint(0xF011C);   // cellphone
        if (i.includes("computer") || i.includes("laptop"))
            return String.fromCodePoint(0xF0322);   // laptop
        if (i.includes("watch"))
            return String.fromCodePoint(0xF0589);   // watch
        return String.fromCodePoint(0xF00AF);       // bluetooth
    }

    function toggleConnection() {
        if (connected)
            modelData.disconnect();
        else
            modelData.connect();
    }

    function startPairing() {
        error = "";
        connectAfterPair = true;
        modelData.pair();
    }

    // ── look ────────────────────────────────────────────────────
    height: content.implicitHeight + 16
    radius: 10
    clip: true
    color: "#2b2d3f"
    border.width: 1
    border.color: connected ? "#e89aa8" : "#3a3d52"

    Behavior on height {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    onExpandedChanged: {
        if (!expanded)
            error = "";
    }

    Connections {
        target: card.modelData

        // pairing finished: trust the device so it can reconnect by itself, then connect
        function onPairedChanged() {
            if (card.modelData.paired && card.connectAfterPair) {
                card.connectAfterPair = false;
                card.error = "";
                card.modelData.trusted = true;
                card.modelData.connect();
            }
        }

        function onPairingChanged() {
            if (!card.modelData.pairing && card.connectAfterPair)
                pairCheck.restart();
        }

        function onConnectedChanged() {
            if (card.modelData.connected)
                card.collapse();
        }
    }

    // pairing ended; if the device still isn't paired a moment later, it failed
    Timer {
        id: pairCheck
        interval: 700
        onTriggered: {
            if (card.connectAfterPair && !card.modelData.paired) {
                card.connectAfterPair = false;
                card.error = "Pairing failed. Devices that need a PIN aren't supported here";
            }
        }
    }

    // Whole card is clickable. Declared first so the controls below sit on top of it.
    MouseArea {
        anchors.fill: parent
        onClicked: card.toggled()
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 12
            rightMargin: 12
            topMargin: 8
        }
        spacing: 8

        // header: icon, name + status, (toggle button while collapsed and paired)
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            AppIcon {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                size: 22
                names: [card.modelData.icon, "bluetooth"]
                glyph: card.deviceGlyph(card.modelData.icon)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: card.modelData.name
                    color: "white"
                    elide: Text.ElideRight
                    font.pointSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: card.subtitle
                    color: card.connected ? "#e89aa8" : "#8a8da6"
                    elide: Text.ElideRight
                    font.pointSize: 9
                }
            }

            NetButton {
                visible: card.paired && !card.expanded && !card.pairing
                enabled: !card.busy
                text: card.toggleText
                fill: card.connected ? "#3a3d52" : "#e89aa8"
                textColor: card.connected ? "white" : "#232534"
                onClicked: card.toggleConnection()
            }
        }

        // expanded + paired: connect/disconnect and forget
        RowLayout {
            visible: card.expanded && card.paired
            Layout.fillWidth: true
            spacing: 8

            NetButton {
                enabled: !card.busy
                text: card.toggleText
                fill: card.connected ? "#3a3d52" : "#e89aa8"
                textColor: card.connected ? "white" : "#232534"
                onClicked: card.toggleConnection()
            }

            NetButton {
                enabled: !card.busy
                text: "Forget"
                textColor: "#ff8a8a"
                onClicked: {
                    card.modelData.forget();
                    card.collapse();
                }
            }
        }

        // expanded + not paired: pair (then connect)
        RowLayout {
            visible: card.expanded && !card.paired
            Layout.fillWidth: true
            spacing: 8

            NetButton {
                visible: !card.pairing
                text: "Pair"
                fill: "#e89aa8"
                textColor: "#232534"
                onClicked: card.startPairing()
            }

            NetButton {
                visible: card.pairing
                text: "Cancel pairing"
                onClicked: {
                    card.connectAfterPair = false;
                    card.modelData.cancelPair();
                }
            }
        }

        Text {
            visible: card.expanded && card.error !== ""
            Layout.fillWidth: true
            text: card.error
            color: "#ff8a8a"
            font.pointSize: 10
            wrapMode: Text.WordWrap
        }
    }
}
