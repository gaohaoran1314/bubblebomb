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

    property real lastKnownX: 0; property real lastKnownY: 0; property bool hasMemory: false
    property real detectionRange: 2500
    property int switchCooldown: 2; property int cooldownTimer: 0

    property real bombTimer: 0
    property real bombCooldown: 3000 + Math.random() * 3000

    property int avoidLockTimer: 0
    property int avoidLockFrames: 6

    property bool chasing: false

    property var spots: []
    property real antennaBaseAngle: 0

    property bool isClient: false
    property int monsterId: 0

    property real targetX: x
    property real targetY: y

    // 脚下阴影
    Rectangle {
        id: shadow
        width: 30; height: 8; radius: 4
        color: "#30000000"
        x: (parent.width - width) / 2
        y: parent.height - 6
        visible: parent.alive
    }

    SequentialAnimation on scale {
        loops: Animation.Infinite; running: alive
        NumberAnimation { to: 1.05; duration: 800 }
        NumberAnimation { to: 0.95; duration: 800 }
    }

    SequentialAnimation on antennaBaseAngle {
        loops: Animation.Infinite; running: alive
        NumberAnimation { to: 3; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { to: -3; duration: 400; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        id: leftAntenna
        width: 6; height: 14
        color: "#5a2d6e"
        radius: 3
        x: 6; y: -12
        rotation: -20 + antennaBaseAngle + (moveDir === 3 ? 8 : (moveDir === 2 ? -8 : 0))
        visible: parent.alive
        Behavior on rotation { NumberAnimation { duration: 150 } }
        Rectangle {
            width: 8; height: 8; radius: 4
            color: "#7d3c98"
            x: (parent.width - width) / 2
            y: -4
        }
    }

    Rectangle {
        id: rightAntenna
        width: 6; height: 14
        color: "#5a2d6e"
        radius: 3
        x: 28; y: -12
        rotation: 20 + antennaBaseAngle + (moveDir === 3 ? 8 : (moveDir === 2 ? -8 : 0))
        visible: parent.alive
        Behavior on rotation { NumberAnimation { duration: 150 } }
        Rectangle {
            width: 8; height: 8; radius: 4
            color: "#7d3c98"
            x: (parent.width - width) / 2
            y: -4
        }
    }

    Rectangle {
        id: leftEyebrow
        width: 8; height: 3; color: "black"
        x: 6; y: 12
        rotation: chasing ? 15 : 0
        Behavior on rotation { NumberAnimation { duration: 150 } }
        visible: parent.alive
    }
    Rectangle {
        id: rightEyebrow
        width: 8; height: 3; color: "black"
        x: 26; y: 12
        rotation: chasing ? -15 : 0
        Behavior on rotation { NumberAnimation { duration: 150 } }
        visible: parent.alive
    }

    Row {
        id: eyesNormal
        anchors.centerIn: parent; spacing: 10
        visible: parent.alive
        Rectangle { width: 8; height: 12; radius: 4; color: "white"; Rectangle { width: 4; height: 6; radius: 2; color: "black"; anchors.centerIn: parent } }
        Rectangle { width: 8; height: 12; radius: 4; color: "white"; Rectangle { width: 4; height: 6; radius: 2; color: "black"; anchors.centerIn: parent } }
    }

    Row {
        id: eyesDead
        anchors.centerIn: parent; spacing: 10
        visible: !parent.alive
        Rectangle { width: 8; height: 2; color: "red"; rotation: 45; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { width: 8; height: 2; color: "red"; rotation: -45; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { width: 8; height: 2; color: "red"; rotation: 45; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { width: 8; height: 2; color: "red"; rotation: -45; anchors.verticalCenter: parent.verticalCenter }
    }

    Canvas {
        id: mouthNormal
        width: 16; height: 8
        anchors.horizontalCenter: parent.horizontalCenter
        y: 24
        visible: parent.alive && !chasing
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "black";
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(8, -2, 8, 0.2 * Math.PI, 0.8 * Math.PI, false);
            ctx.stroke();
        }
    }

    Rectangle {
        id: mouthChase
        width: 12; height: 6; radius: 3
        color: "black"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 25
        visible: parent.alive && chasing
    }

    Canvas {
        id: mouthDead
        width: 16; height: 8
        anchors.horizontalCenter: parent.horizontalCenter
        y: 24
        visible: !parent.alive
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "red";
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(0, 4);
            ctx.lineTo(6, 0);
            ctx.lineTo(12, 8);
            ctx.lineTo(16, 4);
            ctx.stroke();
        }
    }

    Repeater {
        model: spots
        Rectangle {
            x: modelData.x; y: modelData.y
            width: modelData.size; height: modelData.size
            radius: modelData.size / 2
            color: modelData.color
            opacity: 0.7
        }
    }

    Component {
        id: deathParticle
        Rectangle {
            width: 6; height: 6
            color: Qt.rgba(0.8 + Math.random() * 0.2, 0.2, 0.8 + Math.random() * 0.2, 1)
            x: monster.x + Math.random() * 40 - 10
            y: monster.y + Math.random() * 40 - 10
            property real vx: (Math.random() - 0.5) * 120
            property real vy: (Math.random() - 0.5) * 120 - 40
            NumberAnimation on x { to: x + vx; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation on y { to: y + vy; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation on opacity { to: 0; duration: 400 }
            Timer { interval: 400; running: true; onTriggered: parent.destroy() }
        }
    }

    Timer { id: deathTimer; interval: 300; running: false; onTriggered: monster.destroy() }
    Timer { id: forceDestroyTimer; interval: 600; running: false; onTriggered: monster.destroy() }
    Timer { interval: 70; running: alive && !isClient; repeat: true; onTriggered: moveAI() }

    Timer {
        interval: 16
        running: isClient && alive
        repeat: true
        onTriggered: {
            x += (targetX - x) * 0.3
            y += (targetY - y) * 0.3
        }
    }

    Component { id: bombComponent; Bomb {} }

    Component.onCompleted: {
        var tempSpots = []
        for (var i = 0; i < 3 + Math.floor(Math.random() * 3); i++) {
            tempSpots.push({
                x: 4 + Math.random() * 28,
                y: 10 + Math.random() * 22,
                size: 2 + Math.random() * 4,
                color: Math.random() < 0.5 ? "#2a0a2e" : "#1a001a"
            })
        }
        spots = tempSpots
        targetX = x
        targetY = y
    }

    function moveAI() {
        if (!alive || isClient) return
        targetPlayer = findClosestAlivePlayerInRange()
        if (!targetPlayer) { randomMove(); chasing = false; cooldownTimer = 0; return }

        var predictedX = targetPlayer.x, predictedY = targetPlayer.y
        if (targetPlayer.keyLeft) predictedX -= 20
        else if (targetPlayer.keyRight) predictedX += 20
        if (targetPlayer.keyUp) predictedY -= 20
        else if (targetPlayer.keyDown) predictedY += 20

        var dist = Math.sqrt((x-targetPlayer.x)*(x-targetPlayer.x) + (y-targetPlayer.y)*(y-targetPlayer.y))
        var speedMul = 1.0
        if (dist < 100) speedMul = 1.6
        else if (dist < 200) speedMul = 1.3
        else if (dist < 400) speedMul = 1.1

        let dx = predictedX - x, dy = predictedY - y
        let isDiagonal = Math.abs(dx) > 20 && Math.abs(dy) > 20

        let lineOfSight = true
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock && isBlockInTheWay(x, y, predictedX, predictedY, o)) { lineOfSight = false; break }
        }
        chasing = lineOfSight

        let desiredDir = moveDir
        if (lineOfSight) {
            lastKnownX = predictedX; lastKnownY = predictedY; hasMemory = true
            if (Math.abs(dx) > Math.abs(dy)) desiredDir = dx > 0 ? 3 : 2
            else desiredDir = dy > 0 ? 1 : 0
        } else {
            if (hasMemory) {
                let dxM = lastKnownX - x, dyM = lastKnownY - y
                if (Math.abs(dxM) < 5 && Math.abs(dyM) < 5) { hasMemory = false; desiredDir = Math.floor(Math.random()*4) }
                else { desiredDir = Math.abs(dxM) > Math.abs(dyM) ? (dxM > 0 ? 3 : 2) : (dyM > 0 ? 1 : 0) }
            } else { if (Math.random() < 0.05) desiredDir = Math.floor(Math.random()*4) }
        }

        if (avoidLockTimer <= 0) {
            var safeDir = avoidBombs(desiredDir)
            if (safeDir !== desiredDir) {
                if (Math.abs(safeDir - desiredDir) === 2) {
                    desiredDir = safeDir
                    avoidLockTimer = avoidLockFrames
                } else if (Math.abs(safeDir - desiredDir) === 1) {
                    if (Math.random() < 0.5) {
                        desiredDir = safeDir
                        avoidLockTimer = avoidLockFrames
                    }
                }
            }
        }
        if (avoidLockTimer > 0) avoidLockTimer--

        let moveSpeed = speed * speedMul
        if (lineOfSight && isDiagonal) moveSpeed *= 1.5

        bombTimer += 70
        if (bombTimer >= bombCooldown) { tryPlaceBomb(); bombTimer = 0; bombCooldown = 3000 + Math.random()*3000 }

        if (cooldownTimer > 0) cooldownTimer--
        if (desiredDir !== moveDir && cooldownTimer <= 0 && !isBlockedInDir(desiredDir, moveSpeed)) {
            moveDir = desiredDir; cooldownTimer = switchCooldown
        }

        if (isBlockedInDir(moveDir, moveSpeed)) {
            cooldownTimer = 0
            let t1 = (moveDir+1)%4, t2 = (moveDir+3)%4
            if (!isBlockedInDir(t1, moveSpeed)) { moveDir = t1; cooldownTimer = switchCooldown }
            else if (!isBlockedInDir(t2, moveSpeed)) { moveDir = t2; cooldownTimer = switchCooldown }
            else { moveDir = Math.floor(Math.random()*4); cooldownTimer = switchCooldown }
        }

        if (!tryMove(moveDir, moveSpeed)) {
            cooldownTimer = 0
            let t1 = (moveDir+1)%4, t2 = (moveDir+3)%4
            if (!tryMove(t1, moveSpeed)) {
                if (!tryMove(t2, moveSpeed)) {
                    let t3 = (moveDir+2)%4
                    if (!tryMove(t3, moveSpeed)) tryMove(Math.floor(Math.random()*4), moveSpeed)
                }
            }
        }

        if (x < 20) x = 20; if (x > 1340) x = 1340; if (y < 20) y = 20; if (y > 840) y = 840
    }

    function findClosestAlivePlayerInRange() {
        var candidates = []
        if (typeof gameRoot.player1 !== "undefined" && !gameRoot.player1.isDead) {
            candidates.push(gameRoot.player1)
        }
        var p2 = (typeof gameRoot.getPlayer2 === "function") ? gameRoot.getPlayer2() : null
        if (p2 && !p2.isDead) {
            candidates.push(p2)
        }
        var closest = null, minDist = Infinity
        for (var i = 0; i < candidates.length; i++) {
            var p = candidates[i]
            var dx = p.x - x, dy = p.y - y
            var dist = Math.sqrt(dx*dx + dy*dy)
            if (dist < minDist && dist <= detectionRange) {
                minDist = dist; closest = p
            }
        }
        return closest
    }

    function avoidBombs(pref) {
        var dangerousBombs = []
        for (var i = 0; i < gameRoot.children.length; i++) {
            var b = gameRoot.children[i]
            if (b.isBomb && !b.exploded && b.alive !== false) {
                var dist = Math.sqrt((x - b.x)*(x - b.x) + (y - b.y)*(y - b.y))
                if (dist < 200) dangerousBombs.push(b)
            }
        }
        if (dangerousBombs.length === 0) return pref
        var scores = [0,0,0,0]
        for (var d = 0; d < 4; d++) {
            var nx = x, ny = y
            if (d === 0) ny -= 40; else if (d === 1) ny += 40
            else if (d === 2) nx -= 40; else if (d === 3) nx += 40
            if (!checkCollision(nx, ny)) scores[d] += 50
            for (var j = 0; j < dangerousBombs.length; j++) {
                var db = dangerousBombs[j]
                scores[d] += Math.sqrt((nx-db.x)*(nx-db.x) + (ny-db.y)*(ny-db.y))
            }
        }
        var bestDir = 0, maxScore = -Infinity
        for (var s = 0; s < 4; s++) { if (scores[s] > maxScore) { maxScore = scores[s]; bestDir = s } }
        return bestDir
    }

    function tryPlaceBomb() {
        let bx = Math.round(x / 40) * 40, by = Math.round(y / 40) * 40
        if (bx < 40 || bx > 1320 || by < 40 || by > 820) return
        if (isBlockedAt(bx, by) || isBombAt(bx, by)) return
        bombComponent.createObject(gameRoot, { x: bx, y: by, range: 1, owner: monster })
        if (gameRoot.mode === "host" && typeof networkManager !== "undefined") {
            networkManager.sendBombPlaced(bx, by, 1, 0)
        }
    }

    function isBlockedAt(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBlock && o.alive !== false) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) return true
            }
        }
        return false
    }

    function isBombAt(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBomb && o.alive !== false && !o.exploded) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) return true
            }
        }
        return false
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
        if (!checkCollision(nx, ny)) { x = nx; y = ny; stuckCount = 0; return true }
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
                    stuckCount = 0; return true
                }
            }
            stuckCount = 0; moveDir = Math.floor(Math.random()*4)
        }
        return false
    }

    function randomMove() {
        if (Math.random() < 0.03) moveDir = Math.floor(Math.random()*4)
        let nx = x, ny = y
        if (moveDir === 0) ny -= speed; else if (moveDir === 1) ny += speed
        else if (moveDir === 2) nx -= speed; else if (moveDir === 3) nx += speed
        if (!checkCollision(nx, ny)) { x = nx; y = ny }
        else { moveDir = Math.floor(Math.random()*4) }
        if (x < 20) x = 20; if (x > 1340) x = 1340; if (y < 20) y = 20; if (y > 840) y = 840
    }

    function isBlockInTheWay(x1, y1, x2, y2, block) {
        let bcx = block.x + block.width / 2, bcy = block.y + block.height / 2
        let len = Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1)); if (len === 0) return false
        let t = ((bcx-x1)*(x2-x1) + (bcy-y1)*(y2-y1)) / (len*len)
        if (t < 0 || t > 1) return false
        let cx = x1 + t*(x2-x1), cy = y1 + t*(y2-y1)
        return Math.sqrt((bcx-cx)*(bcx-cx) + (bcy-cy)*(bcy-cy)) < block.width
    }

    function checkCollision(px, py) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBomb && o.owner === monster && !o.exploded) {
                if (Math.abs(monster.x - o.x) < 40 && Math.abs(monster.y - o.y) < 40) continue
            }
            if ((o.isBlock || o.isBomb) && o.alive !== false) {
                if (px + 36 > o.x && px + 4 < o.x + 40 && py + 36 > o.y && py + 4 < o.y + 40) return true
            }
        }
        return false
    }

    function die() {
        if (!alive) return
        alive = false
        color = "#ff4444"
        chasing = false
        for (var i = 0; i < 8; i++) {
            deathParticle.createObject(monster.parent)
        }
        for (var j = 0; j < gameRoot.children.length; j++) {
            var obj = gameRoot.children[j]
            if (obj.isBomb && obj.owner === monster && !obj.exploded) {
                obj.owner = null
            }
        }
        deathTimer.restart()
        forceDestroyTimer.restart()
    }
}