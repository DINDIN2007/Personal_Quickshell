import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

Item {
    id: screenshotRoot

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    Layout.alignment: Qt.AlignVCenter

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    Process {
        id: screenshotProc
        running: false
        command: ["hyprctl", "dispatch", "exec", "/home/dinhv/debug_shot.sh"]
        stdout: SplitParser { onRead: data => console.log("[Screenshot]: " + data) }
    }

    Component.onCompleted: screenshotProc.running = false;

    Text {
        id: screenshotIcon
        anchors.centerIn: parent
        text: "󰆟"
        color: screenshotMouse.pressed ? "#DE3549" : "#ffffff"
        font.family: screenshotRoot.iconFont
        font.pixelSize: 14

        // Scale and animation
        scale: screenshotMouse.pressed ? 0.9 : screenshotMouse.containsMouse ? 1.08 : 1.0
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
        id: screenshotMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            rippleAnim.start()
            if (screenshotProc.running) screenshotProc.running = false
            screenshotProc.running = true
        }
    }
}