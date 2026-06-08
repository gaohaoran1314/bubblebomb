import QtQuick 2.15

Rectangle {
    id: monster
    width: 40
    height: 40
    color: "purple"
    radius: 8
    objectName: "monster"

    property bool alive: true
    property real speed: 1.8
    property Item targetPlayer: null

    // AI状态控制
    property int moveDir: Math.floor(Math.random() * 4)
    property int stuckCount: 0

    Timer {
        id: deathTimer
        interval: 300
        running: false
        onTriggered: monster.destroy()
    }

    Timer {
        interval: 70
        running: alive
        repeat: true
        onTriggered: moveAI()
    }

    function moveAI() {
        if (!alive || !targetPlayer) return

        let nx = x
        let ny = y

        // 卡住超过3次 → 强制随机方向
        if (stuckCount > 3) {
            moveDir = Math.floor(Math.random() * 4)
            stuckCount = 0
        }

        // 核心：视线检测，被墙挡住就不追玩家，改为随机移动
        let dx = targetPlayer.x - x
        let dy = targetPlayer.y - y
        let lineOfSight = true

        // 简单的直线障碍检测
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock) {
                if (isBlockInTheWay(x, y, targetPlayer.x, targetPlayer.y, o)) {
                    lineOfSight = false
                    break
                }
            }
        }

        // 只有能看到玩家，才会朝着玩家走；否则随机移动
        if (lineOfSight) {
            if (Math.abs(dx) > Math.abs(dy)) {
                moveDir = dx > 0 ? 3 : 2
            } else {
                moveDir = dy > 0 ? 1 : 0
            }
        } else {
            // 看不到玩家，保持随机移动，防止卡死
            if (Math.random() < 0.03) {
                moveDir = Math.floor(Math.random() * 4)
            }
        }

        // 计算下一步
        if (moveDir === 0) ny -= speed
        if (moveDir === 1) ny += speed
        if (moveDir === 2) nx -= speed
        if (moveDir === 3) nx += speed

        // 碰撞检测
        if (checkCollision(nx, ny)) {
            stuckCount++
            moveDir = Math.floor(Math.random() * 4)
            return
        }

        // 成功移动，重置状态
        stuckCount = 0
        x = nx
        y = ny

        // 边界限制
        if (x < 20) x = 20
        if (x > 1340) x = 1340
        if (y < 20) y = 20
        if (y > 840) y = 840
    }

    // 检测方块是否挡住视线（简化版）
    function isBlockInTheWay(x1, y1, x2, y2, block) {
        // 用矩形范围近似判断方块是否在两点之间
        let blockCenterX = block.x + block.width / 2
        let blockCenterY = block.y + block.height / 2

        // 点到直线的距离判断（简化版）
        let lineLen = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
        if (lineLen === 0) return false

        let t = ((blockCenterX - x1) * (x2 - x1) + (blockCenterY - y1) * (y2 - y1)) / (lineLen ** 2)
        if (t < 0 || t > 1) return false

        let closestX = x1 + t * (x2 - x1)
        let closestY = y1 + t * (y2 - y1)

        let dist = Math.sqrt((blockCenterX - closestX) ** 2 + (blockCenterY - closestY) ** 2)
        return dist < block.width
    }

    // 方块+炸弹碰撞检测
    function checkCollision(px, py) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if ((o.isBlock || o.isBomb) && o.alive !== false) {
                if (px + width > o.x &&
                    px < o.x + o.width &&
                    py + height > o.y &&
                    py < o.y + o.height)
                {
                    return true
                }
            }
        }
        return false
    }

    function die() {
        alive = false
        color = "#ff4444"
        deathTimer.start()
    }
}
