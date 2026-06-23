import QtQuick 2.15

Rectangle {
    id: root
    width: 40; height: 40; radius: 20
    color: "#3cb4ff"; border.color: "#0066cc"; border.width: 2

    signal onExploded()
    property bool isBomb: true
    property bool exploded: false
    property int range: 1
    property var owner: null
    property bool blockPlayer: false

    // 放置弹跳动画
    SequentialAnimation {
        id: popInAnimation
        running: true
        NumberAnimation { target: root; property: "scale"; from: 0.3; to: 1.1; duration: 120; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "scale"; from: 1.1; to: 1.0; duration: 80; easing.type: Easing.OutQuad }
    }

    // 倒计时变色
    Timer {
        id: colorTimer
        interval: 1000; running: !exploded; repeat: true
        property int elapsedSeconds: 0
        onTriggered: {
            elapsedSeconds++
            if (elapsedSeconds < 2) {
                if (color == "#3cb4ff") color = "#f1c40f"
                else if (color == "#f1c40f") color = "#e74c3c"
                else color = "#3cb4ff"
            } else {
                color = "#ff0000"
                redFlashTimer.start()
                colorTimer.stop()
            }
        }
    }

    // 快速红色闪烁（最后1秒）
    Timer {
        id: redFlashTimer
        interval: 150; running: false; repeat: true
        property bool flash: true
        onTriggered: {
            color = flash ? "#ff0000" : "#cc0000"
            flash = !flash
        }
    }

    SequentialAnimation on opacity {
        loops: Animation.Infinite; running: !exploded
        NumberAnimation { to: 0.6; duration: 300 }
        NumberAnimation { to: 1.0; duration: 300 }
    }

    // 火焰特效
    Component {
        id: firePrefab
        Rectangle {
            id: flame
            width: 40; height: 40; radius: 10
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ff0000" }
                GradientStop { position: 0.5; color: "#ff6600" }
                GradientStop { position: 1.0; color: "#ffff00" }
            }
            opacity: 0.9
            Timer { interval: 300; running: true; repeat: false; onTriggered: flame.destroy() }
        }
    }

    // 爆炸倒计时
    Timer { interval: 3000; running: true; onTriggered: explode() }

    // 炸弹本体销毁
    Timer {
        id: deleteTimer
        interval: 400; running: false; repeat: false
        onTriggered: {
            onExploded()
            root.destroy()
        }
    }

    function explode() {
        if (exploded) return
        exploded = true

        // 音效
        if (typeof gameRoot !== "undefined" && typeof gameRoot.music.playExplosion === "function") {
            gameRoot.music.playExplosion()
        }
        // 屏幕震动
        if (typeof gameRoot !== "undefined" && typeof gameRoot.shakeScreen === "function") {
            gameRoot.shakeScreen()
        }

        color = "orange"; radius = 0
        var r = range
        if (!hasUnbreakableBlockAt(x, y)) createFire(x, y)
        spreadFire(1, 0, r); spreadFire(-1, 0, r)
        spreadFire(0, 1, r); spreadFire(0, -1, r)

        deleteTimer.start()

        // ★ 主机通知所有客户端此炸弹已爆炸
        if (typeof gameRoot !== "undefined" && gameRoot.mode === "host" && typeof NetworkManager !== "undefined") {
            NetworkManager.sendBombExploded(x, y)
        }
    }

    function spreadFire(dx, dy, maxDist) {
        for (var step = 1; step <= maxDist; step++) {
            var fx = x + dx * step * 40, fy = y + dy * step * 40
            if (hasUnbreakableBlockAt(fx, fy)) break
            createFire(fx, fy)
        }
    }

    function hasUnbreakableBlockAt(fx, fy) {
        var list = parent.children
        for (var i = 0; i < list.length; i++) {
            var o = list[i]
            if (o.isBlock && o.isBreakable === false && o.alive !== false) {
                if (fx + 40 > o.x && fx < o.x + 40 && fy + 40 > o.y && fy < o.y + 40) return true
            }
        }
        return false
    }

    function createFire(fx, fy) {
        var f = firePrefab.createObject(parent)
        f.x = fx; f.y = fy
        var list = parent.children
        for (var i = 0; i < list.length; i++) {
            var o = list[i]
            if (Math.abs(o.x - fx) < 20 && Math.abs(o.y - fy) < 20) {
                if (root.owner && root.owner.objectName === "monster") {
                    if (o.objectName === "monster") continue
                }
                if (o.objectName === "monster" && o.alive) o.die()
                if (o.isBlock && o.alive && o.isBreakable !== false) o.die()
                if (o.isBomb && !o.exploded && typeof o.explode === "function") {
                    if (o.owner && o.owner.objectName === "monster" && (!root.owner || root.owner.objectName !== "monster")) {
                        o.owner = null
                    }
                    o.explode()
                }
                if (o.hp !== undefined && o.takeDamage && !o.isDead) {
                    o.takeDamage()
                }
            }
        }
    }
}