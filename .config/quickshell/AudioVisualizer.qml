import QtQuick
import Quickshell.Io

// Small equalizer driven by `cava`. Needs cava installed (sudo pacman -S cava).
// cava only runs while `active` is true, so it costs nothing while nothing plays.
//
// If it stays flat, run `qs` in a terminal: cava's error messages and a
// "no data" warning are printed there.
Item {
    id: root

    property bool active: false
    property int targetWidth: 80                // the visualizer is exactly this wide
    property int barWidth: 2
    property int gap: 2
    readonly property int bars: Math.max(2, Math.floor((targetWidth + gap) / (barWidth + gap)))
    property int maxHeight: 16
    property color color: "#e89aa8"

    // "auto" uses pipewire when your cava build supports it, otherwise pulse
    // (pulse also works on PipeWire through pipewire-pulse). Or force "pipewire" / "pulse" / "alsa".
    property string inputMethod: "auto"

    property var values: zeros()                // 0..100 per bar
    property bool gotFrames: false

    function zeros() {
        return Array(bars).fill(0);
    }

    // cava prints one frame per line: "12;40;7;...;"
    function parse(line) {
        const v = line.split(";").filter(s => s !== "").map(Number);
        if (v.length > 0) {
            values = v;
            gotFrames = true;
        }
    }

    // The config is written next to the runtime files, then cava replaces the shell
    // (exec) so stopping the process really stops cava.
    readonly property string script: 'cfg="${XDG_RUNTIME_DIR:-/tmp}/qs-cava.conf"\n'
        + (inputMethod === "auto"
            ? 'm=pipewire\nldd "$(command -v cava)" 2>/dev/null | grep -q libpipewire || m=pulse\n'
            : 'm=' + inputMethod + '\n')
        + 'cat > "$cfg" <<EOF\n'
        + '[general]\n'
        + 'bars = ' + bars + '\n'
        + 'framerate = 30\n'
        + 'autosens = 1\n'
        + '[input]\n'
        + 'method = $m\n'
        + 'source = auto\n'
        + '[output]\n'
        + 'method = raw\n'
        + 'raw_target = /dev/stdout\n'
        + 'data_format = ascii\n'
        + 'ascii_max_range = 100\n'
        + 'bar_delimiter = 59\n'
        + 'frame_delimiter = 10\n'
        + 'channels = mono\n'
        + '[smoothing]\n'
        + 'noise_reduction = 65\n'
        + 'EOF\n'
        + 'exec cava -p "$cfg"'

    implicitWidth: targetWidth
    implicitHeight: maxHeight

    onActiveChanged: {
        if (!active) {
            values = zeros();
            gotFrames = false;
        }
    }

    Process {
        id: cava

        // `command` first: if music is already playing when the shell loads, `running`
        // is true immediately and the process must already know what to run
        command: ["sh", "-c", root.script]
        running: root.active

        stdout: SplitParser {
            onRead: data => root.parse(data)
        }

        // cava explains itself here, e.g. "input method 'pipewire' is not supported"
        stderr: SplitParser {
            onRead: data => console.warn("AudioVisualizer: cava says:", data)
        }
    }

    // started but nothing came out: usually a wrong input method or no cava binary
    Timer {
        interval: 3000
        running: root.active && !root.gotFrames
        onTriggered: console.warn("AudioVisualizer: no data from cava after 3s (is cava installed? try inputMethod: \"pulse\")")
    }

    Row {
        anchors.centerIn: parent
        spacing: root.gap

        Repeater {
            model: root.bars

            delegate: Rectangle {
                required property int index

                width: root.barWidth
                height: 2 + (root.maxHeight - 2) * Math.min(1, (root.values[index] ?? 0) / 100)
                y: (root.maxHeight - height) / 2
                radius: width / 2
                color: root.color
                opacity: root.active ? 1 : 0.4

                Behavior on height {
                    NumberAnimation {
                        duration: 70
                    }
                }
            }
        }
    }
}
