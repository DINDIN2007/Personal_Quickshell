import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../styles"

Rectangle {
    id: clockRoot
    
    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"
    property int batteryLevel: 0
    property bool isCharging: false
    
    Layout.preferredHeight: 28
    Layout.preferredWidth: contentRow.implicitWidth + 20
    
    color: Colors.widgetBg
    radius: height / 2
    
    // --- Logic: Time ---
    function updateTime() {
        let date = new Date();
        let timeStr = Qt.formatDateTime(date, "h:mm ap").toLowerCase();
        let dateStr = Qt.formatDateTime(date, "ddd, MM/dd");
        timeText.text = timeStr + " • " + dateStr;
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRoot.updateTime() }
    
    // --- Logic: Battery & Tools ---
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
                        if (!isNaN(val)) clockRoot.batteryLevel = val;
                    }
                    if (line.startsWith("state:")) {
                        clockRoot.isCharging = (line.includes("charging") && !line.includes("discharging"));
                    }
                }
            }
        }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: batProc.running = true }
    
    Process {
        id: screenshotProc
        running: false
        command: ["hyprctl", "dispatch", "exec", "/home/dinhv/debug_shot.sh"]
        stdout: SplitParser { onRead: data => console.log("[Screenshot]: " + data) }
    }

    Process {
        id: colorPickerProc
        running: false
        command: ["hyprpicker", "-a"] 
    }

    // --- FIX: Brightness Logic ---
    Process {
        id: brightnessProc
        running: false
        command: ["brightnessctl", "s", "5%+"] 
        
        // Debugging: If this prints an error in your terminal, you likely need to install 'brightnessctl'
        stdout: SplitParser { onRead: data => console.log("[Brightness]: " + data) }
        stderr: SplitParser { onRead: data => console.log("[Brightness Error]: " + data) }
    }

    Component.onCompleted: { updateTime(); batProc.running = true; screenshotProc.running = false; colorPickerProc.running = false; }

    // --- UI Content ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8 

        // 1. Clock
        Text {
            id: timeText
            Layout.alignment: Qt.AlignVCenter 
            color: "#ffffff"
            font.pixelSize: clockRoot.fontSize
            font.family: clockRoot.fontFamily
            font.bold: true
            renderType: Text.NativeRendering
        }
        
        // 2. Color Picker
        Text {
            text: "󰴱"
            color: pickerMouse.pressed ? "#bd93f9" : "#ffffff"
            font.pixelSize: 14
            font.family: clockRoot.iconFont
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 20

            MouseArea {
                id: pickerMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (colorPickerProc.running) colorPickerProc.running = false
                    colorPickerProc.running = true
                }
            }
        }

        // 3. Brightness Control (Fixed)
        Text {
            text: "󰖙"
            color: briMouse.pressed ? "#bd93f9" : "#ffffff"
            font.pixelSize: 14
            font.family: clockRoot.iconFont
            Layout.alignment: Qt.AlignVCenter
            
            MouseArea {
                id: briMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                
                onWheel: (wheel) => {
                    // Update command based on scroll direction
                    if (wheel.angleDelta.y > 0) {
                        brightnessProc.command = ["brightnessctl", "s", "5%+"]
                    } else {
                        brightnessProc.command = ["brightnessctl", "s", "5%-"]
                    }
                    
                    // FIX: Force reset the process if you scroll fast
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

        // 4. Screenshot Button
        Text {
            text: "󰆟"
            color: screenshotMouse.pressed ? "#bd93f9" : "#ffffff"
            font.pixelSize: 14
            font.family: clockRoot.iconFont 
            Layout.alignment: Qt.AlignVCenter
            
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

        // 5. Battery
        Rectangle {
            id: batContainer
            Layout.preferredWidth: 32
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter 
            radius: 8
            color: "#333333" 
            clip: true 

            Rectangle {
                id: batFill
                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                width: parent.width * (clockRoot.batteryLevel / 100)
                radius: 8
                color: "#ffffff"
                Behavior on width { NumberAnimation { duration: 300 } }
            }

            Text {
                id: whiteBatText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1 
                text: clockRoot.batteryLevel + "%"
                font.pixelSize: 9
                font.family: clockRoot.fontFamily; font.bold: true
                color: "#ffffff"; renderType: Text.NativeRendering
            }

            Item {
                anchors.fill: batFill; clip: true 
                Text {
                    x: whiteBatText.x; y: whiteBatText.y
                    width: whiteBatText.width; height: whiteBatText.height
                    text: whiteBatText.text; font: whiteBatText.font
                    color: "#000000"; renderType: Text.NativeRendering
                }
            }
        }
    }
}