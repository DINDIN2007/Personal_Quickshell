import Quickshell
import Quickshell.Widgets
import Quickshell.Io // <--- Added for Process
import QtQuick
import QtQuick.Layouts

Image {
    source: "file:///home/dinhv/.config/quickshell/assets/icons/Cachyos_Logo.svg"
    
    Layout.preferredWidth: 20
    Layout.preferredHeight: 20
    
    fillMode: Image.PreserveAspectFit

    // Define the command to run
    Process {
        id: fastfetchProc
        // "kitty --hold" keeps the window open after the command finishes
        command: ["kitty", "--hold", "fastfetch"] 
    }

    // Detect the click
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor // Changes cursor to a hand on hover
        onClicked: {
            fastfetchProc.running = true
        }
    }

    Rectangle {
        width: parent.width + 8
        height: parent.height + 8
        radius: 14 

        anchors.centerIn: parent
        
        color: "#DE3549"
        opacity: 0.5
        z: -1
    }
}