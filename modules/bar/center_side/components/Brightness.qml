import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 3. Brightness Control
Item {
    id: brightnessRoot

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    Layout.alignment: Qt.AlignVCenter

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    Process {
        id: brightnessProc
        running: false
        command: ["brightnessctl", "s", "5%+"]
        stdout: SplitParser { onRead: data => console.log("[Brightness]: " + data) }
        stderr: SplitParser { onRead: data => console.log("[Brightness Error]: " + data) }
    }

    Text {
        id: brightnessIcon
        anchors.centerIn: parent
        text: "󰖙"
        color: briMouse.pressed ? "#DE3549" : "#ffffff"
        font.family: brightnessRoot.iconFont
        font.pixelSize: 14

        // Scale and animation
        scale: briMouse.pressed ? 0.9 : briMouse.containsMouse ? 1.08 : 1.0
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }

    // Click ripple effect
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0
        height: width
        radius: width / 2
        color: "#ffffff"
        opacity: 0

        ParallelAnimation {
            id: rippleAnim
            NumberAnimation {
                target: ripple
                property: "width"
                from: 0
                to: 40
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: ripple
                property: "opacity"
                from: 0.3
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: briMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                brightnessProc.command = ["brightnessctl", "s", "5%+"]
            } else {
                brightnessProc.command = ["brightnessctl", "s", "5%-"]
            }

            if (brightnessProc.running) brightnessProc.running = false;
            brightnessProc.running = true
        }

        onClicked: {
            rippleAnim.start()
            brightnessProc.command = ["brightnessctl", "s", "100%"]
            if (brightnessProc.running) brightnessProc.running = false;
            brightnessProc.running = true
        }
    }
}