import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 5. Battery
Rectangle {
    id: batRoot
    Layout.preferredWidth: 32
    Layout.preferredHeight: 16
    Layout.alignment: Qt.AlignVCenter 
    radius: 8
    color: "#333333" 
    clip: true
    Layout.leftMargin: 5

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    property int batteryLevel: 0
    property bool isCharging: false

    // --- Logic: Battery Polling ---
    Process {
        id: batProc
        command: ["sh", "-c", "upower -i /org/freedesktop/UPower/devices/DisplayDevice"]
        stdout: SplitParser {
            onRead: data => {
                let lines = data.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (line.startsWith("percentage:")) {
                        let valStr = line.split(":")[1].replace("%", "").trim();
                        let val = parseInt(valStr);
                        if (!isNaN(val)) batRoot.batteryLevel = val;
                    }
                    if (line.startsWith("state:")) {
                        batRoot.isCharging = (line.includes("charging") && !line.includes("discharging"));
                    }
                }
            }
        }
    }

    // Auto Updates every 5 seconds
    Timer { 
        interval: 5000
        running: true
        repeat: true
        onTriggered: batProc.running = true 
    }

    // Initialize on load
    Component.onCompleted: batProc.running = true

    // --- UI Content --
    Rectangle {
        id: batFill
        anchors.left: parent.left
        anchors.top: parent.top 
        anchors.bottom: parent.bottom
        width: parent.width * (batRoot.batteryLevel / 100)
        radius: 8
        
        // Change color based on isCharging status
        color: batRoot.isCharging ? '#259b56' : "#ffffff"
        
        Behavior on width { NumberAnimation { duration: 300 } }
        Behavior on color { ColorAnimation { duration: 300 } } 
    }

    Text {
        id: whiteBatText
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1 
        text: batRoot.batteryLevel + "%"
        font.pixelSize: 9
        font.family: batRoot.fontFamily;
        font.bold: true
        color: "#ffffff";
        renderType: Text.NativeRendering
    }

    Item {
        anchors.fill: batFill;
        clip: true 
        Text {
            x: whiteBatText.x;
            y: whiteBatText.y
            width: whiteBatText.width;
            height: whiteBatText.height
            text: whiteBatText.text;
            font: whiteBatText.font
            color: "#000000";
            renderType: Text.NativeRendering
        }
    }
}