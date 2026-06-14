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
    property bool isBreakable: true

    Timer {
        id: destroyTimer
        interval: 200
        running: false
        onTriggered: block.destroy()
    }

    function die() {
        if (!alive) return
        alive = false
        color = "#ff8800"
        destroyTimer.start()

        // 掉落概率从 0.3 提高到 0.5（50%）
        if (Math.random() < 1 && typeof gameRoot !== "undefined" && gameRoot.spawnPowerUpAt) {
            gameRoot.spawnPowerUpAt(x, y)
        }
    }
}