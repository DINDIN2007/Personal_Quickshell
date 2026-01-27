import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 2. Color Picker
Item {
    id: pickerRoot

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 30

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    Process {
        id: colorPickerProc
        running: false
        command: ["hyprpicker", "-a"]
    }

    Component.onCompleted: colorPickerProc.running = false;

    Text {
        id: pickerIcon
        anchors.centerIn: parent
        text: "󰴱"
        color: pickerMouse.pressed ? "#DE3549" : "#ffffff"
        font.family: pickerRoot.iconFont
        font.pixelSize: 14

        // Scale and animation
        scale: pickerMouse.pressed ? 0.9 : pickerMouse.containsMouse ? 1.08 : 1.0
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
        id: pickerMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            rippleAnim.start()
            if (colorPickerProc.running) colorPickerProc.running = false
            colorPickerProc.running = true
        }
    }
}