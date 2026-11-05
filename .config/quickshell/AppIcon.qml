import QtQuick
import Quickshell

// A theme icon that never shows the pink/black "missing icon" square.
//
// Tries each name in `names` (best first). If none exists in your icon theme it draws
// a round badge instead: a Nerd Font `glyph` if you give one, otherwise the first
// `letter`. `url` skips the theme lookup (notification images, absolute file paths).
Item {
    id: root

    property var names: []
    property string url: ""
    property int size: 22
    property string letter: ""
    property string glyph: ""
    property color badgeColor: "#34374d"
    property color badgeText: "#e89aa8"

    // iconPath(name, true) returns "" when the theme doesn't have the icon,
    // instead of the missing-icon image
    readonly property string resolved: {
        if (url !== "")
            return url;
        for (const n of names) {
            if (!n)
                continue;
            const p = Quickshell.iconPath(n, true);
            if (p !== "")
                return p;
        }
        return "";
    }

    readonly property bool showImage: resolved !== "" && img.status !== Image.Error

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        visible: root.showImage
        source: root.resolved
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
    }

    Rectangle {
        visible: !root.showImage
        anchors.fill: parent
        radius: width / 2
        color: root.badgeColor

        Text {
            anchors.centerIn: parent
            text: root.glyph !== "" ? root.glyph : (root.letter !== "" ? root.letter.charAt(0).toUpperCase() : "?")
            color: root.badgeText
            font.family: root.glyph !== "" ? "JetBrainsMono Nerd Font Propo" : "SF Pro Display"
            font.pixelSize: Math.round(root.size * (root.glyph !== "" ? 0.6 : 0.5))
            font.weight: 600
        }
    }
}
