import QtQuick
import QtQuick.Shapes
import "../styles" // Assuming this is where Colors.barBg is

Item {
    id: root
    width: 25
    height: 25

    // Set this to true if you are placing it on the RIGHT side
    property bool isRight: false 
    // Set this to true if you are placing it on the BOTTOM
    property bool isBottom: false

    Shape {
        anchors.fill: parent
        // Enable high-quality antialiasing so the curve is smooth
        layer.enabled: true
        layer.samples: 8

        ShapePath {
            fillColor: (isBottom === true) ? "black" : Colors.barBg
            strokeColor: "transparent"

            // Logic: We draw a square, but we "scoop out" the circle from it
            // depending on which corner this is.
            
            startX: isRight ? 25 : 0
            startY: isBottom ? 25 : 0

            PathLine { x: isRight ? 0 : 25; y: isBottom ? 25 : 0 }
            
            // The Curve
            PathArc {
                x: isRight ? 25 : 0
                y: isBottom ? 0 : 25
                radiusX: 25; radiusY: 25
                useLargeArc: false
                // Sweep direction depends on the corner
                direction: (isRight === isBottom) ? PathArc.Counterclockwise : PathArc.Clockwise
            }
            
            // Close the shape
            PathLine { x: isRight ? 25 : 0; y: isBottom ? 25 : 0 }
        }
    }
}