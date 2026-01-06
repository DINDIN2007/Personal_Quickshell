import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: pwrBtnRoot
    
    Layout.preferredWidth: 30
    Layout.preferredHeight: 28 

    property string iconFont: "JetBrainsMono Nerd Font"

    Process { id: toggleProc }

    Text {
        anchors.centerIn: parent
        text: "" 
        font.family: pwrBtnRoot.iconFont
        font.pixelSize: 16
        // Red when pressed, White normally
        color: mouse.pressed ? "#ff5555" : "#ffffff" 
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // Toggles the lock file which PowerMenu listens for
            toggleProc.command = ["sh", "-c", "[ -f /tmp/qs_powermenu ] && rm /tmp/qs_powermenu || touch /tmp/qs_powermenu"]
            toggleProc.running = true
        }
    }
}