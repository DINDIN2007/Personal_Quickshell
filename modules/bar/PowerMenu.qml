import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../styles"

PanelWindow {
    id: powerMenuWindow
    
    anchors {
        top: true
        bottom: true
        right: true 
    }
    
    width: 120 
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: true 

    // Directly uses the state from shell.qml
    property bool isOpen: root.powerMenuOpen

    Process { id: actionProc }

    Rectangle {
        id: menuBg
        width: 80
        height: 500 
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right 

        opacity: powerMenuWindow.isOpen ? 1 : 0
        transform: Translate {
            x: powerMenuWindow.isOpen ? 0 : 100
            Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }
        
        // opacity: powerMenuWindow.isOpen ? 1 : 0
        // Behavior on opacity { NumberAnimation { duration: 300 } }

        color: Colors.barBg 
        topLeftRadius: 20
        bottomLeftRadius: 20
        border.color: "#333333"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 30
            anchors.bottomMargin: 30
            spacing: 25

            // Logout
            Item {
                Layout.preferredWidth: 50; Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignHCenter
                Rectangle {
                    anchors.fill: parent; radius: 12
                    color: btn1.containsMouse ? "#333333" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "󰍃"
                    font.pixelSize: 24
                    color: "#ffffff"
                    font.family: "JetBrainsMono Nerd Font"
                }
                MouseArea {
                    id: btn1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { actionProc.command = ["hyprctl", "dispatch", "exit"]; actionProc.running = true }
                }
            }

            // Sleep (GIF)
            Item {
                Layout.preferredWidth: 60; Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                AnimatedImage {
                    anchors.fill: parent; anchors.margins: 4
                    fillMode: Image.PreserveAspectFit
                    source: "file:///home/dinhv/.config/quickshell/assets/Luffy_Icon.gif"
                    playing: powerMenuWindow.isOpen 
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { actionProc.command = ["systemctl", "suspend"]; actionProc.running = true }
                }
            }

            // Power Off
            Item {
                Layout.preferredWidth: 50; Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignHCenter
                Rectangle {
                    anchors.fill: parent; radius: 12
                    color: btn4.containsMouse ? "#ff5555" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "󰐥"
                    font.pixelSize: 26
                    color: btn4.containsMouse ? "#ffffff" : "#ff5555"
                    font.family: "JetBrainsMono Nerd Font"
                }
                MouseArea {
                    id: btn4; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { actionProc.command = ["systemctl", "poweroff"]; actionProc.running = true }
                }
            }
        }
    }
}