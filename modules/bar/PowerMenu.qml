import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../styles"
import "../borders/"

Item {
    id: powerMenuRoot

    property alias powerMenuOpen: powerMenuWindow.powerMenuOpen

    PanelWindow {
        id: powerMenuWindow
        property alias powerMenuOpen: powerMenuWindow.visible
        
        // --- 1. CENTER THE WINDOW ---
        // By removing 'top: true' and only keeping 'right: true', 
        // Wayland/Quickshell defaults to centering it vertically.
        anchors {
            top: false
            bottom: false
            right: true
            left: false
        }
        
        // Remove margins that pushed it down
        margins.top: 0

        // Increase height to fit both top and bottom fillers
        // 360 (Menu) + 25 (Top Filler) + 25 (Bottom Filler) = 410
        width: 80 
        height: 410
        
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        Process { id: actionProc }
        Process { id: launcherProc }

        Rectangle {
            id: menuBg
            
            width: 80
            height: 361 
            
            // --- 2. CENTER BACKGROUND IN WINDOW ---
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            opacity: powerMenuOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            transform: Translate {
                id: slideAnim
                x: powerMenuOpen ? 0 : 80
                Behavior on x { 
                    NumberAnimation { 
                        duration: 250
                        easing.type: Easing.OutCubic 
                    } 
                }
            }
            
            color: Colors.barBg
            
            // --- 3. SYMMETRY ---
            // Since it is centered, round both left corners
            topLeftRadius: 20
            bottomLeftRadius: 20
            
            // border.color: "#333333"
            // border.width: 1

            // --- 4. TOP CORNER FILLER ---
            // Curves upwards from the top of the menu
            CornerFiller {
                anchors.bottom: parent.top
                anchors.right: parent.right
                isRight: true
                // Invert 'isBottom' compared to the bottom filler to flip the curve
                isBottom: true 
                
                visible: powerMenuOpen
                cornerColor: Colors.barBg
            }

            // --- BOTTOM CORNER FILLER ---
            // Curves downwards from the bottom of the menu
            CornerFiller {
                anchors.top: parent.bottom
                anchors.right: parent.right
                isRight: true
                isBottom: false
                
                visible: powerMenuOpen
                cornerColor: Colors.barBg
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 15; anchors.bottomMargin: 15; spacing: 10

                // (Your buttons remain unchanged)
                // 1. Logout
                Item {
                    Layout.preferredWidth: 45; Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle { anchors.fill: parent; radius: 10; color: btn1.containsMouse ? "#333333" : "transparent" }
                    Text { anchors.centerIn: parent; text: "󰍃"; font.pixelSize: 22; color: "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { id: btn1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                        onClicked: { actionProc.command = ["hyprctl", "dispatch", "exit"]; actionProc.running = true; powerMenuOpen = false }
                    }
                }

                // 2. Update
                Item {
                    Layout.preferredWidth: 45; Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle { anchors.fill: parent; radius: 10; color: btnUp.containsMouse ? "#333333" : "transparent" }
                    Text { anchors.centerIn: parent; text: "󰚰"; font.pixelSize: 22; color: "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { id: btnUp; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                        onClicked: { launcherProc.command = ["kitty", "-e", "sudo", "pacman", "-Syu"]; launcherProc.running = true; powerMenuOpen = false }
                    }
                }

                // 3. Sleep
                Item {
                    Layout.preferredWidth: 75; Layout.preferredHeight: 75
                    Layout.alignment: Qt.AlignHCenter
                    AnimatedImage {
                        anchors.fill: parent; anchors.margins: 2; fillMode: Image.PreserveAspectFit
                        source: "file:///home/dinhv/.config/quickshell/assets/icons/Luffy_Icon.gif"
                        playing: powerMenuOpen

                        smooth: true
                        mipmap: true
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor;
                        onClicked: { actionProc.command = ["systemctl", "suspend"]; actionProc.running = true; powerMenuOpen = false }
                    }
                }

                // 4. Restart
                Item {
                    Layout.preferredWidth: 45; Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle { anchors.fill: parent; radius: 10; color: btnRe.containsMouse ? "#333333" : "transparent" }
                    Text { anchors.centerIn: parent; text: "󰜉"; font.pixelSize: 22; color: "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { id: btnRe; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                        onClicked: { actionProc.command = ["systemctl", "reboot"]; actionProc.running = true; powerMenuOpen = false }
                    }
                }

                // 5. Power Off
                Item {
                    Layout.preferredWidth: 45; Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle { anchors.fill: parent; radius: 10; color: btn4.containsMouse ? "#ff5555" : "transparent" }
                    Text { anchors.centerIn: parent; text: "󰐥"; font.pixelSize: 24; color: btn4.containsMouse ? "#ffffff" : "#ff5555"; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { id: btn4; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                        onClicked: { actionProc.command = ["systemctl", "poweroff"]; actionProc.running = true; powerMenuOpen = false }
                    }
                }
            }
        }
    }
}