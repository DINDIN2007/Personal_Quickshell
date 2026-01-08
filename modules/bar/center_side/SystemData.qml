import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../../styles"
import "./components"

Rectangle {
    id: systemDataRoot
    
    // Default value if not passed down from Bar.qml
    property int fontSize: 14
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    Layout.preferredHeight: 28
    Layout.preferredWidth: contentRow.implicitWidth + 20
    
    color: Colors.widgetBg 
    radius: height / 2
    clip: true

    // --- Timer (for CPU, Memory and Temperature Indicators) ---
    Timer {
        interval: 2000;
        running: true; repeat: true
        onTriggered: {
            cpuRoot.cpuProc.running = true
            memRoot.memProc.running = true
            tempRoot.tempProc.running = true
            volRoot.volProc.running = true
        }
    }

    // --- UI ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8 // Reduced spacing (was 12)

        // --- CPU ---
        CPU {
            id: cpuRoot  // <--- ADD THIS ID
        }

        // --- MEMORY ---
        Memory {
            id: memRoot  // <--- ADD THIS ID
        }

        // --- TEMPERATURE ---
        Temperature {
            id: tempRoot // <--- ADD THIS ID
        }

        Volume {}
        Media {}
    }
}