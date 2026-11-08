import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
    id: root

    property int topOffset: 32

    property int btnWidth: 60
    property int btnHeight: 40
    property int btnRadius: 5

    anchors {
        top: true
        right: true
    }
    margins.top: topOffset
    margins.right: 3
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:controlpopup"

    implicitHeight: controls.implicitHeight + 25
    implicitWidth: 300
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#232534"
        radius: 15

        ColumnLayout {
            id: controls
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            GridLayout {
                columnSpacing: 10
                rowSpacing: 10
                rows: 2
                columns: 4

                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰖩"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰂯"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: ""
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰌪"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰀝"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󰀃"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: "󱠏"
                }
                ControlBtn {
                    btnWidth: root.btnWidth
                    btnHeight: root.btnHeight
                    icon: ""
                }
            }

            Rectangle {
                Layout.fillWidth: parent
                implicitHeight: 1
                color: "#3a3d52"
            }

            RowLayout {
                id: vvv
                spacing: 10

                property var sink: Pipewire.defaultAudioSink

                readonly property bool ready: sink && sink.ready
                readonly property bool muted: ready && sink.audio.muted
                readonly property double vol: ready ? sink.audio.volume : 0

                readonly property string icon: {
                    if (!ready)
                        return String.fromCodePoint(0xF0581);
                    if (muted)
                        return String.fromCodePoint(0xF075F);
                    if (vol === 0)
                        return String.fromCodePoint(0xF0581);
                    if (vol < 34)
                        return String.fromCodePoint(0xF057F);
                    if (vol < 67)
                        return String.fromCodePoint(0xF0580);

                    return String.fromCodePoint(0xF075E);
                }

                PwObjectTracker {
                    objects: [vvv.sink]
                }

                Text {
                    text: vvv.icon
                    color: "#e89aa8"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 18
                }

                Slider {
                    id: audioSlider
                    Layout.fillWidth: true
                    implicitHeight: 24
                    from: 0.0
                    to: 1.0
                    wheelEnabled: true
                    value: vvv.vol

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 6
                        x: audioSlider.leftPadding
                        y: audioSlider.topPadding + audioSlider.availableHeight / 2 - height / 2
                        width: audioSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#3b3d52" // Inactive track color (Nord polar night)
                        opacity: slider.enabled ? 1 : 0.4

                        Rectangle {
                            width: audioSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: "#e89aa8" // Fill
                        }
                    }

                    handle: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        x: audioSlider.leftPadding + audioSlider.visualPosition * (audioSlider.availableWidth - width)
                        y: audioSlider.topPadding + audioSlider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: audioSlider.pressed ? "white" : "#e89aa8"
                        border.width: 2
                        border.color: "#232534"
                        opacity: audioSlider.enabled ? 1 : 0.4
                    }

                    onMoved: {
                        Pipewire.defaultAudioSink.audio.volume = value;
                    }
                }

                Text {
                    Layout.preferredWidth: 36
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(vvv.vol * 100) + "%"
                    color: "white"
                    font.family: "SF Pro Display"
                    font.pointSize: 10
                    font.weight: 500
                }
            }

            RowLayout {
                id: bbb

                property bool active: true      // re-read the real brightness every 2 s while true (catches the keyboard keys)
                property int level: 50          // 1..100
                property bool ready: false      // false until a backlight device has answered

                spacing: 10

                // "intel_backlight,backlight,4800,50%,9600"  ->  device, class, current, percent, max
                Process {
                    id: reader
                    command: ["brightnessctl", "-c", "backlight", "-m"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            const f = text.trim().split(",");
                            const cur = Number(f[2]);
                            const max = Number(f[4]);
                            if (!(max > 0))
                                return;                     // no backlight (desktop monitor, VM...)
                            bbb.ready = true;

                            // ignore reads while dragging or just after a change (they can be stale),
                            // and 1% differences (rounding between what we set and what we read)
                            const percent = Math.max(1, Math.round(cur / max * 100));
                            if (!slider.pressed && !holdoff.running && Math.abs(percent - bbb.level) > 1)
                                bbb.level = percent;
                        }
                    }
                }

                Timer {
                    interval: 2000
                    repeat: true
                    running: bbb.active
                    triggeredOnStart: true
                    onTriggered: reader.running = true
                }

                // at most one `brightnessctl set` every 40 ms while dragging
                Timer {
                    id: sendTimer
                    interval: 40
                    onTriggered: Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", bbb.level + "%"])
                }

                Timer {
                    id: holdoff
                    interval: 700
                }

                Text {
                    text: String.fromCodePoint(bbb.level < 34 ? 0xF00DE : bbb.level < 67 ? 0xF00DF : 0xF00E0)   // brightness-5 / 6 / 7
                    color: "#e89aa8"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 18
                    opacity: bbb.ready ? 1 : 0.4
                }

                Slider {
                    id: slider
                    Layout.fillWidth: true
                    implicitHeight: 24              // the area you can grab
                    enabled: bbb.ready
                    from: 1
                    to: 100
                    stepSize: 1
                    value: bbb.level
                    wheelEnabled: true

                    onMoved: {
                        bbb.level = Math.round(value);
                        holdoff.restart();
                        if (!sendTimer.running)
                            sendTimer.start();
                    }

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 6
                        x: slider.leftPadding
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        width: slider.availableWidth
                        height: 6
                        radius: 3
                        color: "#3a3d52"
                        opacity: slider.enabled ? 1 : 0.4

                        Rectangle {
                            width: slider.visualPosition * (slider.availableWidth - slider.handle.width) + slider.handle.width / 2
                            height: parent.height
                            radius: 3
                            color: "#e89aa8"
                        }
                    }

                    handle: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: slider.pressed ? "white" : "#e89aa8"
                        border.width: 2
                        border.color: "#232534"
                        opacity: slider.enabled ? 1 : 0.4
                    }
                }

                Text {
                    Layout.preferredWidth: 36
                    horizontalAlignment: Text.AlignRight
                    text: bbb.ready ? bbb.level + "%" : "n/a"
                    color: "white"
                    font.family: "SF Pro Display"
                    font.pointSize: 10
                    font.weight: 500
                }
            }
        }
    }
}
