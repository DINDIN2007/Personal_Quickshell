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
  property bool clipboardOpen: false
  property bool notificationOpen: false

  Bar {
    id: mainBar
    onRequestMenuToggle: root.powerMenuOpen = !root.powerMenuOpen
    onRequestClipboardToggle: root.clipboardOpen = !root.clipboardOpen
    onRequestNotificationToggle: root.notificationOpen = !root.notificationOpen
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
        console.log("toggle called, current state:", root.appLauncherOpen)
        root.appLauncherOpen = !root.appLauncherOpen
        console.log("new state:", root.appLauncherOpen)
    }
  }

  ClipboardPopup {
    isOpen: root.clipboardOpen
    parentWindow: mainBar
    onCloseRequested: root.clipboardOpen = false
  }

  NotificationPopup {
    isOpen: root.notificationOpen
    onCloseRequested: root.notificationOpen = false
  }
}