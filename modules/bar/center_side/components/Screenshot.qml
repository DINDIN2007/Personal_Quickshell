import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

Text {
    text: "󰆟"
    color: screenshotMouse.pressed ? "#DE3549" : "#ffffff"
    Layout.alignment: Qt.AlignVCenter

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"
    
    Process {
        id: screenshotProc
        running: false
        command: ["hyprctl", "dispatch", "exec", "/home/dinhv/debug_shot.sh"]
        stdout: SplitParser { onRead: data => console.log("[Screenshot]: " + data) }
    }

    Component.onCompleted: screenshotProc.running = false;

    MouseArea {
        id: screenshotMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (screenshotProc.running) screenshotProc.running = false
            screenshotProc.running = true
        }
    }
}