import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    property color color: "#252324"
    property real radius: height / 2      // size of "round" corners
    property real flare: 10               // size of "flare" corners

    // each is "square" | "round" | "flare"
    property string topLeft: "round"
    property string topRight: "round"
    property string bottomLeft: "round"
    property string bottomRight: "round"

    default property alias content: contentArea.data

    // reserve room for the sideways (top) flares so they don't overlap neighbours
    Layout.leftMargin: topLeft === "flare" ? flare : 0
    Layout.rightMargin: topRight === "flare" ? flare : 0

    readonly property real r: Math.max(0, Math.min(radius, height / 2, width / 2))

    function sel(kind, sq, rd, fl) {
        return kind === "flare" ? fl : kind === "round" ? rd : sq;
    }

    Shape {
        x: -root.flare
        width: root.width + root.flare * 2
        height: root.height + root.flare       // extra room for the bottom flares
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: p
            fillColor: root.color
            strokeWidth: -1

            readonly property real f: root.flare
            readonly property real r: root.r
            readonly property real w: root.width
            readonly property real h: root.height
            readonly property string tl: root.topLeft
            readonly property string tr: root.topRight
            readonly property string bl: root.bottomLeft
            readonly property string br: root.bottomRight

            // the shape is offset by +f so sideways flares have room on the left
            startX: f + root.sel(tl, 0, r, -f)
            startY: 0

            // top edge, then top-right corner
            PathLine {
                x: p.f + root.sel(p.tr, p.w, p.w - p.r, p.w + p.f)
                y: 0
            }
            PathArc {
                x: p.f + p.w
                y: root.sel(p.tr, 0, p.r, p.f)
                radiusX: root.sel(p.tr, 0, p.r, p.f)
                radiusY: root.sel(p.tr, 0, p.r, p.f)
                direction: p.tr === "flare" ? PathArc.Counterclockwise : PathArc.Clockwise
            }

            // right edge, then bottom-right corner
            PathLine {
                x: p.f + p.w
                y: root.sel(p.br, p.h, p.h - p.r, p.h + p.f)
            }
            PathArc {
                x: p.f + root.sel(p.br, p.w, p.w - p.r, p.w - p.f)
                y: p.h
                radiusX: root.sel(p.br, 0, p.r, p.f)
                radiusY: root.sel(p.br, 0, p.r, p.f)
                direction: p.br === "flare" ? PathArc.Counterclockwise : PathArc.Clockwise
            }

            // bottom edge, then bottom-left corner
            PathLine {
                x: p.f + root.sel(p.bl, 0, p.r, p.f)
                y: p.h
            }
            PathArc {
                x: p.f
                y: root.sel(p.bl, p.h, p.h - p.r, p.h + p.f)
                radiusX: root.sel(p.bl, 0, p.r, p.f)
                radiusY: root.sel(p.bl, 0, p.r, p.f)
                direction: p.bl === "flare" ? PathArc.Counterclockwise : PathArc.Clockwise
            }

            // left edge, then top-left corner (ends on the start point)
            PathLine {
                x: p.f
                y: root.sel(p.tl, 0, p.r, p.f)
            }
            PathArc {
                x: p.f + root.sel(p.tl, 0, p.r, -p.f)
                y: 0
                radiusX: root.sel(p.tl, 0, p.r, p.f)
                radiusY: root.sel(p.tl, 0, p.r, p.f)
                direction: p.tl === "flare" ? PathArc.Counterclockwise : PathArc.Clockwise
            }
        }
    }

    Item {
        id: contentArea
        anchors.fill: parent
    }
}
