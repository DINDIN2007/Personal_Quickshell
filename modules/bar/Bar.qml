import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import "../styles"

PanelWindow {
    id: bar

    property int fontSize: 14
    property string iconFont: "JetBrainsMono Nerd Font" // Ensure this exists!

    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 0

    property string activeWindow: "Window"

    property string currentLayout: "Tile"

    // CPU tracking
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 0
        left: 0
        right: 0
    }

    implicitHeight: 50
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colors.barBg
        topRightRadius: 12
        topLeftRadius: 12

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter // This centers the whole row vertically
            spacing: 10

            // --- LEFT GROUP ---
            Logo {}
            ActiveWindow { 
                fontSize: bar.fontSize 
            }

            // --- LEFT SPACER ---
            Item { Layout.fillWidth: true }

            // --- CENTER GROUP ---
            RowLayout {
                spacing: 15
                SystemData { 
                    fontSize: bar.fontSize 
                }
            
                // Add other "centered" things here, like a Media Player or Search icon
            }

            // --- RIGHT SPACER ---
            // This pushes the center group back to the middle
            Item { Layout.fillWidth: true }

            // --- RIGHT GROUP ---
            RowLayout {
                spacing: 15
                QuickSettings { 
                    iconFont: bar.iconFont 
                }
            }
        }

        // Color behind the radius of the bar
        Rectangle {
            anchors.fill: parent
            color: "black"
            z: -1
        }
    }
}