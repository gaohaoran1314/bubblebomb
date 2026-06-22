import QtQuick 2.15

Rectangle {
    id: wall
    width: 40; height: 40
    color: "#4a4a4a"; border.color: "#2c3e50"; border.width: 2
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#5c5c5c" }
        GradientStop { position: 0.5; color: "#3c3c3c" }
        GradientStop { position: 1.0; color: "#2c2c2c" }
    }
    property bool isBlock: true; property bool alive: true; property bool isBreakable: false
}