import QtQuick 2.15

Rectangle {
    id: wall
    width: 40
    height: 40
    color: "#7f8c8d"        // 灰色，与可破坏方块区分
    border.color: "#2c3e50"
    border.width: 2

    property bool isBlock: true       // 同样作为障碍物参与碰撞和视线阻挡
    property bool alive: true
    property bool isBreakable: false  // 关键：不可破坏
}