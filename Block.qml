import QtQuick 2.15

Rectangle {
    id: block
    width: 40
    height: 40
    color: "#555555"
    border.color: "#333333"
    border.width: 2

    property bool isBlock: true
    property bool alive: true

    Timer {
        id: destroyTimer
        interval: 200
        running: false
        onTriggered: block.destroy()
    }

    // 被炸毁接口
    function die() {
        if (!alive) return
        alive = false
        color = "#ff8800"
        destroyTimer.start()
    }
}
