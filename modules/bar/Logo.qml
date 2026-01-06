import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Image {
    source: "file:///home/dinhv/.config/quickshell/assets/icons/Cachyos_Logo.svg"
    
    // Reduced from 25
    Layout.preferredWidth: 20
    Layout.preferredHeight: 20
    
    fillMode: Image.PreserveAspectFit

    Rectangle {
        // Reduced from +10 (would be 30) to +8 (28) to match bar items
        width: parent.width + 8
        height: parent.height + 8
        radius: 14 // Adjusted for new size

        anchors.centerIn: parent
        
        color: Color.widgetBg
        opacity: 0.5
        z: -1
    }
}