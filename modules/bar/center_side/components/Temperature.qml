import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../../../styles"

Item {
    id: tempRoot
    Layout.preferredWidth: tempRow.implicitWidth
    Layout.preferredHeight: 24

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    // --- Properties ---
    property int tempValue: 0

    property alias tempProc: tempProc

    // --- Logic ---
    Process { id: appLauncher }

    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser { onRead: data => tempValue = Math.round(parseInt(data)/1000) }
    }

    Component.onCompleted: tempProc.running = true

    // --- UI ---
    RowLayout {
        id: tempRow
        anchors.fill: parent
        spacing: 6
        
        Item {
            width: 24; height: 24
            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 8
                layer.smooth: true

                ShapePath {
                    fillColor: "transparent"; 
                    strokeColor: "#333344"; 
                    strokeWidth: 2; 
                    capStyle: ShapePath.RoundCap
                    PathAngleArc { centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90; sweepAngle: 360 }
                }
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: tempRoot.tempValue > 75 ? "#ff5555" : "#ffb86c"
                    strokeWidth: 2; 
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90
                        sweepAngle: (360 * Math.min(tempRoot.tempValue, 100)) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Text { 
                anchors.centerIn: parent; 
                text: ""; 
                color: "white"; 
                font.family: tempRoot.iconFont; 
                font.pixelSize: 10 
            }
        }
        Text { 
            text: tempRoot.tempValue + "°C"; 
            color: "white"; 
            font.bold: true 
            font.pixelSize: tempRoot.fontSize
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