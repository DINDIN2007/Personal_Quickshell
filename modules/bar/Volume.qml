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

    Layout.preferredWidth: volRow.implicitWidth
    Layout.preferredHeight: 38
    cursorShape: Qt.PointingHandCursor
    
    // Accept both buttons
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // --- Logic: Fetch Volume ---
    Process {
        id: volProc
        command: ["sh", "-c", "pamixer --get-volume && pamixer --get-mute"]
        stdout: SplitParser {
            onRead: data => {
                let cleanData = data.trim();
                if (cleanData === "true") isMuted = true;
                else if (cleanData === "false") isMuted = false;
                else {
                    let val = parseInt(cleanData);
                    if (!isNaN(val)) volumeValue = val;
                }
            }
        }
    }

    // --- Logic: Actions ---
    Process { id: volAction }

    Timer {
        interval: 500
        running: true; repeat: true
        onTriggered: volProc.running = true
    }

    // --- CLICK HANDLER ---
    onClicked: (mouse) => { 
        if (mouse.button === Qt.LeftButton) {
            // Left Click: Toggle Mute
            volAction.command = ["pamixer", "-t"]
            volAction.running = true
            volProc.running = true 
        } else if (mouse.button === Qt.RightButton) {
            // Right Click: Open Pavucontrol
            volAction.command = ["pavucontrol"]
            volAction.running = true
        }
    }
    
    // Scroll to adjust volume
    onWheel: (wheel) => {
        volAction.command = wheel.angleDelta.y > 0 ? ["pamixer", "-i", "2"] : ["pamixer", "-d", "2"]
        volAction.running = true
        volProc.running = true
    }

    // --- Visuals ---
    RowLayout {
        id: volRow
        anchors.fill: parent
        spacing: 8
        Item {
            width: 32; height: 32
            Shape {
                anchors.fill: parent
                layer.enabled: true; layer.samples: 4
                
                // Background Ring
                ShapePath {
                    fillColor: "transparent"; strokeColor: "#333344"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                    PathAngleArc { centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90; sweepAngle: 360 }
                }
                
                // Volume Level Ring
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: volRoot.isMuted ? "#ff5555" : '#ffffff'
                    strokeWidth: 3; capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                        sweepAngle: (360 * Math.min(volRoot.volumeValue, 100)) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Text { 
                anchors.centerIn: parent
                text: volRoot.isMuted ? "󰝟" : (volRoot.volumeValue > 50 ? "󰕾" : "󰖀")
                color: "#FFFFFF"; font.family: volRoot.iconFont; font.pixelSize: 14 
            }
        }
    }
}