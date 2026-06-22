import QtQuick 2.15

Rectangle {
    id: player
    width: 36; height: 36; radius: 18
    color: "red"

    // 高光
    Rectangle {
        width: 12; height: 8; radius: 4
        color: "#60ffffff"
        x: 10; y: 4
    }

    // 眼睛
    Rectangle {
        anchors.centerIn: parent
        width: 24; height: 12
        color: "transparent"
        Rectangle {
            width: 8; height: 10; radius: 4
            color: "white"
            x: 2; y: 2
            Rectangle {
                width: 4; height: 5; radius: 2
                color: "black"
                x: { if (player.keyLeft) return 0; if (player.keyRight) return 4; return 2; }
                y: 2
            }
        }
        Rectangle {
            width: 8; height: 10; radius: 4
            color: "white"
            x: 14; y: 2
            Rectangle {
                width: 4; height: 5; radius: 2
                color: "black"
                x: { if (player.keyLeft) return 0; if (player.keyRight) return 4; return 2; }
                y: 2
            }
        }
    }

    // 微笑嘴巴
    Canvas {
        width: 16; height: 8
        anchors.horizontalCenter: parent.horizontalCenter
        y: 22
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "black";
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(8, -2, 8, 0.2 * Math.PI, 0.8 * Math.PI, false);
            ctx.stroke();
        }
    }

    // 光晕
    Rectangle {
        anchors.fill: parent; radius: parent.radius
        color: "transparent"
        border.color: Qt.lighter(parent.color, 1.5); border.width: 3; opacity: 0.6
    }

    // 待机呼吸
    SequentialAnimation on scale {
        loops: Animation.Infinite; running: true
        NumberAnimation { to: 1.03; duration: 800; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
    }

    // 拾取道具粒子组件
    Component {
        id: powerUpParticle
        Rectangle {
            width: 6; height: 6
            color: Qt.rgba(1, 0.84, 0, 1)
            x: player.x + Math.random() * 30 - 15
            y: player.y + Math.random() * 30 - 15
            property real vx: (Math.random() - 0.5) * 100
            property real vy: (Math.random() - 0.5) * 100 - 20
            NumberAnimation on x { to: x + vx; duration: 350; easing.type: Easing.OutQuad }
            NumberAnimation on y { to: y + vy; duration: 350; easing.type: Easing.OutQuad }
            NumberAnimation on opacity { to: 0; duration: 350 }
            Timer { interval: 350; running: true; onTriggered: parent.destroy() }
        }
    }

    // 脚印组件
    Component {
        id: footPrint
        Rectangle {
            width: 6; height: 6; radius: 3; color: "#ffffaa"; opacity: 0.8
            NumberAnimation on opacity { to: 0; duration: 400 }
            Timer { interval: 400; running: true; onTriggered: parent.destroy() }
        }
    }

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

    // 移动拉伸
    transform: [
        Scale {
            origin.x: player.width / 2
            xScale: {
                if (player.keyLeft && !player.keyRight) return 1.1;
                if (player.keyRight && !player.keyLeft) return 1.1;
                return 1.0;
            }
            yScale: {
                if (player.keyLeft && !player.keyRight) return 0.9;
                if (player.keyRight && !player.keyLeft) return 0.9;
                if (player.keyUp && !player.keyDown) return 0.9;
                if (player.keyDown && !player.keyUp) return 0.9;
                return 1.0;
            }
            Behavior on xScale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            Behavior on yScale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        }
    ]

    function bombAction() {
        if (!isDead && !gameRoot.gameOver) {
            placeBomb()
            canPassBomb = true
            bombPassTimer.restart()
            if (!autoBombTimer.running) autoBombTimer.start()
        }
    }
    function stopBombAction() { autoBombTimer.stop() }

    property bool canPassBomb: false
    Timer { id: bombPassTimer; interval: 1000; running: false; onTriggered: { canPassBomb = false } }

    property int bombRange: 1

    Timer {
        id: autoBombTimer
        interval: 80; repeat: true; running: false
        onTriggered: {
            if (!isDead && !gameRoot.gameOver && !gameRoot.paused) {
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
            if (gameRoot.paused) return
            if(!isDead){
                movePlayer()
                checkHitMonster()
                collectPowerUps()
                updateOwnBombsBlocking()
            }
        }
    }

    function movePlayer() {
        let prevX = x, prevY = y
        let nx = x, ny = y
        if (keyLeft) nx -= moveSpeed; if (keyRight) nx += moveSpeed
        if (keyUp) ny -= moveSpeed; if (keyDown) ny += moveSpeed
        if (nx < 40) nx = 40; if (nx > 1324) nx = 1324
        if (ny < 40) ny = 40; if (ny > 824) ny = 824

        if (nx !== x) {
            let step = (nx > x) ? 1 : -1
            let moved = 0
            for (let i = 0; i < Math.abs(nx - x); i++) {
                let testX = x + step * (moved + 1)
                if (!checkCollision(testX, y, 2)) moved++; else break
            }
            if (moved > 0) x += step * moved
        }
        if (ny !== y) {
            let step = (ny > y) ? 1 : -1
            let moved = 0
            for (let i = 0; i < Math.abs(ny - y); i++) {
                let testY = y + step * (moved + 1)
                if (!checkCollision(x, testY, 2)) moved++; else break
            }
            if (moved > 0) y += step * moved
        }

        if (x !== prevX || y !== prevY) {
            var fp = footPrint.createObject(gameRoot)
            fp.x = x + width/2 - fp.width/2
            fp.y = y + height/2 - fp.height/2
        }
    }

    function updateOwnBombsBlocking() {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var bomb = gameRoot.children[i]
            if (bomb.isBomb && bomb.owner === player && !bomb.blockPlayer) {
                var overlapX = Math.abs(x - bomb.x) < 40, overlapY = Math.abs(y - bomb.y) < 40
                if (!overlapX || !overlapY) bomb.blockPlayer = true
            }
        }
    }

    function checkCollision(px, py, margin) {
        if (margin === undefined) margin = 1
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock) {
                if (px + width - margin > o.x && px + margin < o.x + o.width &&
                    py + height - margin > o.y && py + margin < o.y + o.height) return true
            }
            if (o.isBomb) {
                if (o.owner === player) { if (!o.blockPlayer) continue }
                else { if (canPassBomb) continue }
                if (px + width - margin > o.x && px + margin < o.x + o.width &&
                    py + height - margin > o.y && py + margin < o.y + o.height) return true
            }
            if (o !== player && o.hp !== undefined && !o.isDead) {
                if (px + width - margin > o.x && px + margin < o.x + o.width &&
                    py + height - margin > o.y && py + margin < o.y + o.height) return true
            }
        }
        return false
    }

    function checkHitMonster(){
        if (invincible || isDead) return
        for(var i = 0; i < gameRoot.children.length; i++){
            let o = gameRoot.children[i]
            if(o.objectName === "monster" && o.alive && Math.abs(x - o.x) < 30 && Math.abs(y - o.y) < 30){
                takeDamage(); return
            }
        }
    }

    function takeDamage() {
        if (invincible || isDead) return
        hp--
        if (typeof gameRoot !== "undefined" && gameRoot.music && typeof gameRoot.music.playHit === "function") {
            gameRoot.music.playHit()
        }
        if (typeof gameRoot !== "undefined" && typeof gameRoot.showDamageFlash === "function") {
            gameRoot.showDamageFlash()
        }
        if (hp <= 0) { die(); if (gameRoot && gameRoot.checkGameEnd) gameRoot.checkGameEnd() }
        else { invincible = true; invincibleAnim.start() }
    }

    function collectPowerUps() {
        for (var i = gameRoot.children.length - 1; i >= 0; i--) {
            let o = gameRoot.children[i]
            if (o && o.objectName === "powerup" && typeof o.collect === "function") {
                if (Math.abs(x - o.x) < 30 && Math.abs(y - o.y) < 30) {
                    for (var j = 0; j < 8; j++) {
                        powerUpParticle.createObject(gameRoot)
                    }
                    applyPowerUp(o.type, o.amount || 1); o.collect(); break
                }
            }
        }
    }

    function applyPowerUp(type, amount) {
        switch (type) {
            case "bomb": maxBomb = Math.min(maxBomb + amount, 999); break
            case "speed": moveSpeed = Math.min(moveSpeed + 0.3 * amount, 5.5); break
            case "health": hp = Math.min(hp + amount, 5); break
            case "range": bombRange = Math.min(bombRange + amount, 3); break
        }
    }

    function isBombPlacementBlocked(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBlock && o.alive !== false) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) return true
            }
        }
        return false
    }

    function isBombOverlapping(bx, by) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.isBomb && o.alive !== false && !o.exploded) {
                if (bx + 40 > o.x && bx < o.x + 40 && by + 40 > o.y && by < o.y + 40) return true
            }
        }
        return false
    }

    function isTouchingMonster() {
        for (var i = 0; i < gameRoot.children.length; i++) {
            var o = gameRoot.children[i]
            if (o.objectName === "monster" && o.alive) {
                if (x + width > o.x && x < o.x + o.width && y + height > o.y && y < o.y + o.height) return true
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
            if (testX >= minX && testX <= maxX && !isBombPlacementBlocked(testX, by)) bx = testX
            else {
                let testY = by + dy
                if (testY >= minY && testY <= maxY && !isBombPlacementBlocked(bx, testY)) by = testY
                else {
                    if (testX >= minX && testX <= maxX && testY >= minY && testY <= maxY &&
                        !isBombPlacementBlocked(testX, testY)) { bx = testX; by = testY }
                    else return null
                }
            }
        }
        return { x: bx, y: by }
    }

    function placeBomb() {
        if (currentBomb >= maxBomb || isDead) return
        if (isTouchingMonster()) return
        let bx = Math.round(x / 40) * 40, by = Math.round(y / 40) * 40
        var snapped = snapBombToValid(bx, by); if (!snapped) return
        bx = snapped.x; by = snapped.y
        if (isBombOverlapping(bx, by)) return
        let b = bombComponent.createObject(gameRoot, { x: bx, y: by, range: bombRange, owner: player })
        if (b) {
            currentBomb++
            b.onExploded.connect(()=>{ currentBomb-- })
            if (typeof gameRoot !== "undefined" && gameRoot.music && typeof gameRoot.music.playPlaceBomb === "function") {
                gameRoot.music.playPlaceBomb()
            }

            // ★ 主机发送炸弹放置消息
            if (gameRoot.mode === "host" && typeof networkManager !== "undefined") {
                networkManager.sendBombPlaced(bx, by, bombRange, (player === gameRoot.player1 ? 1 : 2))
            }
        }
    }

    function die() {
        if(isDead) return
        isDead = true; color = "black"
        autoBombTimer.stop()
    }

    Component { id: bombComponent; Bomb {} }
}