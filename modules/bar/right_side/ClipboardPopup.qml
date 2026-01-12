import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../../styles"

PanelWindow {
    id: clipboardPopup
    
    property bool isOpen: false
    property var parentWindow: null
    property list<string> clipboardHistory: []
    
    signal closeRequested()
    
    visible: isOpen
    
    // This makes clicking outside close the popup
    WlrLayershell.namespace: "clipboard-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    
    // Position at the right edge, below the bar
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 50  // below the bar
        right: 10
    }
    
    implicitWidth: 320
    implicitHeight: Math.min(400, contentColumn.implicitHeight + 20)
    
    color: "transparent"
    
    // Fetch clipboard history using cliphist
    Process {
        id: cliphistProc
        command: ["sh", "-c", "cliphist list | head -20"]
        stdout: SplitParser {
            splitMarker: ""  // Read all at once
            onRead: data => {
                let lines = data.trim().split('\n').filter(l => l.length > 0);
                clipboardPopup.clipboardHistory = lines;
            }
        }
    }
    
    // Copy selected item to clipboard
    Process {
        id: copyProc
        property string selectedId: ""
        command: ["sh", "-c", "cliphist decode '" + selectedId + "' | wl-copy"]
    }
    
    // Refresh when opened
    onIsOpenChanged: {
        if (isOpen) {
            cliphistProc.running = true;
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: Colors.barBg
        radius: 8
        border.color: Colors.widgetBg
        border.width: 1
        
        // Invisible mouse area to detect clicks outside
        // This works by covering the whole popup and letting clicks through
        focus: true
        
        Keys.onEscapePressed: clipboardPopup.closeRequested()
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "󰅍  Clipboard"
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                // Close button
                Text {
                    text: "󰅖"
                    color: closeBtnMouse.containsMouse ? "#f38ba8" : "#6c7086"
                    font.pixelSize: 12
                    
                    MouseArea {
                        id: closeBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipboardPopup.closeRequested()
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#45475a"
            }
            
            // Clipboard list
            ListView {
                id: historyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(300, count * 36)
                clip: true
                spacing: 4
                
                model: clipboardPopup.clipboardHistory
                
                delegate: Rectangle {
                    width: historyList.width
                    height: 32
                    radius: 6
                    color: itemMouse.containsMouse ? '#3f3f40' : Colors.widgetBg
                    
                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            // cliphist format: "id\ttext"
                            let parts = modelData.split('\t');
                            return parts.length > 1 ? parts.slice(1).join('\t') : modelData;
                        }
                        color: "#cdd6f4"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    
                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            // Extract the ID (first part before tab)
                            let id = modelData.split('\t')[0];
                            copyProc.selectedId = id;
                            copyProc.running = true;
                            clipboardPopup.closeRequested();
                        }
                    }
                }
            }
            
            // Empty state
            Text {
                visible: clipboardPopup.clipboardHistory.length === 0
                text: "No clipboard history"
                color: "#6c7086"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                Layout.bottomMargin: 20
            }
        }
    }
}