pragma Singleton
import QtQuick

QtObject {
    // Primary Bar Colors
    readonly property color barBg: "#18161D"
    readonly property color widgetBg: "#2B2833"
    readonly property color foreground: "#E0DEF4"
    readonly property color accent: "#DE3549"

    // Functional Colors
    readonly property color dimmedText: "#908CAA"
    readonly property color border: "#393541"
    readonly property color transparent: "transparent"

    // --- NEW MAPPINGS FOR WORKSPACES (Required) ---
    
    // 1. The Active Pill Color
    // I mapped this to your 'accent' (Purple) so it matches your theme.
    // If you prefer actual Blue, change this to "#9ccfd8" (Foam) or "#31748f" (Pine)
    readonly property color red: accent 

    // 2. The Text/Occupied Dot Color
    readonly property color text: foreground

    // 3. The Empty Dot Color
    readonly property color surface2: border // Dark grey for empty slots

    // 4. The Pill Container Background
    readonly property color base: widgetBg 

    // 5. The Container Border
    readonly property color surface0: border
}