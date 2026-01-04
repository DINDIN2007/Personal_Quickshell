import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../styles"

Rectangle {
    id: systemDataRoot

    // --- Properties ---
    property int cpuUsage: 0
    property int memUsage: 0
    property int tempValue: 0 
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    
    property int fontSize: 14
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    // Layout
    Layout.preferredHeight: 38
    Layout.preferredWidth: contentRow.implicitWidth + 30
    color: Colors.widgetBg 
    radius: height / 2
    clip: true

    // --- 1. The Crash Fix: Helper Function ---
    function refreshData() {
        cpuProc.running = true
        memProc.running = true
        tempProc.running = true
    }

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
                lastCpuTotal = total; lastCpuIdle = idle
            }
        }
    }
    
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser { onRead: data => { var p=data.trim().split(/\s+/); memUsage = Math.round(100*p[2]/p[1]) } }
    }

    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser { onRead: data => tempValue = Math.round(parseInt(data)/1000) }
    }

    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: systemDataRoot.refreshData()
    }

    Component.onCompleted: refreshData()

    // --- UI ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 12

        // --- CPU ---
        Item {
            Layout.preferredWidth: cpuRow.implicitWidth
            Layout.preferredHeight: 32

            RowLayout {
                id: cpuRow
                anchors.fill: parent
                spacing: 8
                
                // Pie Chart Container
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
                        // Value Ring
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: systemDataRoot.cpuUsage > 80 ? "#ff5555" : "#8be9fd"
                            strokeWidth: 3; capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                                sweepAngle: (360 * systemDataRoot.cpuUsage) / 100
                                Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                    Text { anchors.centerIn: parent; text: "󰍛"; color: "white"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }
                }
                Text { text: systemDataRoot.cpuUsage + "%"; color: "white"; font.bold: true }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => appLauncher.command = (mouse.button === Qt.RightButton) ? ["rog-control-center"] : ["missioncenter"];
                onPressedChanged: if (pressed) appLauncher.running = true
            }
        }

        // --- MEMORY ---
        Item {
            Layout.preferredWidth: memRow.implicitWidth
            Layout.preferredHeight: 32

            RowLayout {
                id: memRow
                anchors.fill: parent
                spacing: 8
                
                Item {
                    width: 32; height: 32
                    Shape {
                        anchors.fill: parent
                        layer.enabled: true; layer.samples: 4
                        ShapePath {
                            fillColor: "transparent"; strokeColor: "#333344"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                            PathAngleArc { centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90; sweepAngle: 360 }
                        }
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: systemDataRoot.memUsage > 85 ? "#ff5555" : "#bd93f9"
                            strokeWidth: 3; capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                                sweepAngle: (360 * systemDataRoot.memUsage) / 100
                                Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                    Text { anchors.centerIn: parent; text: "󰘚"; color: "white"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }
                }
                Text { text: systemDataRoot.memUsage + "%"; color: "white"; font.bold: true }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => appLauncher.command = (mouse.button === Qt.RightButton) ? ["rog-control-center"] : ["missioncenter"];
                onPressedChanged: if (pressed) appLauncher.running = true
            }
        }

        // --- TEMPERATURE ---
        Item {
            Layout.preferredWidth: tempRow.implicitWidth
            Layout.preferredHeight: 32

            RowLayout {
                id: tempRow
                anchors.fill: parent
                spacing: 8
                
                Item {
                    width: 32; height: 32
                    Shape {
                        anchors.fill: parent
                        layer.enabled: true; layer.samples: 4
                        ShapePath {
                            fillColor: "transparent"; strokeColor: "#333344"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                            PathAngleArc { centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90; sweepAngle: 360 }
                        }
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: systemDataRoot.tempValue > 75 ? "#ff5555" : "#ffb86c"
                            strokeWidth: 3; capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                                sweepAngle: (360 * Math.min(systemDataRoot.tempValue, 100)) / 100
                                Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                    Text { anchors.centerIn: parent; text: ""; color: "white"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }
                }
                Text { text: systemDataRoot.tempValue + "°C"; color: "white"; font.bold: true }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => appLauncher.command = (mouse.button === Qt.RightButton) ? ["rog-control-center"] : ["missioncenter"];
                onPressedChanged: if (pressed) appLauncher.running = true
            }
        }

        Volume {}
        Media {}
    }
}