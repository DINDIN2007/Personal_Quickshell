import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 1. Clock (CLICKABLE)
Item {
    id: clockRoot

    Layout.preferredWidth: clockText.implicitWidth
    Layout.preferredHeight: clockText.implicitHeight
    Layout.alignment: Qt.AlignVCenter

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    // --- Logic: Time ---
    function updateTime() {
        let date = new Date();
        let timeStr = Qt.formatDateTime(date, "h:mm ap").toLowerCase();
        let dateStr = Qt.formatDateTime(date, "ddd, MM/dd");
        clockText.text = timeStr + " <font color='#DE3549'>•</font> " + dateStr;
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRoot.updateTime() }

    Component.onCompleted: updateTime();
    Process { id: appLauncher }

    Text {
        id: clockText
        anchors.centerIn: parent

        font.bold: true
        renderType: Text.NativeRendering
        color: timeMouse.pressed ? "#DE3549" : "#ffffff"

        // Scale and animation
        scale: timeMouse.pressed ? 0.9 : timeMouse.containsMouse ? 1.08 : 1.0
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }

    // --- MOUSE AREA FOR APPS ---
    MouseArea {
        id: timeMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

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
                appLauncher.command = ["gnome-pomodoro"]
                appLauncher.running = true
            }
        }
    }
}