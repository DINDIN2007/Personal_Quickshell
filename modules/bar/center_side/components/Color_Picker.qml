import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../../styles"

// 2. Color Picker
Text {
    text: "󰴱"
    color: pickerMouse.pressed ? "#DE3549" : "#ffffff"
    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 20

    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"

    Process {
        id: colorPickerProc
        running: false
        command: ["hyprpicker", "-a"] 
    }

    Component.onCompleted: colorPickerProc.running = false;

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