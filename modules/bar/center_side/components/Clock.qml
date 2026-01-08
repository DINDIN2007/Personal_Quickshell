import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 1. Clock (CLICKABLE)
Text {
    id: clockRoot

    Layout.alignment: Qt.AlignVCenter 
    font.pixelSize: clockRoot.fontSize
    font.family: clockRoot.fontFamily
    font.bold: true
    renderType: Text.NativeRendering

    color: timeMouse.pressed ? "#DE3549" : "#ffffff"
    
    // --- Logic: Time ---
    function updateTime() {
        let date = new Date();
        let timeStr = Qt.formatDateTime(date, "h:mm ap").toLowerCase();
        let dateStr = Qt.formatDateTime(date, "ddd, MM/dd");
        clockRoot.text = timeStr + " <font color='#DE3549'>•</font> " + dateStr;
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRoot.updateTime() }

    Component.onCompleted: updateTime();

    // --- MOUSE AREA FOR APPS ---
    MouseArea {
        id: timeMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        // Accept Left, Right, and Middle (Wheel) clicks
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // Left Click: Timer / Alarm
                appLauncher.command = ["gnome-clocks"]
                appLauncher.running = true
            } 
            else if (mouse.button === Qt.RightButton) {
                // Right Click: Calendar
                appLauncher.command = ["gnome-calendar"]
                appLauncher.running = true
            }
            else if (mouse.button === Qt.MiddleButton) {
                // Middle Click: Pomodoro
                // Note: If you installed 'solanum' instead, change this to "solanum"
                appLauncher.command = ["gnome-pomodoro"]
                appLauncher.running = true
            }
        }
    }
}