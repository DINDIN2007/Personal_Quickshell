import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../styles"

Rectangle {
    id: root
    
    // --- Configuration ---
    property int fontSize: 11
    property string fontFamily: "sans-serif"
    
    Layout.preferredHeight: 28 // Reduced from 38
    Layout.preferredWidth: row.implicitWidth + 12 // Tighter padding

    color: Colors.widgetBg
    radius: height / 2
    clip: true

    // --- Logic: Mouse Scroll to Switch ---
    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) Hyprland.dispatch("workspace e-1")
            else Hyprland.dispatch("workspace e+1")
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: 7

            delegate: Item {
                id: delegateRoot
                
                property int wsId: index + 1
                property var wsObject: Hyprland.workspaces.values.find(w => w.id === wsId)
                property bool isOccupied: wsObject !== undefined
                property bool isActive: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace.id === wsId

                // Sizing: Reduced from 32x32
                width: 24
                height: 24

                // 1. The Sliding "Pill"
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.isActive ? 20 : 0 // Reduced from 28
                    height: 20
                    radius: 10
                    color: "#bd93f9"
                    opacity: parent.isActive ? 1 : 0
                    
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // 2. The Workspace Number
                Text {
                    anchors.centerIn: parent
                    text: delegateRoot.wsId
                    color: delegateRoot.isActive ? "#000000" : (delegateRoot.isOccupied ? "#ffffff" : "#555555")
                    
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                // 3. Click to switch
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`workspace ${delegateRoot.wsId}`)
                }
            }
        }
    }
}