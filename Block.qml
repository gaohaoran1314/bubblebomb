import QtQuick 2.15

Rectangle {
    id: block
    width: 40; height: 40
    color: "#7f8c8d"; border.color: "#4a4a4a"; border.width: 2; radius: 4
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#95a5a6" }
        GradientStop { position: 1.0; color: "#5d6d7e" }
    }
    property bool isBlock: true; property bool alive: true; property bool isBreakable: true

    Timer { id: destroyTimer; interval: 200; running: false; onTriggered: block.destroy() }

    // 粒子碎片组件
    Component {
        id: particleComponent
        Rectangle {
            width: 8; height: 8
            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
            x: block.x + Math.random() * 40 - 4
            y: block.y + Math.random() * 40 - 4
            property real vx: (Math.random() - 0.5) * 100
            property real vy: (Math.random() - 0.5) * 100 - 30
            NumberAnimation on x { to: x + vx; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation on y { to: y + vy; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation on opacity { to: 0; duration: 400 }
            Timer { interval: 400; running: true; onTriggered: parent.destroy() }
        }
    }

    function die() {
        if (!alive) return
        alive = false
        color = "#ff8c00"

        // 生成 6 个破碎粒子
        for (var i = 0; i < 6; i++) {
            particleComponent.createObject(block.parent)
        }

        destroyTimer.start()
        if (Math.random() < 0.5 && typeof gameRoot !== "undefined" && gameRoot.spawnPowerUpAt) {
            gameRoot.spawnPowerUpAt(x, y)
        }

        // ★ 主机模式：通知所有客户端该方块被摧毁
        if (typeof gameRoot !== "undefined" && gameRoot.mode === "host" && typeof networkManager !== "undefined") {
            networkManager.sendBlockDestroyed(x, y)
        }
    }
}