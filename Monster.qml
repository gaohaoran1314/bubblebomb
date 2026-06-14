import QtQuick 2.15

Rectangle {
    id: monster
    width: 40; height: 40; color: "purple"; radius: 8
    objectName: "monster"

    property bool alive: true
    property real speed: 3.2
    property Item targetPlayer: null

    property int moveDir: Math.floor(Math.random() * 4)
    property int stuckCount: 0

    // 当前允许穿过的炸弹（通常由炸弹创建时通知）
    property var passableBomb: null

    property real lastKnownX: 0
    property real lastKnownY: 0
    property bool hasMemory: false

    property real detectionRange: 2500

    property int switchCooldown: 2
    property int cooldownTimer: 0

    Timer { id: deathTimer; interval: 300; running: false; onTriggered: monster.destroy() }
    Timer { interval: 70; running: alive; repeat: true; onTriggered: moveAI() }

    function allowPassThrough(bomb) {
        passableBomb = bomb
    }

    function moveAI() {
        if (!alive) return

        targetPlayer = findClosestAlivePlayerInRange()
        if (!targetPlayer) {
            randomMove()
            cooldownTimer = 0
            return
        }

        if (passableBomb && (!passableBomb.alive || passableBomb.exploded)) passableBomb = null

        let dx = targetPlayer.x - x
        let dy = targetPlayer.y - y
        let isDiagonal = Math.abs(dx) > 20 && Math.abs(dy) > 20

        let lineOfSight = true
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock && isBlockInTheWay(x, y, targetPlayer.x, targetPlayer.y, o)) {
                lineOfSight = false; break
            }
        }

        let desiredDir = moveDir
        if (lineOfSight) {
            lastKnownX = targetPlayer.x; lastKnownY = targetPlayer.y; hasMemory = true
            if (Math.abs(dx) > Math.abs(dy)) {
                desiredDir = dx > 0 ? 3 : 2
            } else {
                desiredDir = dy > 0 ? 1 : 0
            }
        } else {
            if (hasMemory) {
                let dxMem = lastKnownX - x
                let dyMem = lastKnownY - y
                if (Math.abs(dxMem) < 5 && Math.abs(dyMem) < 5) {
                    hasMemory = false
                    desiredDir = Math.floor(Math.random() * 4)
                } else {
                    if (Math.abs(dxMem) > Math.abs(dyMem)) {
                        desiredDir = dxMem > 0 ? 3 : 2
                    } else {
                        desiredDir = dyMem > 0 ? 1 : 0
                    }
                }
            } else {
                if (Math.random() < 0.05) desiredDir = Math.floor(Math.random() * 4)
            }
        }

        let moveSpeed = speed
        if (lineOfSight && isDiagonal) {
            moveSpeed = speed * 1.5
        }

        if (cooldownTimer > 0) cooldownTimer--

        if (desiredDir !== moveDir && cooldownTimer <= 0 && !isBlockedInDir(desiredDir, moveSpeed)) {
            moveDir = desiredDir
            cooldownTimer = switchCooldown
        }

        if (isBlockedInDir(moveDir, moveSpeed)) {
            cooldownTimer = 0
            let try1 = (moveDir + 1) % 4, try2 = (moveDir + 3) % 4
            if (!isBlockedInDir(try1, moveSpeed)) {
                moveDir = try1; cooldownTimer = switchCooldown
            } else if (!isBlockedInDir(try2, moveSpeed)) {
                moveDir = try2; cooldownTimer = switchCooldown
            } else {
                moveDir = Math.floor(Math.random() * 4); cooldownTimer = switchCooldown
            }
        }

        if (!tryMove(moveDir, moveSpeed)) {
            cooldownTimer = 0
            let try1 = (moveDir + 1) % 4, try2 = (moveDir + 3) % 4
            if (!tryMove(try1, moveSpeed)) {
                if (!tryMove(try2, moveSpeed)) {
                    let tryBack = (moveDir + 2) % 4
                    if (!tryMove(tryBack, moveSpeed)) {
                        let randomDir = Math.floor(Math.random() * 4)
                        tryMove(randomDir, moveSpeed)
                    }
                }
            }
        }

        // 应急脱困：如果卡住多次且脚下有炸弹，临时允许穿过
        if (stuckCount >= 3 && passableBomb === null) {
            // 查找脚下是否有未爆炸的炸弹
            for (var j = 0; j < gameRoot.children.length; j++) {
                var bomb = gameRoot.children[j]
                if (bomb.isBomb && !bomb.exploded && bomb.alive !== false) {
                    if (Math.abs(x - bomb.x) < 40 && Math.abs(y - bomb.y) < 40) {
                        allowPassThrough(bomb)
                        stuckCount = 0   // 重置卡住计数
                        break
                    }
                }
            }
        }

        if (passableBomb) {
            var overlapX = Math.abs(x - passableBomb.x) < 40
            var overlapY = Math.abs(y - passableBomb.y) < 40
            if (!overlapX || !overlapY) {
                passableBomb = null
            }
        }

        if (x < 20) x = 20; if (x > 1340) x = 1340
        if (y < 20) y = 20; if (y > 840) y = 840
    }

    function findClosestAlivePlayerInRange() {
        var closest = null, minDist = Infinity
        for (var i = 0; i < gameRoot.children.length; i++) {
            var obj = gameRoot.children[i]
            if (obj.hp !== undefined && !obj.isDead) {
                var dx = obj.x - x, dy = obj.y - y
                var dist = Math.sqrt(dx*dx + dy*dy)
                if (dist < minDist && dist <= detectionRange) {
                    minDist = dist
                    closest = obj
                }
            }
        }
        return closest
    }

    function isBlockedInDir(dir, spd) {
        if (spd === undefined) spd = speed
        let nx = x, ny = y
        if (dir === 0) ny -= spd; else if (dir === 1) ny += spd
        else if (dir === 2) nx -= spd; else if (dir === 3) nx += spd
        return checkCollision(nx, ny)
    }

    function tryMove(dir, spd) {
        if (spd === undefined) spd = speed
        let nx = x, ny = y
        if (dir === 0) ny -= spd; else if (dir === 1) ny += spd
        else if (dir === 2) nx -= spd; else if (dir === 3) nx += spd

        if (!checkCollision(nx, ny)) {
            x = nx; y = ny
            stuckCount = 0
            return true
        }
        stuckCount++
        if (stuckCount > 5) {
            for (var d = 0; d < 4; d++) {
                let jx = x, jy = y
                if (d === 0) jy -= speed * 2; else if (d === 1) jy += speed * 2
                else if (d === 2) jx -= speed * 2; else if (d === 3) jx += speed * 2
                if (!checkCollision(jx, jy)) {
                    x = jx; y = jy
                    if (x < 20) x = 20; if (x > 1340) x = 1340
                    if (y < 20) y = 20; if (y > 840) y = 840
                    stuckCount = 0
                    return true
                }
            }
            stuckCount = 0
            moveDir = Math.floor(Math.random() * 4)
        }
        return false
    }

    function randomMove() {
        if (Math.random() < 0.03) moveDir = Math.floor(Math.random() * 4)
        let nx = x, ny = y
        if (moveDir === 0) ny -= speed; if (moveDir === 1) ny += speed
        if (moveDir === 2) nx -= speed; if (moveDir === 3) nx += speed
        if (!checkCollision(nx, ny)) { x = nx; y = ny }
        else { moveDir = Math.floor(Math.random() * 4) }
        if (x < 20) x = 20; if (x > 1340) x = 1340; if (y < 20) y = 20; if (y > 840) y = 840
    }

    function isBlockInTheWay(x1, y1, x2, y2, block) {
        let bcx = block.x + block.width / 2; let bcy = block.y + block.height / 2
        let len = Math.sqrt((x2-x1)**2 + (y2-y1)**2); if (len === 0) return false
        let t = ((bcx-x1)*(x2-x1) + (bcy-y1)*(y2-y1)) / (len**2)
        if (t < 0 || t > 1) return false
        let cx = x1 + t*(x2-x1); let cy = y1 + t*(y2-y1)
        return Math.sqrt((bcx-cx)**2 + (bcy-cy)**2) < block.width
    }

    function checkCollision(px, py) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            // 允许穿过的炸弹直接跳过
            if (o === passableBomb) continue
            // 其他正常炸弹阻挡
            if (o.isBomb && o.alive !== false && !o.exploded) {
                // 阻挡逻辑在下面统一处理
            }
            if ((o.isBlock || o.isBomb) && o.alive !== false) {
                if (px + 36 > o.x && px + 4 < o.x + 40 &&
                    py + 36 > o.y && py + 4 < o.y + 40) return true
            }
        }
        return false
    }

    function die() { alive = false; color = "#ff4444"; deathTimer.start() }
}