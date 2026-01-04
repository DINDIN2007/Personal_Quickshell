import Quickshell
import Quickshell.Hyprland // Required for the event listener
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../styles"

Rectangle {
    id: activeWindowRoot

    // --- Properties --
    property string windowClass: "" // e.g., "org.quickshell"
    property string windowTitle: "" // e.g., "illogical-impulse Settings"

    property int fontSize: 14 
    property string fontFamily: "sans-serif"

    // --- Logic ---
    // Active window title
    Process {
        id: windowProc
        // The -c flag in jq is crucial: it outputs the JSON on a single line
        command: ["sh", "-c", "hyprctl activewindow -j | jq -c '.'"]

        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "" || data.trim() === "{}") {
                    windowClass = "Hyprland";
                    windowTitle = "Desktop";
                    return;
                }

                try {
                    const windowData = JSON.parse(data);
                    windowClass = windowData.class || "";
                    windowTitle = windowData.title || "";
                } catch (e) {
                    // If it fails, fallback to Desktop
                    windowClass = "Hyprland";
                    windowTitle = "Desktop";
                }
            }
        }

        Component.onCompleted: running = true
    }

    // This listener ensures the process runs whenever you switch windows
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
        }
    }

    // Periodic backup timer
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }

    // --- UI ---
    Layout.preferredHeight: 30 
    Layout.preferredWidth: titleRow.childrenRect.width + 24 

    color: Colors.barBg // Or a slightly lighter color for contrast
    radius: height / 2
    clip: true

    ColumnLayout {
    
        id: titleRow
        anchors.centerIn: parent
    
        // Set this to 0 to remove default space, 
        // or -2 to make it even tighter like your reference image
        spacing: -4

        Text {
            text: windowClass
            color: "#888899"
            font.pixelSize: fontSize - 5
            font.family: fontFamily
            font.bold: true
            visible: text !== ""
        
            // Ensure it stays centered if the title below it is wider
            Layout.alignment: Qt.AlignLeft
        }

        Text {
            id: titleText
            text: windowTitle
            color: "#FFFFFF"
            font.pixelSize: fontSize
            font.family: fontFamily
            font.bold: true
        
            Layout.alignment: Qt.AlignLeft
            elide: Text.ElideRight
            Layout.maximumWidth: 400 
        }
    }
}