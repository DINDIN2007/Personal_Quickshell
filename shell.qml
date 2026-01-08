//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./modules"
import "./modules/bar"
import "./modules/bar/right_side"

import "./modules/background"
import "./modules/styles"
import "./modules/on_screen_display"
import "./modules/sidebar"
import "./modules/app_launcher"

ShellRoot {
  id: root

  // Global state for the power menu
  property bool powerMenuOpen: false
  property bool appLauncherOpen: false

  Bar {
    onRequestMenuToggle: root.powerMenuOpen = !root.powerMenuOpen
  }

  Corners {}

  OSD {}
  PowerMenu {
    powerMenuOpen: root.powerMenuOpen
  }

  AppLauncher {
    // Pass the state
    isOpen: root.appLauncherOpen
    
    // SYNC THE STATE when it closes
    onCloseRequested: root.appLauncherOpen = false
  }

  // Inside ShellRoot in shell.qml
  IpcHandler {
      target: "app_launcher"
      
      // Define a function that 'qs msg' can call
      function toggle(): void {
          root.appLauncherOpen = !root.appLauncherOpen
      }
  }
}