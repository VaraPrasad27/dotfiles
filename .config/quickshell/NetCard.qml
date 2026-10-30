import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

// One Wi-Fi network in the popup list.
//
//   collapsed + known    →  name ............ [Connect | Disconnect]
//   collapsed + unknown  →  name
//   expanded  + known    →  name
//                           [Connect | Disconnect] [Forget]
//   expanded  + unknown  →  name
//                           [ password ........ ] [Connect]
//
// The whole card is clickable and toggles between collapsed and expanded.
Rectangle {
    id: card

    required property var modelData
    property bool expanded: false

    signal toggled      // the card was clicked
    signal collapse     // the row asks to be collapsed (after connect / forget)

    // ── state ───────────────────────────────────────────────────
    readonly property bool known: modelData.known
    readonly property bool busy: modelData.stateChanging

    readonly property bool isOpen: modelData.security === WifiSecurityType.Open || modelData.security === WifiSecurityType.Owe
    readonly property bool usesPsk: modelData.security === WifiSecurityType.WpaPsk || modelData.security === WifiSecurityType.Wpa2Psk || modelData.security === WifiSecurityType.Sae
    readonly property int minPskLength: modelData.security === WifiSecurityType.Sae ? 1 : 8

    property bool needPassword: false   // a saved password was rejected → ask again
    property string error: ""

    readonly property string toggleText: busy ? (modelData.connected ? "Disconnecting…" : "Connecting…") : (modelData.connected ? "Disconnect" : "Connect")

    function toggleConnection() {
        if (modelData.connected)
            modelData.disconnect();
        else
            modelData.connect();
    }

    function submitPassword() {
        if (password.text.length >= minPskLength)
            modelData.connectWithPsk(password.text);
    }

    // ── look ────────────────────────────────────────────────────
    height: content.implicitHeight + 16
    radius: 10
    clip: true
    color: "#2b2d3f"
    border.width: 1
    border.color: modelData.connected ? "#e89aa8" : "#3a3d52"

    Behavior on height {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    onExpandedChanged: {
        if (!expanded) {
            error = "";
            needPassword = false;
            password.text = "";
        }
    }

    Connections {
        target: card.modelData

        function onConnectionFailed(reason) {
            const noSecrets = reason === ConnectionFailReason.NoSecrets;
            card.error = noSecrets ? "Wrong or missing password" : "Connection failed";
            if (noSecrets && card.usesPsk)
                card.needPassword = true;
        }

        function onConnectedChanged() {
            if (card.modelData.connected) {
                card.error = "";
                card.needPassword = false;
                password.text = "";
                card.collapse();
            }
        }
    }

    // ── small button used in this row ───────────────────────────
    component NetButton: Rectangle {
        id: btn

        property string text
        property color textColor: "white"
        property color fill: "#3a3d52"
        signal clicked

        implicitWidth: label.implicitWidth + 24
        implicitHeight: 28
        radius: 8
        color: fill
        opacity: !enabled ? 0.45 : area.containsMouse ? 0.85 : 1

        Text {
            id: label
            anchors.centerIn: parent
            text: btn.text
            color: btn.textColor
            font.pointSize: 10
            font.weight: 600
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
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

        // header: name (+ toggle button while collapsed and known)
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: card.modelData.name
                color: "white"
                elide: Text.ElideRight
                font.pointSize: 12
            }

            NetButton {
                visible: card.known && !card.expanded
                enabled: !card.busy
                text: card.toggleText
                fill: card.modelData.connected ? "#3a3d52" : "#e89aa8"
                textColor: card.modelData.connected ? "white" : "#232534"
                onClicked: card.toggleConnection()
            }
        }

        // expanded + known: connect/disconnect and forget
        RowLayout {
            visible: card.expanded && card.known && !card.needPassword
            Layout.fillWidth: true
            spacing: 8

            NetButton {
                enabled: !card.busy
                text: card.toggleText
                fill: card.modelData.connected ? "#3a3d52" : "#e89aa8"
                textColor: card.modelData.connected ? "white" : "#232534"
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

        // expanded + needs a password (unknown network, or a saved one was rejected)
        RowLayout {
            visible: card.expanded && card.usesPsk && (!card.known || card.needPassword)
            Layout.fillWidth: true
            spacing: 8

            onVisibleChanged: if (visible)
                password.forceActiveFocus()

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 28
                radius: 8
                color: "#1b1c29"
                border.width: 1
                border.color: password.activeFocus ? "#e89aa8" : "#3a3d52"

                TextInput {
                    id: password
                    anchors.fill: parent
                    leftPadding: 10
                    rightPadding: 10
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    color: "white"
                    selectionColor: "#e89aa8"
                    selectedTextColor: "#232534"
                    font.pointSize: 11
                    clip: true
                    onAccepted: card.submitPassword()
                }

                Text {
                    visible: password.text.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "Password"
                    color: "#8a8da6"
                    font.pointSize: 11
                }
            }

            NetButton {
                enabled: !card.busy && password.text.length >= card.minPskLength
                text: card.busy ? "Connecting…" : "Connect"
                fill: "#e89aa8"
                textColor: "#232534"
                onClicked: card.submitPassword()
            }
        }

        RowLayout {
            visible: card.expanded && card.isOpen && !card.known
            Layout.fillWidth: true

            NetButton {
                enabled: !card.busy
                text: card.busy ? "Connecting…" : "Connect"
                fill: "#e89aa8"
                textColor: "#232534"
                onClicked: card.modelData.connect()
            }
        }

        // expanded + enterprise / WEP etc.
        Text {
            visible: card.expanded && !card.known && !card.isOpen && !card.usesPsk
            Layout.fillWidth: true
            text: "This network type isn't supported here"
            color: "#8a8da6"
            font.pointSize: 10
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
