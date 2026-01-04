import Quickshell
import Quickshell.Io // For process type
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: stats

    // Theme
    property color colBg: "#1a1b26"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font"

    anchors { top: true; left: true; right: true}

    implicitHeight: 30
    color: stats.colBg

    RowLayout {

    }

    // System data
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // Run shell commands with Process
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        // SplitParser calls onRead for each line of output
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a,b) => a + parseInt(b), 0)

                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                }

                lastCpuTotal = total
                lastCpuIdle = idle
            }
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = false; 
            cpuProc.running = true;
        }
    }
}