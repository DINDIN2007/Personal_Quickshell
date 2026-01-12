import QtQuick
import Quickshell

Scope {
    Variants {
        model: Quickshell.screens
        
        Scope {
            id: cornerScope
            required property var modelData
            property var targetScreen: modelData
            
            // --- TOP LEFT ---
            PanelWindow {
                screen: cornerScope.targetScreen
                anchors { left: true; top: true }
                implicitWidth: 25; implicitHeight: 25
                color: "transparent"
                CornerFiller { anchors.fill: parent; isRight: false; isBottom: false }
            }

            // --- TOP RIGHT ---
            PanelWindow {
                screen: cornerScope.targetScreen
                anchors { right: true; top: true }
                implicitWidth: 25; implicitHeight: 25
                color: "transparent"
                CornerFiller { anchors.fill: parent; isRight: true; isBottom: false }
            }

            // --- BOTTOM LEFT ---
            PanelWindow {
                screen: cornerScope.targetScreen
                anchors { left: true; bottom: true }
                implicitWidth: 25; implicitHeight: 25
                color: "transparent"
                CornerFiller { anchors.fill: parent; isRight: false; isBottom: true }
            }

            // --- BOTTOM RIGHT ---
            PanelWindow {
                screen: cornerScope.targetScreen
                anchors { right: true; bottom: true }
                implicitWidth: 25; implicitHeight: 25
                color: "transparent"
                CornerFiller { anchors.fill: parent; isRight: true; isBottom: true }
            }
        }
    }
}