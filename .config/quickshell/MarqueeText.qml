import QtQuick

// Single-line text in a fixed-width box. If it doesn't fit, it scrolls sideways as a
// seamless ticker: a second copy of the text follows the first, so when a pass ends
// the picture is identical to the start and nothing ever jumps back.
//   - one pass every `interval` ms
//   - while `hovered`, passes follow one another without a break; when the hover ends
//     the current pass is finished quickly and the text stops
Item {
    id: root

    property string text
    property color color: "white"
    property font font
    property int boxWidth: 110          // the box is always this wide
    property int interval: 6000         // rest between automatic passes (ms)
    property real speed: 30             // scroll speed (px per second)
    property int gap: 40                // space between the end of the text and its repeat
    property bool hovered: false
    property color fade: "#252324"      // background colour, for the edge fades

    readonly property real fullWidth: Math.ceil(measure.implicitWidth)
    readonly property real overflow: Math.max(0, fullWidth - width)
    readonly property real loopLength: fullWidth + gap
    readonly property real offset: strip.x
    property alias stripX: strip.x
    property bool scrolling: false
    property bool startedByHover: false

    implicitWidth: boxWidth
    implicitHeight: measure.implicitHeight
    clip: true

    function start(byHover) {
        if (overflow > 1 && !cycle.running && !finish.running) {
            startedByHover = byHover === true;
            scrolling = true;
            cycle.start();
        }
    }

    function reset() {
        cycle.stop();
        finish.stop();
        strip.x = 0;
        scrolling = false;
    }

    // pointer left during a hover-started scroll: carry on in the same direction,
    // but quickly, until the pass is complete
    function windDown() {
        cycle.stop();
        if (strip.x > -1) {
            strip.x = 0;
            scrolling = false;
            return;
        }
        finishMove.duration = Math.max(150, (loopLength + strip.x) / (speed * 3) * 1000);
        finish.start();
    }

    onTextChanged: reset()

    onHoveredChanged: {
        if (hovered)
            start(true);
        else if (cycle.running && startedByHover)
            windDown();
    }

    // invisible copy that tells us how wide the whole text is
    Text {
        id: measure
        visible: false
        text: root.text
        font: root.font
        textFormat: Text.PlainText
    }

    Item {
        id: strip

        Text {
            text: root.text
            color: root.color
            font: root.font
            textFormat: Text.PlainText
        }

        // the repeat that slides in behind the first copy
        Text {
            x: root.loopLength
            visible: root.overflow > 1
            text: root.text
            color: root.color
            font: root.font
            textFormat: Text.PlainText
        }
    }

    // one full pass: slide left by exactly one text-length + gap, then re-seat
    // (the second copy is now where the first one started, so the jump is invisible)
    SequentialAnimation {
        id: cycle

        PauseAnimation {
            duration: root.startedByHover ? 0 : 400
        }
        NumberAnimation {
            target: strip
            property: "x"
            from: 0
            to: -root.loopLength
            duration: root.loopLength / root.speed * 1000
            easing.type: Easing.Linear
        }
        ScriptAction {
            script: {
                strip.x = 0;
                root.scrolling = false;
            }
        }

        onFinished: if (root.hovered)
            root.start(true)
    }

    SequentialAnimation {
        id: finish

        NumberAnimation {
            id: finishMove
            target: strip
            property: "x"
            to: -root.loopLength
            easing.type: Easing.Linear
        }
        ScriptAction {
            script: {
                strip.x = 0;
                root.scrolling = false;
                if (root.hovered)
                    Qt.callLater(() => root.start(true));
            }
        }
    }

    Timer {
        interval: root.interval
        running: root.overflow > 1 && !root.scrolling && !root.hovered
        onTriggered: root.start(false)
    }

    // soft edges: the right one marks "there is more"; the left one appears once scrolled
    // and fades out again as the pass ends, so the re-seat doesn't pop
    Rectangle {
        anchors.left: parent.left
        width: 16
        height: parent.height
        opacity: root.overflow > 1 ? Math.max(0, Math.min(1, -root.offset / 16, (root.loopLength + root.offset) / 16)) : 0
        visible: opacity > 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: root.fade
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(root.fade.r, root.fade.g, root.fade.b, 0)
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        width: 16
        height: parent.height
        visible: root.overflow > 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Qt.rgba(root.fade.r, root.fade.g, root.fade.b, 0)
            }
            GradientStop {
                position: 1.0
                color: root.fade
            }
        }
    }
}
