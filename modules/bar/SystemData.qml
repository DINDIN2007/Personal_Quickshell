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
    property int volumeValue: 0
    property bool isMuted: false
    property string mediaText: "Nothing playing"
    
    property int fontSize: 14
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    // --- Layout Settings ---
    Layout.preferredHeight: 38
    Layout.preferredWidth: contentRow.childrenRect.width + 30 
    
    color: Colors.widgetBg 
    radius: height / 2
    clip: true

    // --- Logic: CPU ---
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0

                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal
                    var idleDiff = idleTime - lastCpuIdle
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                    }
                }
                lastCpuTotal = total
                lastCpuIdle = idleTime
            }
        }
    }

    // --- Logic: Memory ---
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                memUsage = Math.round(100 * used / total)
            }
        }
    }

    // --- Logic: Temperature ---
    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    tempValue = Math.round(parseInt(data.trim()) / 1000)
                }
            }
        }
    }

    // --- Logic: Volume ---
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

    // --- Logic: Media ---
    Process {
        id: mediaProc
        command: ["sh", "-c", "playerctl metadata --format '{{ artist }} - {{ title }}' | cut -c 1-30"]
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                mediaText = (text.length > 0 && text !== " - ") ? text : "Stopped";
            }
        }
    }

    // --- Logic: Advanced Player Focus ---
    Process {
        id: focusPlayerProc
        command: ["sh", "-c", "
            PLAYER=$(playerctl metadata --format '{{playerName}}' | tr '[:upper:]' '[:lower:]')
            ADDR=$(hyprctl clients -j | jq -r \".[] | select((.class | translate(\\\"[:upper:]\\\", \\\"[:lower:]\\\") == \\\"$PLAYER\\\") or (.initialClass | translate(\\\"[:upper:]\\\", \\\"[:lower:]\\\") == \\\"$PLAYER\\\")) | .address\" | head -n 1)
            if [ -n \"$ADDR\" ]; then
                hyprctl dispatch focuswindow address:\"$ADDR\"
            else
                hyprctl dispatch focuswindow \"$PLAYER\"
            fi
        "]
    }

    Process { id: volAction }

    // --- Update Timers ---
    Timer {
        interval: 2000
        running: true; repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            tempProc.running = true
            mediaProc.running = true
        }
        Component.onCompleted: onTriggered()
    }

    Timer {
        interval: 500
        running: true; repeat: true
        onTriggered: volProc.running = true
    }

    // --- UI: Content Row ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        // --- SPACE REDUCED HERE (from 16 to 8) ---
        spacing: 8 

        // --- CPU ---
        RowLayout {
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
                        fillColor: "transparent"; strokeColor: systemDataRoot.cpuUsage > 80 ? "#ff5555" : "#8be9fd"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                            sweepAngle: (360 * systemDataRoot.cpuUsage) / 100
                            Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                        }
                    }
                }
                Text { anchors.centerIn: parent; text: "󰍛"; color: "#FFFFFF"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }            
            }
            Text { text: systemDataRoot.cpuUsage + "%"; color: "#FFFFFF"; font.pixelSize: systemDataRoot.fontSize; font.family: systemDataRoot.fontFamily; font.bold: true }
        }

        // --- MEMORY ---
        RowLayout {
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
                        fillColor: "transparent"; strokeColor: systemDataRoot.memUsage > 85 ? "#ff5555" : "#bd93f9"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                            sweepAngle: (360 * systemDataRoot.memUsage) / 100
                            Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                        }
                    }
                }
                Text { anchors.centerIn: parent; text: "󰘚"; color: "#FFFFFF"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }            
            }
            Text { text: systemDataRoot.memUsage + "%"; color: "#FFFFFF"; font.pixelSize: systemDataRoot.fontSize; font.family: systemDataRoot.fontFamily; font.bold: true }
        }

        // --- TEMPERATURE ---
        RowLayout {
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
                        fillColor: "transparent"; strokeColor: systemDataRoot.tempValue > 75 ? "#ff5555" : "#ffb86c"; strokeWidth: 3; capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: 16; centerY: 16; radiusX: 12; radiusY: 12; startAngle: -90
                            sweepAngle: (360 * Math.min(systemDataRoot.tempValue, 100)) / 100
                            Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                        }
                    }
                }
                Text { anchors.centerIn: parent; text: ""; color: "#FFFFFF"; font.family: systemDataRoot.iconFont; font.pixelSize: 14 }
            }
            Text { text: systemDataRoot.tempValue + "°C"; color: "#FFFFFF"; font.pixelSize: systemDataRoot.fontSize; font.family: systemDataRoot.fontFamily; font.bold: true }
        }

        Volume {}
        Media {}
    }
}