import QtQuick 2.15

Rectangle {
    id: player
    width: 36; height: 36; radius: 18
    color: "red"

    property real moveSpeed: 3.0
    property int maxBomb: 1
    property int currentBomb: 0
    property bool isDead: false

    property int hp: 3
    property bool invincible: false

    property bool keyLeft: false
    property bool keyRight: false
    property bool keyUp: false
    property bool keyDown: false

    function bombAction() {
        if (!isDead && !gameRoot.gameOver) {
            placeBomb()
            canPassBomb = true
            bombPassTimer.restart()
            if (!autoBombTimer.running) autoBombTimer.start()
        }
    }

    function stopBombAction() {
        autoBombTimer.stop()
    }

    property bool canPassBomb: false
    Timer { id: bombPassTimer; interval: 600; running: false; onTriggered: { canPassBomb = false } }

    property int bombRange: 1

    // 连放间隔设为 0（每帧触发），确保移动时每格都能放炸弹
    Timer {
        id: autoBombTimer
        interval: 0; repeat: true; running: false
        onTriggered: {
            if (!isDead && !gameRoot.gameOver) {
                placeBomb()
                canPassBomb = true; bombPassTimer.restart()
            }
        }
    }

    SequentialAnimation {
        id: invincibleAnim
        loops: 6; running: false
        PropertyAnimation { target: player; property: "opacity"; to: 0.3; duration: 250 }
        PropertyAnimation { target: player; property: "opacity"; to: 1.0; duration: 250 }
        onFinished: { player.opacity = 1.0; invincible = false }
    }

    Timer {
        interval: 8; running: true; repeat: true
        onTriggered: {
            if(!isDead){
                movePlayer()
                checkHitMonster()
                collectPowerUps()
                updateOwnBombsBlocking()
            }
        }
    }

    function movePlayer() {
        let nx = x, ny = y
        if (keyLeft) nx -= moveSpeed; if (keyRight) nx += moveSpeed
        if (keyUp) ny -= moveSpeed; if (keyDown) ny += moveSpeed

        if (nx < 40) nx = 40
        if (nx > 1324) nx = 1324
        if (ny < 40) ny = 40
        if (ny > 824) ny = 824

        if (nx !== x) {
            let step = (nx > x) ? 1 : -1
            let steps = Math.abs(nx - x)
            let moved = 0
            for (let i = 0; i < steps; i++) {
                let testX = x + step * (moved + 1)
                if (!checkCollision(testX, y, 2)) { moved++ } else { break }
            }
            if (moved > 0) x = x + step * moved
        }

        if (ny !== y) {
            let step = (ny > y) ? 1 : -1
            let steps = Math.abs(ny - y)
            let moved = 0
            for (let i = 0; i < steps; i++) {
                let testY = y + step * (moved + 1)
                if (!checkCollision(x, testY, 2)) { moved++ } else { break }
            }
            if (moved > 0) y = y + step * moved
        }
    }

    function updateOwnBombsBlocking() {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var bomb = gameRoot.children[i]
            if (bomb.isBomb && bomb.owner === player && !bomb.blockPlayer) {
                var px = player.x, py = player.y
                var overlapX = Math.abs(px - bomb.x) < 40
                var overlapY = Math.abs(py - bomb.y) < 40
                if (!overlapX || !overlapY) {
                    bomb.blockPlayer = true
                }
            }
        }
    }

    function checkCollision(px, py, margin) {
        if (margin === undefined) margin = 1
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock) {
                if (px + width - margin > o.x && px + margin < o.x + o.width &&
                    py + height - margin > o.y && py + margin < o.y + o.height)
                    return true
            }
            if (o.isBomb) {
                if (o.owner === player && !o.blockPlayer) continue
                if (!canPassBomb || o.owner !== player) {
                    if (px + width - margin > o.x && px + margin < o.x + o.width &&
                        py + height - margin > o.y && py + margin < o.y + o.height)
                        return true
                }
            }
            // 玩家之间碰撞
            if (o !== player && o.hp !== undefined && !o.isDead) {
                if (px + width - margin > o.x && px + margin < o.x + o.width &&
                    py + height - margin > o.y && py + margin < o.y + o.height)
                    return true
            }
        }
        return false
    }

    function checkHitMonster(){
        if (invincible || isDead) return
        for(var i = 0; i < gameRoot.children.length; i++){
            let o = gameRoot.children[i]
            if(o.objectName === "monster" && o.alive){
                if(Math.abs(x - o.x) < 30 && Math.abs(y - o.y) < 30){
                    takeDamage(); return
                }
            }
        }
    }

    function takeDamage() {
        if (invincible || isDead) return
        hp -= 1
        if (hp <= 0) {
            die()
            if (gameRoot && gameRoot.checkGameEnd) gameRoot.checkGameEnd()
        } else {
            invincible = true; invincibleAnim.start()
        }
    }

    function collectPowerUps() {
        for (var i = gameRoot.children.length - 1; i >= 0; i--) {
            let o = gameRoot.children[i]
            if (o && o.objectName === "powerup" && typeof o.collect === "function") {
                let dx = Math.abs(x - o.x)
                let dy = Math.abs(y - o.y)
                if (dx < 30 && dy < 30) {
                    applyPowerUp(o.type, o.amount || 1)
                    o.collect()
                    break
                }
            }
        }
    }

    function applyPowerUp(type, amount) {
        switch (type) {
            case "bomb":   maxBomb = Math.min(maxBomb + amount, 999); break
            case "speed":  moveSpeed = Math.min(moveSpeed + 0.3 * amount, 5.5); break
            case "health": hp = Math.min(hp + amount, 5); break
            case "range":  bombRange = Math.min(bombRange + amount, 3); break
        }
    }

    function isBombPlacementBlocked(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBlock && o.alive !== false) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) {
                    return true
                }
            }
        }
        return false
    }

    function isBombOverlapping(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBomb && o.alive !== false && !o.exploded) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) {
                    return true
                }
            }
        }
        return false
    }

    // 检查玩家是否与任何活着的怪物重叠（用于禁止放炸弹）
    function isTouchingMonster() {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.objectName === "monster" && o.alive) {
                if (x + width > o.x && x < o.x + o.width &&
                    y + height > o.y && y < o.y + o.height) {
                    return true
                }
            }
        }
        return false
    }

    function snapBombToValid(bx, by) {
        let minX = 40, maxX = 1320, minY = 40, maxY = 820
        if (bx < minX) bx = minX; if (bx > maxX) bx = maxX
        if (by < minY) by = minY; if (by > maxY) by = maxY
        if (isBombPlacementBlocked(bx, by)) {
            let centerX = 700, centerY = 400
            let dx = (bx < centerX) ? 40 : -40
            let dy = (by < centerY) ? 40 : -40
            let testX = bx + dx
            if (testX >= minX && testX <= maxX && !isBombPlacementBlocked(testX, by)) {
                bx = testX
            } else {
                let testY = by + dy
                if (testY >= minY && testY <= maxY && !isBombPlacementBlocked(bx, testY)) {
                    by = testY
                } else {
                    if (testX >= minX && testX <= maxX && testY >= minY && testY <= maxY &&
                        !isBombPlacementBlocked(testX, testY)) {
                        bx = testX; by = testY
                    } else {
                        return null
                    }
                }
            }
        }
        return { x: bx, y: by }
    }

    function placeBomb() {
        if (currentBomb >= maxBomb || isDead) return

        // 碰到怪物时禁止放炸弹
        if (isTouchingMonster()) return

        let bx = Math.round(x / 40) * 40
        let by = Math.round(y / 40) * 40
        var snapped = snapBombToValid(bx, by)
        if (!snapped) return
        bx = snapped.x; by = snapped.y
        if (isBombOverlapping(bx, by)) return

        // 炸弹父对象为 gameRoot，确保能检测到所有实体
        let b = bombComponent.createObject(gameRoot, { x: bx, y: by, range: bombRange, owner: player })
        if (b) {
            currentBomb++
            b.onExploded.connect(()=>{ currentBomb-- })
        }
    }

    function die() {
        if(isDead) return
        isDead = true; color = "black"
        autoBombTimer.stop()
    }

    Component { id: bombComponent; Bomb {} }
}