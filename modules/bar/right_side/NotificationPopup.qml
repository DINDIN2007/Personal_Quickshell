import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../../styles"

PanelWindow {
    id: notificationPopup
    
    property bool isOpen: false
    property var notifications: []
    property int notifCount: 0
    
    signal closeRequested()
    
    visible: isOpen
    
    WlrLayershell.namespace: "notification-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 48
        right: 10
    }
    
    implicitWidth: 380
    implicitHeight: Math.min(500, contentColumn.implicitHeight + 20)
    
    color: "transparent"
    
    onIsOpenChanged: {
        if (isOpen) {
            notifProc.running = true;
        }
    }
    
    // Read notifications from swaync cache file
    Process {
        id: notifProc
        command: ["sh", "-c", "cat ~/.local/share/swaync/notifications.json 2>/dev/null || echo '[]'"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    let parsed = JSON.parse(data.trim());
                    // swaync stores as array of notification objects
                    notificationPopup.notifications = parsed.reverse();
                } catch (e) {
                    notificationPopup.notifications = [];
                }
            }
        }
    }
    
    // Get notification count
    Process {
        id: countProc
        command: ["swaync-client", "-c", "-sw"]
        stdout: SplitParser {
            onRead: data => {
                notificationPopup.notifCount = parseInt(data.trim()) || 0;
            }
        }
    }
    
    // Close a notification
    Process {
        id: closeLatestProc
        command: ["swaync-client", "--close-latest", "-sw"]
        onExited: notifProc.running = true
    }
    
    // Clear all notifications
    Process {
        id: clearAllProc
        command: ["swaync-client", "-C", "-sw"]
        onExited: notifProc.running = true
    }
    
    // Auto-refresh while open
    Timer {
        interval: 2000
        running: notificationPopup.isOpen
        repeat: true
        onTriggered: notifProc.running = true
    }
    
    Rectangle {
        anchors.fill: parent
        color: Colors.barBg
        radius: 8
        border.color: Colors.widgetBg
        border.width: 1
        
        focus: true
        Keys.onEscapePressed: notificationPopup.closeRequested()
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "󰂚  Notifications"
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                // Clear all button
                Text {
                    text: "Clear All"
                    color: clearAllMouse.containsMouse ? "#f38ba8" : "#6c7086"
                    font.pixelSize: 11
                    visible: notificationPopup.notifications.length > 0
                    
                    MouseArea {
                        id: clearAllMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clearAllProc.running = true
                    }
                }
                
                // Close button
                Text {
                    text: "󰅖"
                    color: closeBtnMouse.containsMouse ? "#f38ba8" : "#6c7086"
                    font.pixelSize: 12
                    leftPadding: 10
                    
                    MouseArea {
                        id: closeBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notificationPopup.closeRequested()
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#45475a"
            }
            
            // Notification list
            ListView {
                id: notifList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(400, count * 80)
                clip: true
                spacing: 6
                
                model: notificationPopup.notifications
                
                delegate: Rectangle {
                    width: notifList.width
                    height: notifContent.implicitHeight + 16
                    radius: 8
                    color: itemMouse.containsMouse ? '#3f3f40' : Colors.widgetBg
                    
                    RowLayout {
                        id: notifContent
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        
                        // App icon
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignTop
                            radius: 8
                            color: "#45475a"
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    let appName = modelData["app-name"] || modelData.appName || modelData["app_name"] || "";
                                    if (appName.toLowerCase().includes("discord")) return "󰙯";
                                    if (appName.toLowerCase().includes("firefox")) return "󰈹";
                                    if (appName.toLowerCase().includes("chrome")) return "";
                                    if (appName.toLowerCase().includes("spotify")) return "󰓇";
                                    if (appName.toLowerCase().includes("swww")) return "󰸉";
                                    if (appName.toLowerCase().includes("terminal") || appName.toLowerCase().includes("kitty") || appName.toLowerCase().includes("alacritty")) return "";
                                    if (appName.toLowerCase().includes("code") || appName.toLowerCase().includes("vscode")) return "󰨞";
                                    if (appName.toLowerCase().includes("telegram")) return "";
                                    if (appName.toLowerCase().includes("slack")) return "󰒱";
                                    if (appName.toLowerCase().includes("steam")) return "󰓓";
                                    if (appName.toLowerCase().includes("notify") || appName.toLowerCase().includes("notification")) return "󰂚";
                                    return "󰀦";
                                }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 20
                                color: "#cdd6f4"
                            }
                        }
                        
                        // Content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Text {
                                    text: modelData["app-name"] || modelData.appName || modelData["app_name"] || "Unknown"
                                    color: "#89b4fa"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: {
                                        let time = modelData.time || modelData.timestamp || "";
                                        if (time) {
                                            let date = new Date(time * 1000);
                                            return date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                                        }
                                        return "";
                                    }
                                    color: "#6c7086"
                                    font.pixelSize: 10
                                }
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary || modelData.title || ""
                                color: "#cdd6f4"
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                visible: text !== ""
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body || modelData.message || ""
                                color: "#bac2de"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                visible: text !== ""
                            }
                        }
                        
                        // Dismiss button
                        Text {
                            Layout.alignment: Qt.AlignTop
                            text: "󰅖"
                            color: dismissMouse.containsMouse ? "#f38ba8" : "#6c7086"
                            font.pixelSize: 12
                            
                            MouseArea {
                                id: dismissMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    closeLatestProc.running = true;
                                }
                            }
                        }
                    }
                    
                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                    }
                }
            }
            
            // Empty state
            Text {
                visible: notificationPopup.notifications.length === 0
                text: "No notifications"
                color: "#6c7086"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                Layout.bottomMargin: 20
            }
        }
    }
}