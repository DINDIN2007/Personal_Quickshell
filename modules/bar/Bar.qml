import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import "../styles"

import "./left_side/"
import "./center_side/"
import "./right_side/"

PanelWindow {
    id: bar

    signal requestMenuToggle()

    // Use the compact font size
    property int fontSize: 11
    property string iconFont: "JetBrainsMono Nerd Font"

    // System data properties (kept for compatibility)
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 0
    property string activeWindow: "Window"
    property string currentLayout: "Tile"

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

    implicitHeight: 38
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colors.barBg
        topRightRadius: 12
        topLeftRadius: 12

        // --- 1. LEFT GROUP ---
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Logo {}
            ActiveWindow { 
                fontSize: bar.fontSize 
            }
        }

        // --- 2. CENTER GROUP ---
        // Anchored strictly to the center. It ignores the Left/Right groups.
        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            SystemData { 
                fontSize: bar.fontSize 
            }
            
            Workspaces {
                fontSize: bar.fontSize
            }

            Clock_Pill {
                fontSize: bar.fontSize
            }
        }

        // --- 3. RIGHT GROUP ---
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            QuickSettings { 
                iconFont: bar.iconFont

                onTogglePowerMenu: bar.requestMenuToggle()
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