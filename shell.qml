//@ pragma UseQApplication
import QtQuick
import Quickshell
import "./modules/bar/"
import "./modules/borders/" 
import "./modules/styles/"

ShellRoot {
  id: root

  // Global state for the power menu
  property bool powerMenuOpen: false

  Bar {}

  // --- TOP Left ---
  PanelWindow {
      anchors { left: true; top: true;}
      margins { right: 0; top: 0;}
      width: 25; height: 25
      color: "transparent"
      CornerFiller { anchors.fill: parent; isRight: false; isBottom: false; }
  }

  // --- TOP RIGHT ---
  PanelWindow {
      anchors { right: true; top: true; }
      margins { right: 0; top: 0; }
      width: 25; height: 25
      color: "transparent"
      CornerFiller { anchors.fill: parent; isRight: true; isBottom: false; }
  }

  // --- BOTTOM LEFT ---
  PanelWindow {
      anchors { left: true; bottom: true; }
      margins { left: 0; bottom: 0; }
      width: 25; height: 25
      color: "transparent"
      CornerFiller { anchors.fill: parent; isRight: false; isBottom: true; }
  }

  // --- BOTTOM RIGHT ---
  PanelWindow {
      anchors { right: true; bottom: true; }
      margins { right: 0; bottom: 0; }
      width: 25; height: 25
      color: "transparent"
      CornerFiller { anchors.fill: parent; isRight: true; isBottom: true; }
  }

  OSD {}
  PowerMenu {}
}