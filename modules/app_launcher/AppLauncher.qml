import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "../styles"

Scope {
    id: root
    
    property bool isOpen: false
    signal closeRequested()
    
    // Store which screen to show on when launcher opens
    property var activeScreen: Quickshell.screens[0]
    
    // Helper function to find the screen matching a Hyprland monitor
    function findScreenForMonitor(monitor) {
        if (!monitor) return null
        
        // Try matching by name first
        for (let i = 0; i < Quickshell.screens.length; i++) {
            let screen = Quickshell.screens[i]
            if (screen.name === monitor.name) {
                return screen
            }
        }
        
        // Fallback: match by position
        for (let i = 0; i < Quickshell.screens.length; i++) {
            let screen = Quickshell.screens[i]
            if (screen.x === monitor.x && screen.y === monitor.y) {
                return screen
            }
        }
        
        return null
    }
    
    onIsOpenChanged: {
        console.log("isOpen changed to:", isOpen)
        if (isOpen) {
            let focusedMon = Hyprland.focusedMonitor
            console.log("Focused monitor:", focusedMon)
            console.log("Monitor name:", focusedMon?.name)
            console.log("Monitor screen property:", focusedMon?.screen)
            
            // Try multiple methods to get the correct screen
            let targetScreen = null
            
            // Method 1: Direct screen property from Hyprland monitor
            if (focusedMon?.screen) {
                targetScreen = focusedMon.screen
                console.log("Using direct screen property")
            }
            // Method 2: Find matching screen by name/position
            else if (focusedMon) {
                targetScreen = findScreenForMonitor(focusedMon)
                console.log("Found screen by matching:", targetScreen?.name)
            }
            
            // Fallback to first screen
            activeScreen = targetScreen ?? Quickshell.screens[0]
            console.log("Final activeScreen:", activeScreen?.name)
        }
    }
    
    WlrLayershell {
        id: launcherWindow
        
        screen: root.activeScreen
        
        namespace: "qs_launcher"
        
        layer: WlrLayer.Overlay
        keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        property int launcherWidth: 550
        property int launcherHeight: 430
        property int cornerRadius: 16
        
        property bool canClose: false
        property bool animationStarted: false

        visible: root.isOpen
        
        color: "transparent"
        
        onVisibleChanged: {
            if (visible) {
                canClose = false
                animationStarted = false
                searchBox.text = ""
                appView.currentIndex = 0
                launcherContent.y = 10000
            }
        }
        
        onHeightChanged: {
            if (visible && height > 0 && !animationStarted) {
                animationStarted = true
                launcherContent.y = height
                openAnimation.from = height
                openAnimation.to = height - launcherHeight
                openAnimation.start()
                searchBox.forceActiveFocus()
                graceTimer.restart()
            }
        }

        Timer {
            id: graceTimer
            interval: 150
            onTriggered: canClose = true
        }
        
        function closeWithAnimation() {
            closeAnimation.from = launcherContent.y
            closeAnimation.to = launcherWindow.height
            closeAnimation.start()
        }

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (launcherWindow.canClose) launcherWindow.closeWithAnimation()
                }
            }
        }

        Rectangle {
            id: launcherContent
            width: launcherWindow.launcherWidth
            height: launcherWindow.launcherHeight
            anchors.horizontalCenter: parent.horizontalCenter
            y: 10000
            
            color: Colors.barBg
            radius: launcherWindow.cornerRadius
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: launcherWindow.cornerRadius
                color: parent.color
            }

            CornerFiller {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: -width
                isRight: true
                isBottom: true
                cornerColor: launcherContent.color
            }
            
            CornerFiller {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -width
                isRight: false
                isBottom: true
                cornerColor: launcherContent.color
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: searchBox.forceActiveFocus()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                anchors.bottomMargin: 16
                spacing: 12

                ListView {
                    id: appView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    highlightMoveDuration: 0
                    keyNavigationWraps: false
                    spacing: 4
                    
                    model: ScriptModel {
                        id: appModel
                        values: {
                            if (typeof DesktopEntries === "undefined" || !DesktopEntries.applications) return []
                            let all = DesktopEntries.applications.values
                            let query = searchBox.text.toLowerCase()
                            if (query === "") return all
                            return all.filter(app => app.name.toLowerCase().includes(query))
                        }
                    }

                    delegate: Item {
                        width: ListView.view.width
                        height: 52
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: {
                                if (parent.ListView.isCurrentItem) return "#45475a"
                                if (mouseArea.containsMouse) return "#313244"
                                return "transparent"
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14
                            
                            Image {
                                source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                sourceSize.width: 32
                                sourceSize.height: 32
                                asynchronous: true
                                cache: true
                            }
                            
                            Text {
                                text: modelData.name
                                color: parent.parent.ListView.isCurrentItem ? "#cdd6f4" : "#bac2de"
                                font.pixelSize: 14
                                font.weight: parent.parent.ListView.isCurrentItem ? Font.Medium : Font.Normal
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            Rectangle {
                                visible: parent.parent.ListView.isCurrentItem
                                width: 4
                                height: 24
                                radius: 2
                                color: Colors.red
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: appView.currentIndex = index
                            onClicked: {
                                modelData.execute() 
                                launcherWindow.closeWithAnimation()
                            }
                        }
                    }
                }

                TextField {
                    id: searchBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    
                    placeholderText: "Search apps..."
                    placeholderTextColor: "#6c7086"
                    font.pixelSize: 16
                    color: "white"
                    leftPadding: 16
                    rightPadding: 16
                    
                    background: Rectangle { 
                        color: "#313244"
                        radius: 12
                        border.color: searchBox.activeFocus ? Colors.red : "transparent"
                        border.width: 2
                    }
                    
                    focus: true
                    
                    onTextChanged: { 
                        appModel.reload()
                        appView.currentIndex = 0 
                    }
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Up) {
                            if (appView.currentIndex > 0) {
                                appView.currentIndex--
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (appView.currentIndex < appView.count - 1) {
                                appView.currentIndex++
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            launcherWindow.closeWithAnimation()
                            event.accepted = true
                        }
                    }

                    onAccepted: {
                        if (appView.count > 0 && appView.currentIndex >= 0) {
                            let apps = appModel.values
                            if (apps[appView.currentIndex]) {
                                apps[appView.currentIndex].execute()
                                launcherWindow.closeWithAnimation()
                            }
                        }
                    }
                }
            }
        }

        NumberAnimation {
            id: openAnimation
            target: launcherContent
            property: "y"
            duration: 200
            easing.type: Easing.OutCubic
        }
        
        NumberAnimation {
            id: closeAnimation
            target: launcherContent
            property: "y"
            duration: 150
            easing.type: Easing.InCubic
            onFinished: root.closeRequested()
        }
    }
    
    component CornerFiller: Item {
        width: 25
        height: 25

        property bool isRight: false 
        property bool isBottom: false
        property color cornerColor: "#1e1e2e"

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                fillColor: cornerColor 
                strokeColor: "transparent"

                startX: isRight ? 25 : 0
                startY: isBottom ? 25 : 0

                PathLine { x: isRight ? 0 : 25; y: isBottom ? 25 : 0 }
                
                PathArc {
                    x: isRight ? 25 : 0
                    y: isBottom ? 0 : 25
                    radiusX: 25; radiusY: 25
                    useLargeArc: false
                    direction: (isRight === isBottom) ? PathArc.Counterclockwise : PathArc.Clockwise
                }
                
                PathLine { x: isRight ? 25 : 0; y: isBottom ? 25 : 0 }
            }
        }
    }
}