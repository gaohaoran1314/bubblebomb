import QtQuick 2.15

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 20
    color: "#3cb4ff"
    border.color: "#0066cc"
    border.width: 2

    signal onExploded()
    property bool isBomb: true
    property bool exploded: false
    property int range: 1
    property var owner: null
    property bool blockPlayer: false

    Component {
        id: firePrefab
        Rectangle {
            width: 40
            height: 40
            color: "#ff5500"
            opacity: 0.9
            Timer {
                interval: 300
                running: true
                onTriggered: parent.destroy()
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: explode()
    }

    Timer {
        id: deleteTimer
        interval: 400
        running: false
        onTriggered: {
            onExploded()
            root.destroy()
        }
    }

    // 创建时通知脚下怪物：用矩形重叠检测
    Component.onCompleted: {
        if (parent && parent.children) {
            for (var i = 0; i < parent.children.length; i++) {
                var obj = parent.children[i]
                if (obj.objectName === "monster" && obj.alive) {
                    if (Math.abs(obj.x - root.x) < 40 && Math.abs(obj.y - root.y) < 40) {
                        obj.allowPassThrough(root)
                    }
                }
            }
        }
    }

    function explode() {
        if (exploded) return
        exploded = true

        // 安全调用音效
        if (typeof gameRoot !== "undefined"
            && gameRoot.music
            && typeof gameRoot.music.playExplosion === "function") {
            gameRoot.music.playExplosion()
        }

        color = "orange"
        radius = 0

        var r = range
        if (!hasUnbreakableBlockAt(x, y)) createFire(x, y)
        spreadFire(1, 0, r)
        spreadFire(-1, 0, r)
        spreadFire(0, 1, r)
        spreadFire(0, -1, r)

        deleteTimer.start()
    }

    function spreadFire(dx, dy, maxDist) {
        for (var step = 1; step <= maxDist; step++) {
            var fx = x + dx * step * 40
            var fy = y + dy * step * 40
            if (hasUnbreakableBlockAt(fx, fy)) break
            createFire(fx, fy)
        }
    }

    // 使用矩形重叠检测，确保火焰不会超出不可破坏的墙壁
    function hasUnbreakableBlockAt(fx, fy) {
        var list = parent.children
        for (var i = 0; i < list.length; i++) {
            var o = list[i]
            // 只检测不可破坏且存活的障碍物
            if (o.isBlock && o.isBreakable === false && o.alive !== false) {
                // 火焰块40x40，障碍物40x40，矩形重叠即视为阻挡
                if (fx + 40 > o.x && fx < o.x + 40 && fy + 40 > o.y && fy < o.y + 40) {
                    return true
                }
            }
        }
        return false
    }

    function createFire(fx, fy) {
        var f = firePrefab.createObject(parent)
        f.x = fx
        f.y = fy

        var list = parent.children
        for (var i = 0; i < list.length; i++) {
            var o = list[i]
            if (Math.abs(o.x - fx) < 20 && Math.abs(o.y - fy) < 20) {
                if (o.objectName === "monster" && o.alive) o.die()
                if (o.isBlock && o.alive && o.isBreakable !== false) o.die()
                if (o.isBomb && !o.exploded) o.explode()
                if (o.hp !== undefined && o.takeDamage && !o.isDead) {
                    o.takeDamage()
                }
            }
        }
    }
}