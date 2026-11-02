import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.Mpris

// Media island: album art, track title / artist, previous / play-pause / next,
// and a thin progress line. Hidden while there is nothing to show.
Rectangle {
    id: root

    property int maxTitleWidth: 150
    property int maxArtistWidth: 90

    // The player shown: whichever one is playing; when nothing is, stay on the last
    // one that was (so pausing doesn't make the island jump to another player).
    readonly property var playing: Mpris.players.values.find(p => p.isPlaying) ?? null
    property var lastPlayed: null

    onPlayingChanged: if (playing)
        lastPlayed = playing
    Component.onCompleted: if (playing)
        lastPlayed = playing

    readonly property var player: {
        const ps = Mpris.players.values;
        if (playing)
            return playing;
        if (lastPlayed && ps.includes(lastPlayed))
            return lastPlayed;
        return ps[0] ?? null;
    }

    readonly property real progress: {
        const p = player;
        if (!p || !p.positionSupported || !p.lengthSupported || p.length <= 0)
            return 0;
        return Math.max(0, Math.min(1, p.position / p.length));
    }

    // browsers keep empty players around after a tab closes, so ignore those
    visible: player !== null && (player.trackTitle !== "" || player.isPlaying)

    implicitHeight: 28
    implicitWidth: row.implicitWidth + 16
    radius: height / 2
    color: "#252324"

    // `position` only updates when asked, so poke it once a second while playing
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.player?.isPlaying ?? false) && (root.player?.positionSupported ?? false)
        onTriggered: root.player.positionChanged()
    }

    RowLayout {
        id: row
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // album art in a circle, or a note when there is none
        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#34374d"
                visible: art.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF0387)     // music-note
                    color: "#8a8da6"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13
                }
            }

            Image {
                id: art
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(44, 44)
                source: root.player?.trackArtUrl ?? ""
            }

            // Rounds the art into a circle without shader effects: a frame in the
            // island's colour with a circular hole, laid over the square image.
            Shape {
                anchors.fill: parent
                visible: art.status === Image.Ready
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: root.color
                    fillRule: ShapePath.OddEvenFill
                    strokeWidth: -1

                    // outer square (a pixel larger so no edge of the image peeks out)
                    startX: -1
                    startY: -1
                    PathLine { x: 23; y: -1 }
                    PathLine { x: 23; y: 23 }
                    PathLine { x: -1; y: 23 }
                    PathLine { x: -1; y: -1 }

                    // inner circle, diameter 22
                    PathMove { x: 22; y: 11 }
                    PathArc { x: 0; y: 11; radiusX: 11; radiusY: 11 }
                    PathArc { x: 22; y: 11; radiusX: 11; radiusY: 11 }
                }
            }
        }

        // title + artist; click focuses the player's window
        Item {
            implicitWidth: textRow.implicitWidth
            implicitHeight: textRow.implicitHeight

            RowLayout {
                id: textRow
                spacing: 8

                Text {
                    text: root.player?.trackTitle || "Unknown title"
                    color: "white"
                    font.family: "SF Pro Display"
                    font.pointSize: 10
                    font.weight: 500
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    Layout.maximumWidth: root.maxTitleWidth
                }

                Text {
                    visible: text !== ""
                    text: root.player?.trackArtist ?? ""
                    color: "#8a8da6"
                    font.family: "SF Pro Display"
                    font.pointSize: 10
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    Layout.maximumWidth: root.maxArtistWidth
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.player?.canRaise ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.player.raise()
            }
        }

        // controls
        RowLayout {
            spacing: 0

            MediaButton {
                glyph: String.fromCodePoint(0xF04AE)        // skip-previous
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player.previous()
            }

            MediaButton {
                glyph: String.fromCodePoint(root.player?.isPlaying ? 0xF03E4 : 0xF040A)   // pause / play
                size: 18
                color: "#e89aa8"
                hoverColor: "white"
                enabled: root.player?.canTogglePlaying ?? false
                onClicked: root.player.togglePlaying()
            }

            MediaButton {
                glyph: String.fromCodePoint(0xF04AD)        // skip-next
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player.next()
            }
        }
    }

    // progress line along the bottom edge
    Rectangle {
        anchors {
            left: parent.left
            leftMargin: 14
            bottom: parent.bottom
            bottomMargin: 2
        }
        height: 2
        radius: 1
        width: (parent.width - 28) * root.progress
        color: "#e89aa8"
        opacity: 0.8
        visible: root.progress > 0
    }
}
