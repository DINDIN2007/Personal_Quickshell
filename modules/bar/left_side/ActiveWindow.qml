import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: activeWindowRoot

    property string windowClass: ""
    property string windowTitle: ""

    property int fontSize: 11
    property string fontFamily: "sans-serif"

    // --- Logic ---
    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -c '.'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "" || data.trim() === "{}") {
                    windowClass = "Hyprland";
                    windowTitle = "Desktop";
                    return;
                }
                try {
                    const windowData = JSON.parse(data);
                    windowClass = windowData.class || "";
                    windowTitle = windowData.title || "";
                } catch (e) {
                    windowClass = "Hyprland";
                    windowTitle = "Desktop";
                }
            }
        }
        Component.onCompleted: running = true
    }
    Connections { target: Hyprland; function onRawEvent(event) { windowProc.running = true } }
    Timer { interval: 500; running: true; repeat: true; onTriggered: windowProc.running = true }

    // --- UI ---
    Layout.preferredHeight: 24 // Reduced from 30 (even smaller than others to fit tight text)
    Layout.preferredWidth: titleRow.childrenRect.width + 16

    color: Colors.barBg
    radius: height / 2
    clip: true

    ColumnLayout {
        id: titleRow
        anchors.centerIn: parent
        spacing: -2 // Tighter vertical spacing

        Text {
            text: windowClass
            color: "#888899"
            font.pixelSize: fontSize - 2
            font.family: fontFamily
            font.bold: true
            visible: text !== ""
            Layout.alignment: Qt.AlignLeft
        }

        Text {
            id: titleText
            text: windowTitle
            color: "#FFFFFF"
            font.pixelSize: fontSize
            font.family: fontFamily
            font.bold: true
            Layout.alignment: Qt.AlignLeft
            elide: Text.ElideRight
            Layout.fillWidth: false
            Layout.maximumWidth: 150
        }
    }
}