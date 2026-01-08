import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../styles" 

PanelWindow {
    id: osdWindow
    
    // --- Configuration ---
    property int fontSize: 14
    property string fontName: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"
    
    // --- State ---
    property int currentVal: 0
    property string type: "volume" 
    property bool revealed: false

    property int lastVol: -1
    property int lastBri: -1
    
    property bool volInitialized: false
    property bool briInitialized: false

    // --- POSITIONING ---
    anchors {} // Center on screen
    exclusionMode: ExclusionMode.Ignore // Float over windows

    width: 250
    height: 60
    
    color: "transparent"
    visible: revealed

    // --- Logic: Auto-Hide Timer ---
    Timer {
        id: hideTimer
        interval: 2000 
        onTriggered: osdWindow.revealed = false
    }

    function showOSD(newType, value) {
        type = newType
        currentVal = value
        revealed = true
        hideTimer.restart()
    }

    // --- Logic: Volume Polling ---
    Process {
        id: volPoll
        // FIX: Use 'echo' to force both values onto a single line (atomic output)
        command: ["sh", "-c", "echo $(pamixer --get-volume) $(pamixer --get-mute)"]
        
        stdout: SplitParser {
            onRead: data => {
                // Now we split by space, not newline
                let parts = data.trim().split(" ")
                
                // If we don't get both values, ignore this read
                if (parts.length < 2) return
                
                let vol = parseInt(parts[0])
                let muted = (parts[1] === "true")
                
                if (muted) vol = 0;

                // Show OSD only if volume changed (and it's not the first load)
                if (osdWindow.volInitialized && osdWindow.lastVol !== vol) {
                    osdWindow.showOSD("volume", vol)
                }
                
                osdWindow.lastVol = vol
                osdWindow.volInitialized = true
            }
        }
    }

    // --- Logic: Brightness Polling ---
    Process {
        id: briPoll
        command: ["sh", "-c", "echo $(brightnessctl g) $(brightnessctl m)"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ")
                if (parts.length < 2) return

                let current = parseInt(parts[0])
                let max = parseInt(parts[1])
                let percent = Math.round((current / max) * 100)

                if (osdWindow.briInitialized && osdWindow.lastBri !== percent) {
                    osdWindow.showOSD("brightness", percent)
                }
                
                osdWindow.lastBri = percent
                osdWindow.briInitialized = true
            }
        }
    }

    // Poll frequently (100ms)
    Timer {
        interval: 100
        running: true; repeat: true
        onTriggered: {
            volPoll.running = true
            briPoll.running = true
        }
    }

    // --- UI Design ---
    Rectangle {
        anchors.fill: parent
        color: "#11111b" 
        radius: 10       
        
        border.color: "#333333"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // 1. Icon Container
            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
                
                Text {
                    anchors.centerIn: parent
                    font.family: osdWindow.iconFont
                    font.pixelSize: 24
                    color: "#ffffff"
                    
                    text: {
                        if (osdWindow.type === "brightness") return "󰃠"
                        // Volume Icons
                        if (osdWindow.currentVal === 0) return "󰝟"
                        if (osdWindow.currentVal < 50) return "󰖀"
                        return "󰕾"
                    }
                }
            }

            // 2. Data Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                // Top Row: Label ... Value
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: osdWindow.type === "volume" ? "Volume" : "Brightness"
                        color: "#ffffff"
                        font.family: osdWindow.fontName
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                    }
                    
                    Item { Layout.fillWidth: true } 
                    
                    Text {
                        text: osdWindow.currentVal
                        color: "#ffffff"
                        font.family: osdWindow.fontName
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignRight
                    }
                }

                // Bottom Row: Progress Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    color: "#45475a" 
                    radius: 3
                    
                    Rectangle {
                        height: parent.height
                        radius: 3
                        width: (parent.width * osdWindow.currentVal) / 100
                        
                        // Switch color based on type
                        color: osdWindow.type === "brightness" ? "#DE3549" : "#F8A571"
                        
                        Behavior on width { 
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad } 
                        }
                    }
                }
            }
        }
    }
}