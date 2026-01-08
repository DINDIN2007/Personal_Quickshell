import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: quickSettingsRoot
    spacing: 8 

    signal togglePowerMenu()
    
    property string iconFont: "JetBrainsMono Nerd Font"
    
    // --- Properties ---
    property bool wifiEnabled: false
    property int wifiStrength: 0 
    property string wifiName: "Disconnected"
    property bool btEnabled: false
    property bool micMuted: false 

    // --- Helper Functions ---
    function getWifiIcon(enabled, strength) {
        if (!enabled) return "󰤭"; 
        if (strength >= 75) return "󰤨"; 
        if (strength >= 50) return "󰤥"; 
        if (strength >= 25) return "󰤢"; 
        return "󰤯"; 
    }

    // --- Status Polling ---
    Process {
        id: wifiStatusProc
        command: [
            "sh", "-c", 
            "RADIO=$(nmcli -t -f WIFI g); STATE=$(nmcli -t -f STATE g); DATA=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes'); echo \"$RADIO:$STATE:$DATA\""
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
        stdout: SplitParser { onRead: data => { btEnabled = data.trim().length > 0; } }
    }

    Process {
        id: micStatusProc
        command: ["pamixer", "--default-source", "--get-mute"]
        stdout: SplitParser { onRead: data => { micMuted = (data.trim() === "true"); } }
    }

    // --- Actions ---
    Process { 
        id: actionProc
        onExited: {
            wifiStatusProc.running = true;
            btStatusProc.running = true;
        }
    }

    Process {
        id: micAction
        command: ["pamixer", "--default-source", "-t"]
        onExited: micStatusProc.running = true
    }

    Process { id: launcherProc }

    // --- NEW: Power Menu Toggle Process ---
    Process { id: menuToggleProc }

    Timer {
        interval: 3000; 
        running: true; repeat: true
        onTriggered: { 
            wifiStatusProc.running = true;
            btStatusProc.running = true
            micStatusProc.running = true 
        }
        Component.onCompleted: onTriggered()
    }

    // --- 1. WiFi ---
    Item {
        Layout.preferredWidth: 24; Layout.preferredHeight: 28 
        Text {
            anchors.centerIn: parent
            text: quickSettingsRoot.getWifiIcon(quickSettingsRoot.wifiEnabled, quickSettingsRoot.wifiStrength)
            font.family: quickSettingsRoot.iconFont; font.pixelSize: 14 
            color: wifiMouse.pressed ? "#404040" : (quickSettingsRoot.wifiEnabled ? "#ffffff" : "#a8a8a8")
        }
        MouseArea {
            id: wifiMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    let cmd = quickSettingsRoot.wifiEnabled ? "off" : "on";
                    actionProc.command = ["nmcli", "radio", "wifi", cmd];
                    actionProc.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    launcherProc.command = ["nm-connection-editor"];
                    launcherProc.running = true;
                }
            }
        }
    }

    // --- 2. Microphone ---
    Item {
        Layout.preferredWidth: 24; Layout.preferredHeight: 28 
        Text {
            anchors.centerIn: parent
            text: quickSettingsRoot.micMuted ? "󰍭" : "󰍬"
            font.family: quickSettingsRoot.iconFont; font.pixelSize: 14 
            color: micMouse.pressed ? "#404040" : (quickSettingsRoot.micMuted ? "#ff5555" : "#ffffff")
        }
        MouseArea {
            id: micMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (micAction.running) micAction.running = false;
                    micAction.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    launcherProc.command = ["pavucontrol"];
                    launcherProc.running = true;
                }
            }
        }
    }

    // --- 3. Bluetooth ---
    Item {
        Layout.preferredWidth: 24; Layout.preferredHeight: 28
        Text {
            anchors.centerIn: parent
            text: quickSettingsRoot.btEnabled ? "󰂯" : "󰂲"
            font.family: quickSettingsRoot.iconFont; font.pixelSize: 14 
            color: btMouse.pressed ? '#404040' : (quickSettingsRoot.btEnabled ? '#ffffff' : '#a8a8a8')
        }
        MouseArea {
            id: btMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    let cmd = quickSettingsRoot.btEnabled ? "off" : "on";
                    actionProc.command = ["bluetoothctl", "power", cmd];
                    actionProc.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    launcherProc.command = ["blueman-manager"];
                    launcherProc.running = true;
                }
            }
        }
    }

    // --- 4. POWER BUTTON ---
    Item {
        Layout.preferredWidth: 24;
        Layout.preferredHeight: 28 
        Text {
            anchors.centerIn: parent
            text: "" 
            font.family: quickSettingsRoot.iconFont;
            font.pixelSize: 14 
            color: pwrMouse.pressed ? "#ff5555" : "#DE3549" 
        }
        MouseArea {
            id: pwrMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Toggles the property defined in shell.qml
                //root.powerMenuOpen = !root.powerMenuOpen
                quickSettingsRoot.togglePowerMenu()
            }
        }
    }
}