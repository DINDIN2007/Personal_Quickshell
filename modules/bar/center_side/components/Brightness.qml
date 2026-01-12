import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 3. Brightness Control
Text {
    text: "󰖙"
    color: briMouse.pressed ? "#DE3549" : "#ffffff"
    Layout.alignment: Qt.AlignVCenter

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"
    
    Process {
        id: brightnessProc
        running: false
        command: ["brightnessctl", "s", "5%+"] 
        stdout: SplitParser { onRead: data => console.log("[Brightness]: " + data) }
        stderr: SplitParser { onRead: data => console.log("[Brightness Error]: " + data) }
    }

    MouseArea {
        id: briMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                brightnessProc.command = ["brightnessctl", "s", "5%+"]
            } else {
                brightnessProc.command = ["brightnessctl", "s", "5%-"]
            }
            
            if (brightnessProc.running) brightnessProc.running = false;
            brightnessProc.running = true
        }

        onClicked: {
            brightnessProc.command = ["brightnessctl", "s", "100%"]
            if (brightnessProc.running) brightnessProc.running = false;
            brightnessProc.running = true
        }
    }
}