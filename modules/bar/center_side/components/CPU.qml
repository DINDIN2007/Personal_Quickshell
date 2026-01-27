import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../../../styles"

Item {
    id: cpuRoot
    Layout.preferredWidth: cpuRow.implicitWidth
    Layout.preferredHeight: 24

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

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

        // Scale based on mouse state
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

            // Click ripple effect
            Rectangle {
                id: ripple
                anchors.centerIn: parent
                width: 0
                height: width
                radius: width / 2
                color: "#ffffff"
                opacity: 0

                ParallelAnimation {
                    id: rippleAnim
                    NumberAnimation {
                        target: ripple
                        property: "width"
                        from: 0
                        to: 40
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: ripple
                        property: "opacity"
                        from: 0.3
                        to: 0
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 8
                layer.smooth: true

                // Background Ring
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: "#333344"
                    strokeWidth: 2
                    capStyle: ShapePath.RoundCap
                    PathAngleArc { centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90; sweepAngle: 360 }
                }

                // Value Ring
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: cpuRoot.cpuUsage > 80 ? "#ff5555" : "#8be9fd"
                    strokeWidth: 2
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: 12; centerY: 12; radiusX: 9; radiusY: 9; startAngle: -90
                        sweepAngle: (360 * cpuRoot.cpuUsage) / 100
                        Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰍛"
                color: "white"
                font.family: cpuRoot.iconFont
                font.pixelSize: 10
            }
        }

        Text {
            text: cpuRoot.cpuUsage + "%"
            color: "white"
            font.bold: true
            font.pixelSize: cpuRoot.fontSize
        }
    }

    // MouseArea must be outside RowLayout, at root level
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