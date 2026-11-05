import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.Mpris

// Media island: album art, track title / artist, previous / play-pause / next,
// and a thin progress line. Hidden while there is nothing to show.
Rectangle {
    id: root

    property int contentWidth: 110          // title box and visualizer are both exactly this wide
    property int artSize: 20
    property int scrollInterval: 6000       // idle time between automatic scrolls (ms)

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

    // "Title — Artist" as one string
    readonly property string label: {
        const title = player?.trackTitle || "Unknown title";
        const artist = player?.trackArtist ?? "";
        return artist !== "" ? title + " — " + artist : title;
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

    // How far the art must sit from the left end so the corners of its square frame
    // stay inside the pill's rounded cap (1px safety margin).
    readonly property int artInset: {
        const r = height / 2;
        const room = (r - 1) * (r - 1) - (artSize / 2) * (artSize / 2);
        return Math.ceil(r - Math.sqrt(Math.max(0, room)));
    }
    implicitWidth: artInset + row.implicitWidth + 10
    radius: height / 2
    color: "#252324"

    HoverHandler {
        id: hover
    }

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
            leftMargin: root.artInset
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // album art in a circle, or a note when there is none
        Item {
            Layout.preferredWidth: root.artSize
            Layout.preferredHeight: root.artSize

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
                sourceSize: Qt.size(root.artSize * 2, root.artSize * 2)
                source: root.player?.trackArtUrl ?? ""
            }

            // Rounds the art into a circle without shader effects: a frame in the
            // island's colour with a circular hole, laid over the square image.
            // The frame is exactly the size of the art, and `artInset` keeps its
            // corners inside the island's rounded end.
            Shape {
                anchors.fill: parent
                visible: art.status === Image.Ready
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    id: frame
                    readonly property real d: root.artSize

                    fillColor: root.color
                    fillRule: ShapePath.OddEvenFill
                    strokeWidth: -1

                    // the square
                    startX: 0
                    startY: 0
                    PathLine { x: frame.d; y: 0 }
                    PathLine { x: frame.d; y: frame.d }
                    PathLine { x: 0; y: frame.d }
                    PathLine { x: 0; y: 0 }

                    // the circle cut out of it
                    PathMove { x: frame.d; y: frame.d / 2 }
                    PathArc { x: 0; y: frame.d / 2; radiusX: frame.d / 2; radiusY: frame.d / 2 }
                    PathArc { x: frame.d; y: frame.d / 2; radiusX: frame.d / 2; radiusY: frame.d / 2 }
                }
            }
        }

        // "Title — Artist" as one line that scrolls; click focuses the player's window
        Item {
            implicitWidth: marquee.implicitWidth
            implicitHeight: marquee.implicitHeight

            MarqueeText {
                id: marquee
                text: root.label
                color: "white"
                font.family: "SF Pro Display"
                font.pointSize: 10
                font.weight: 500
                boxWidth: root.contentWidth
                interval: root.scrollInterval
                hovered: hover.hovered
                fade: root.color
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.player?.canRaise ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.player.raise()
            }
        }

        // audio visualizer (cava), only runs while something is playing
        AudioVisualizer {
            targetWidth: root.contentWidth
            active: root.visible && (root.player?.isPlaying ?? false)
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
