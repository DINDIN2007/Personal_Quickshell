import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../../../styles"

Item {
    id: memRoot
    Layout.preferredWidth: memRow.implicitWidth
    Layout.preferredHeight: 24

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    // --- Properties ---
    property int memUsage: 0

    property alias memProc: memProc

    // --- Logic ---
    Process { id: appLauncher }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser { onRead: data => { var p=data.trim().split(/\s+/); memUsage = Math.round(100*p[2]/p[1]) } }
    }

    Component.onCompleted: memProc.running = true

    // --- UI ---
    RowLayout {
        id: memRow
        anchors.fill: parent
        spacing: 6
        
        // Scale and animation properties
        scale: mouseArea.pressed ? 0.9 : mouseArea.containsMouse ? 1.08 : 1.0
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }

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
                    strokeColor: memRoot.memUsage > 85 ? "#ff5555" : "#bd93f9"
                    strokeWidth: 2; 
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90
                        sweepAngle: (360 * memRoot.memUsage) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Text { 
                anchors.centerIn: parent; 
                text: "󰘚"; 
                color: "white"; 
                font.family: memRoot.iconFont; 
                font.pixelSize: 10 
            }
        }
        Text { 
            text: memRoot.memUsage + "%"; 
            color: "white"; 
            font.bold: true 
            font.pixelSize: memRoot.fontSize
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onClicked: (mouse) => {
            rippleAnim.start()
            appLauncher.command = (mouse.button === Qt.RightButton) ? ["rog-control-center"] : ["missioncenter"]
            appLauncher.running = true
        }
    }
}