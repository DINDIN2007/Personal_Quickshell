import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../../../styles"

Item {
    id: cpuRoot
    Layout.preferredWidth: cpuRow.implicitWidth
    Layout.preferredHeight: 24 // Reduced height (was 32)

    // --- Properties ---
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property alias cpuProc: cpuProc

    // --- Logic ---
    Process { id: appLauncher }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1])+parseInt(parts[2])+parseInt(parts[3])+parseInt(parts[4])+parseInt(parts[5])+parseInt(parts[6])+parseInt(parts[7])
                var idle = parseInt(parts[4])+parseInt(parts[5])
                if (lastCpuTotal > 0) {
                    var diff = total - lastCpuTotal
                    var idleDiff = idle - lastCpuIdle
                    cpuUsage = Math.round(100 * (diff - idleDiff) / diff)
                }
                lastCpuTotal = total;
                lastCpuIdle = idle
            }
        }
    }

    Component.onCompleted: cpuProc.running = true

    // --- UI ---
    RowLayout {
        id: cpuRow
        anchors.fill: parent
        spacing: 6

        Item {
            width: 24; height: 24 // Reduced size (was 32)
            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 8
                layer.smooth: true
                
                // Background Ring
                ShapePath {
                    fillColor: "transparent"; 
                    strokeColor: "#333344"; 
                    strokeWidth: 2; // Thinner stroke (was 3)
                    capStyle: ShapePath.RoundCap
                    // Recalculated for 24px box: Center 12, Radius 9
                    PathAngleArc { centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90; sweepAngle: 360 }
                }
                // Value Ring
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: cpuRoot.cpuUsage > 80 ? "#ff5555" : "#8be9fd"
                    strokeWidth: 2; // Thinner stroke
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90
                        sweepAngle: (360 * cpuRoot.cpuUsage) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Text { 
                anchors.centerIn: parent; 
                text: "󰍛"; 
                color: "white"; 
                font.family: cpuRoot.iconFont; 
                font.pixelSize: 10 // Reduced icon size (was 14)
            }
        }
        Text { 
            text: cpuRoot.cpuUsage + "%"; 
            color: "white"; 
            font.bold: true 
            font.pixelSize: cpuRoot.fontSize // Ensure text scales
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => appLauncher.command = (mouse.button === Qt.RightButton) ? ["rog-control-center"] : ["missioncenter"];
        onPressedChanged: if (pressed) appLauncher.running = true
    }
}