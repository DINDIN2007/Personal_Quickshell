import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: quickSettingsRoot
    spacing: 12
    
    property string iconFont: "JetBrainsMono Nerd Font"
    property bool wifiEnabled: false
    property int wifiStrength: 0 
    property string wifiName: "Disconnected"
    property bool btEnabled: false

    function getWifiIcon(enabled, strength) {
        if (!enabled) return "󰤭"; 
        if (strength >= 75) return "󰤨"; 
        if (strength >= 50) return "󰤥"; 
        if (strength >= 25) return "󰤢"; 
        return "󰤯"; 
    }

    // --- Logic: Status Polling ---
    Process {
        id: wifiStatusProc
        command: [
            "sh", "-c", 
            "RADIO=$(nmcli -t -f WIFI g); " +
            "STATE=$(nmcli -t -f STATE g); " +
            "DATA=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes'); " + 
            "echo \"$RADIO:$STATE:$DATA\""
        ]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(':');
                if (parts.length >= 2) {
                    let radio = parts[0];
                    let state = parts[1];
                    if (radio === "enabled" && state === "connected" && parts.length >= 5) {
                        wifiEnabled = true;
                        wifiName = parts[3]; 
                        wifiStrength = parseInt(parts[4]) || 0;
                    } else {
                        wifiEnabled = (radio === "enabled");
                        wifiStrength = 0;
                        wifiName = "Disconnected";
                    }
                }
            }
        }
    }

    Process {
        id: btStatusProc
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes'"]
        stdout: SplitParser {
            onRead: data => { btEnabled = data.trim().length > 0; }
        }
    }

    // --- Logic: Actions ---
    Process { 
        id: actionProc
        // When the command finishes, refresh the status immediately
        onExited: {
            wifiStatusProc.running = true;
            btStatusProc.running = true;
        }
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: { wifiStatusProc.running = true; btStatusProc.running = true }
        Component.onCompleted: onTriggered()
    }

    // --- UI: WiFi ---
    Item {
        Layout.preferredWidth: 30 
        Layout.preferredHeight: 38
        
        Text {
            anchors.centerIn: parent
            text: quickSettingsRoot.getWifiIcon(quickSettingsRoot.wifiEnabled, quickSettingsRoot.wifiStrength)
            font.family: quickSettingsRoot.iconFont
            font.pixelSize: 18
            // Visual Feedback: Turns Red when pressed, otherwise Blue(On) or Grey(Off)
            color: wifiMouse.pressed ? "#404040" : (quickSettingsRoot.wifiEnabled ? "#ffffff" : "#a8a8a8")
        }

        MouseArea {
            id: wifiMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // TOGGLE WIFI
                    let cmd = quickSettingsRoot.wifiEnabled ? "off" : "on";
                    actionProc.command = ["nmcli", "radio", "wifi", cmd];
                    actionProc.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    // OPEN EDITOR
                    actionProc.command = ["nm-connection-editor"];
                    actionProc.running = true;
                }
            }
        }
    }

    // --- UI: Bluetooth ---
    Item {
        Layout.preferredWidth: 30
        Layout.preferredHeight: 38

        Text {
            anchors.centerIn: parent
            text: quickSettingsRoot.btEnabled ? "󰂯" : "󰂲"
            font.family: quickSettingsRoot.iconFont
            font.pixelSize: 18
            // Visual Feedback: Turns Red when pressed, otherwise Purple(On) or Grey(Off)
            color: btMouse.pressed ? '#404040' : (quickSettingsRoot.btEnabled ? '#ffffff' : '#a8a8a8')
        }

        MouseArea {
            id: btMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // TOGGLE BLUETOOTH
                    let cmd = quickSettingsRoot.btEnabled ? "off" : "on";
                    actionProc.command = ["bluetoothctl", "power", cmd];
                    actionProc.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    // OPEN MANAGER
                    actionProc.command = ["blueman-manager"];
                    actionProc.running = true;
                }
            }
        }
    }
}