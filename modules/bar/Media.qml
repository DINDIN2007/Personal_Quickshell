import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: mediaRoot
    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string mediaText: "Stopped"

    Layout.preferredHeight: 28 // Reduced from 38
    Layout.preferredWidth: Math.min(mediaLabel.implicitWidth, 200)
    cursorShape: Qt.PointingHandCursor
    opacity: pressed ? 0.6 : 1.0
    visible: mediaText !== "Stopped"

    // --- Logic ---
    Process {
        id: mediaProc
        command: ["sh", "-c", "playerctl metadata --format '{{ artist }} - {{ title }}' | cut -c 1-30"]
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                mediaText = (text.length > 0 && text !== " - ") ? text : "Stopped";
            }
        }
    }
    Process {
        id: focusPlayerProc
        command: ["sh", "-c", "PLAYER=$(playerctl metadata --format '{{playerName}}' | tr '[:upper:]' '[:lower:]'); ADDR=$(hyprctl clients -j | jq -r \".[] | select((.class | translate(\\\"[:upper:]\\\", \\\"[:lower:]\\\") == \\\"$PLAYER\\\") or (.initialClass | translate(\\\"[:upper:]\\\", \\\"[:lower:]\\\") == \\\"$PLAYER\\\")) | .address\" | head -n 1); if [ -n \"$ADDR\" ]; then hyprctl dispatch focuswindow address:\"$ADDR\"; else hyprctl dispatch focuswindow \"$PLAYER\"; fi"]
    }
    Timer {
        interval: 2000
        running: true; repeat: true
        onTriggered: mediaProc.running = true 
    }
    Component.onCompleted: mediaProc.running = true
    onClicked: focusPlayerProc.running = true

    Text {
        id: mediaLabel
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        text: "󰝚   " + mediaRoot.mediaText
        color: '#ffffff'
        font.pixelSize: mediaRoot.fontSize
        font.family: mediaRoot.fontFamily
        font.italic: true
        elide: Text.ElideRight
    }
}