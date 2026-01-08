import QtQuick
import QtQuick.Shapes
import "../styles" 

Item {
    id: root
    width: 25
    height: 25

    property bool isRight: false 
    property bool isBottom: false
    
    // --- FIX: Add this property definition ---
    // We set the default logic here: Black for bottom corners, BarBg for top.
    property color cornerColor: (isBottom === true) ? "black" : Colors.barBg

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8

        ShapePath {
            // --- FIX: Use the property instead of hardcoded logic ---
            fillColor: root.cornerColor 
            strokeColor: "transparent"

            startX: isRight ? 25 : 0
            startY: isBottom ? 25 : 0

            PathLine { x: isRight ? 0 : 25; y: isBottom ? 25 : 0 }
            
            PathArc {
                x: isRight ? 25 : 0
                y: isBottom ? 0 : 25
                radiusX: 25; radiusY: 25
                useLargeArc: false
                direction: (isRight === isBottom) ? PathArc.Counterclockwise : PathArc.Clockwise
            }
            
            PathLine { x: isRight ? 25 : 0; y: isBottom ? 25 : 0 }
        }
    }
}