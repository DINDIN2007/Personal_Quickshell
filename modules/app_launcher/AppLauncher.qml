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
    property bool shortcutsOpen: false
    signal closeRequested()
    
    // Store which screen to show on when launcher opens
    property var activeScreen: Quickshell.screens[0]
    
    // ============================================
    // CUSTOMIZE SHORTCUTS HERE
    // ============================================
    property var shortcuts: [
        { category: "General", items: [
            { keys: "Super", action: "App Launcher" },
            { keys: "Super + Q", action: "Close Window" },
            { keys: "Super + T", action: "Terminal" },
            { keys: "Super + E", action: "File Manager" },
            { keys: "Super + W", action: "Browser" },
        ]},
        { category: "Window Management", items: [
            { keys: "Super + H/J/K/L", action: "Focus Left/Down/Up/Right" },
            { keys: "Super + Shift + H/J/K/L", action: "Move Window" },
            { keys: "Super + F", action: "Fullscreen" },
            { keys: "Super + V", action: "Toggle Floating" },
            { keys: "Super + P", action: "Pin Window" },
        ]},
        { category: "Workspaces", items: [
            { keys: "Super + 1-9", action: "Switch Workspace" },
            { keys: "Super + Shift + 1-9", action: "Move to Workspace" },
            { keys: "Super + Tab", action: "Previous Workspace" },
        ]},
        { category: "System", items: [
            { keys: "Super + Shift + S", action: "Screenshot" },
        ]},
    ]
    // ============================================
    
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
        if (isOpen) {
            let focusedMon = Hyprland.focusedMonitor
            
            // Try multiple methods to get the correct screen
            let targetScreen = null
            
            // Method 1: Direct screen property from Hyprland monitor
            if (focusedMon?.screen) {
                targetScreen = focusedMon.screen
            }
            // Method 2: Find matching screen by name/position
            else if (focusedMon) {
                targetScreen = findScreenForMonitor(focusedMon)
            }
            
            // Fallback to first screen
            activeScreen = targetScreen ?? Quickshell.screens[0]
        } else {
            // Close shortcuts popup when launcher closes
            shortcutsOpen = false
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
                root.shortcutsOpen = false
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

        // Background overlay
        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.shortcutsOpen) {
                        root.shortcutsOpen = false
                    } else if (launcherWindow.canClose) {
                        launcherWindow.closeWithAnimation()
                    }
                }
            }
        }

        // Main launcher content
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

                // Search box row with shortcuts button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
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
                                if (root.shortcutsOpen) {
                                    root.shortcutsOpen = false
                                } else {
                                    launcherWindow.closeWithAnimation()
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Slash || event.key === Qt.Key_Question) {
                                root.shortcutsOpen = !root.shortcutsOpen
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
                    
                    // Shortcuts button
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 12
                        color: shortcutsBtn.containsMouse ? "#45475a" : "#313244"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⌨"
                            font.pixelSize: 20
                            color: "#cdd6f4"
                        }
                        
                        MouseArea {
                            id: shortcutsBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shortcutsOpen = !root.shortcutsOpen
                        }
                        
                        ToolTip {
                            visible: shortcutsBtn.containsMouse && !root.shortcutsOpen
                            text: "Keyboard Shortcuts (/)"
                            delay: 500
                        }
                    }
                }
            }
        }

        // Shortcuts popup (centered on screen)
        Rectangle {
            id: shortcutsPopup
            width: 600
            height: Math.min(550, launcherWindow.height - 100)
            anchors.centerIn: parent
            
            color: Colors.barBg
            radius: 16
            border.color: "#45475a"
            border.width: 1
            
            visible: root.shortcutsOpen
            opacity: root.shortcutsOpen ? 1 : 0
            scale: root.shortcutsOpen ? 1 : 0.95
            
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            
            MouseArea {
                anchors.fill: parent
                // Prevent clicks from closing
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "⌨  Keyboard Shortcuts"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: "#cdd6f4"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: closeBtn.containsMouse ? "#45475a" : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 14
                            color: "#6c7086"
                        }
                        
                        MouseArea {
                            id: closeBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shortcutsOpen = false
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }
                
                // Shortcuts list
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: shortcutsColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    ColumnLayout {
                        id: shortcutsColumn
                        width: parent.width
                        spacing: 20
                        
                        Repeater {
                            model: root.shortcuts
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                // Category header
                                Text {
                                    text: modelData.category
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: Colors.red
                                    Layout.bottomMargin: 4
                                }
                                
                                // Shortcuts in category
                                Repeater {
                                    model: modelData.items
                                    
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 16
                                        
                                        // Keys
                                        Row {
                                            spacing: 4
                                            Layout.preferredWidth: 200
                                            
                                            Repeater {
                                                model: modelData.keys.split(" + ")
                                                
                                                Rectangle {
                                                    width: keyText.width + 12
                                                    height: 24
                                                    radius: 4
                                                    color: "#313244"
                                                    border.color: "#45475a"
                                                    border.width: 1
                                                    
                                                    Text {
                                                        id: keyText
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        font.pixelSize: 11
                                                        font.family: "monospace"
                                                        color: "#cdd6f4"
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Action description
                                        Text {
                                            text: modelData.action
                                            font.pixelSize: 13
                                            color: "#bac2de"
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Footer hint
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }
                
                Text {
                    text: "Press / or ? to toggle • Esc to close"
                    font.pixelSize: 11
                    color: "#6c7086"
                    Layout.alignment: Qt.AlignHCenter
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
