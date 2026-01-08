import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "./components"

Rectangle {
    id: clockPillRoot
    
    // Default value if not passed down from Bar.qml
    property int fontSize: 11
    property string fontFamily: "sans-serif"
    property string iconFont: "JetBrainsMono Nerd Font"
    
    // --- Layout ---
    Layout.preferredHeight: 28
    Layout.preferredWidth: contentRow.implicitWidth + 20
    color: Colors.widgetBg
    radius: height / 2

    // --- UI Content ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8 

        Clock {}
        Color_Picker {}
        Brightness {}
        Screenshot {}
        Battery {}
    }
}