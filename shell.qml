//@ pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar/"

ShellRoot {
  id: root

  //SideBorder { edge: Qt.LeftEdge }
  //SideBorder { edge: Qt.RightEdge }
  //SideBorder { edge: Qt.BottomEdge }

  Rectangle {
    id: container
    anchors.fill: parent
    color: '#000000'

    Bar {}
  }
}