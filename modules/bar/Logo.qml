import Quickshell
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

Image {
    source: "file:///home/dinhv/.config/quickshell/assets/icons/Cachyos_Logo.svg"
    
    // Use Layout properties since we are inside a RowLayout
    Layout.preferredWidth: 25
    Layout.preferredHeight: 25
    
    // This ensures the SVG scales cleanly
    fillMode: Image.PreserveAspectFit

    // Debug: If you see a green square but no logo, the SVG is the problem.
    // If you see nothing, the path or layout is the problem.
    Rectangle {
        // Make it 20 pixels wider and taller than the image
        width: parent.width + 10
        height: parent.height + 10
        radius: 20

        // Center it perfectly over the image
        anchors.centerIn: parent
        
        color: Color.widgetBg
        opacity: 0.5
        z: -1
    }
}