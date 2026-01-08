import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

MouseArea {
    id: volRoot
    property string iconFont: "JetBrainsMono Nerd Font"
    property int volumeValue: 0
    property bool isMuted: false

    // Layout configuration
    Layout.preferredWidth: volRow.implicitWidth
    Layout.preferredHeight: 28 
    cursorShape: Qt.PointingHandCursor
    
    // Accept interactions
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // --- Logic: Read Volume ---
    Process {
        id: volProc
        command: ["sh", "-c", "pamixer --get-volume && pamixer --get-mute"]
        stdout: SplitParser {
            onRead: data => {
                let cleanData = data.trim();
                // pamixer output parsing
                if (cleanData === "true") isMuted = true;
                else if (cleanData === "false") isMuted = false;
                else {
                    let val = parseInt(cleanData);
                    if (!isNaN(val)) volumeValue = val;
                }
            }
        }
    }

    // --- Logic: Change Volume ---
    Process { 
        id: volAction
        onExited: volProc.running = true
    }

    // --- Interactions ---
    onClicked: (mouse) => { 
        if (mouse.button === Qt.LeftButton) {
            // Left Click: Toggle Mute
            volAction.command = ["pamixer", "-t"]
        } else if (mouse.button === Qt.RightButton) {
            // Right Click: Open Audio Control (Pavucontrol)
            volAction.command = ["pavucontrol"]
        }
        
        // Force restart action
        if (volAction.running) volAction.running = false
        volAction.running = true
    }
    
    onWheel: (wheel) => {
        // Scroll Up = Increase, Scroll Down = Decrease
        if (wheel.angleDelta.y > 0) {
            volAction.command = ["pamixer", "-i", "5"] // Changed to 5 for faster scrolling
        } else {
            volAction.command = ["pamixer", "-d", "5"]
        }

        // FIX: Force restart to catch fast scrolling
        if (volAction.running) volAction.running = false
        volAction.running = true
    }

    Component.onCompleted: volProc.running = true

    // --- Visuals ---
    RowLayout {
        id: volRow
        anchors.fill: parent
        spacing: 6
        
        Item {
            width: 24; height: 24 
            
            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4
                layer.smooth: true
                
                // Background Ring
                ShapePath {
                    fillColor: "transparent"; 
                    strokeColor: "#333344"; 
                    strokeWidth: 2; 
                    capStyle: ShapePath.RoundCap
                    // Center 12, Radius 9
                    PathAngleArc { centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90; sweepAngle: 360 }
                }
                
                // Volume Level Ring
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: volRoot.isMuted ? "#ff5555" : '#ffffff'
                    strokeWidth: 2; 
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90
                        sweepAngle: (360 * Math.min(volRoot.volumeValue, 100)) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Text { 
                anchors.centerIn: parent
                // Icon changes based on volume level
                text: volRoot.isMuted ? "󰝟" : (volRoot.volumeValue > 50 ? "󰕾" : "󰖀")
                color: "#FFFFFF"
                font.family: volRoot.iconFont
                font.pixelSize: 10 
            }
        }
    }
}