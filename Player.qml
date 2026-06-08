import QtQuick 2.15

Rectangle {
    id: player
    width: 36
    height: 36
    radius: 18
    color: "red"
    focus: true

    property real moveSpeed: 4
    property int maxBomb: 3
    property int currentBomb: 0
    property bool isDead: false

    // 移动控制
    property bool keyLeft: false
    property bool keyRight: false
    property bool keyUp: false
    property bool keyDown: false

    // 延长通行保护时间至 600ms，慢走也完全够用
    property bool canPassBomb: false
    Timer {
        id: bombPassTimer
        interval: 600
        running: false
        onTriggered: {
            canPassBomb = false
        }
    }

    Timer {
        interval: 8
        running: true
        repeat: true
        onTriggered: {
            if(!isDead){
                movePlayer()
                checkHitMonster()
            }
        }
    }

    function movePlayer() {
        let nx = x
        let ny = y

        if (keyLeft) nx -= moveSpeed
        if (keyRight) nx += moveSpeed
        if (keyUp) ny -= moveSpeed
        if (keyDown) ny += moveSpeed

        // 边界限制
        if (nx < 0) nx = 0
        if (nx > 1360) nx = 1360
        if (ny < 0) ny = 0
        if (ny > 860) ny = 860

        // 移动检测
        if (!checkCollision(nx, y)) x = nx
        if (!checkCollision(x, ny)) y = ny
    }

    // 碰撞判定：仅方块永久阻挡，炸弹只在保护期结束后阻挡
    function checkCollision(px, py) {
        for (var i = 0; i < gameRoot.children.length; i++) {
            let o = gameRoot.children[i]
            if (o.isBlock) {
                if (px + width > o.x && px < o.x + o.width &&
                    py + height > o.y && py < o.y + o.height)
                {
                    return true
                }
            }
            if (o.isBomb && !canPassBomb) {
                if (px + width > o.x && px < o.x + o.width &&
                    py + height > o.y && py < o.y + o.height)
                {
                    return true
                }
            }
        }
        return false
    }

    // 怪物碰撞检测
    function checkHitMonster(){
        for(var i = 0; i < gameRoot.children.length; i++){
            let o = gameRoot.children[i]
            if(o.objectName === "monster" && o.alive){
                let dx = Math.abs(x - o.x)
                let dy = Math.abs(y - o.y)
                if(dx < 30 && dy < 30){
                    die()
                    return
                }
            }
        }
    }

    // ========== WASD + 方向键 双控制 ==========
    Keys.onPressed: function(event) {
        if(isDead) return

        // 方向键
        if (event.key === Qt.Key_Left)  keyLeft = true
        if (event.key === Qt.Key_Right) keyRight = true
        if (event.key === Qt.Key_Up)    keyUp = true
        if (event.key === Qt.Key_Down)  keyDown = true

        // WASD
        if (event.key === Qt.Key_A) keyLeft = true
        if (event.key === Qt.Key_D) keyRight = true
        if (event.key === Qt.Key_W) keyUp = true
        if (event.key === Qt.Key_S) keyDown = true

        // 空格放炸弹 + 开启通行保护
        if (event.key === Qt.Key_Space) {
            placeBomb()
            canPassBomb = true
            bombPassTimer.restart()
        }
        event.accepted = true
    }

    Keys.onReleased: function(event) {
        if (event.key === Qt.Key_Left)  keyLeft = false
        if (event.key === Qt.Key_Right) keyRight = false
        if (event.key === Qt.Key_Up)    keyUp = false
        if (event.key === Qt.Key_Down)  keyDown = false

        if (event.key === Qt.Key_A) keyLeft = false
        if (event.key === Qt.Key_D) keyRight = false
        if (event.key === Qt.Key_W) keyUp = false
        if (event.key === Qt.Key_S) keyDown = false

        event.accepted = true
    }

    // 放置炸弹
    function placeBomb() {
        if (currentBomb >= maxBomb || isDead) return
        let bx = Math.round(x / 40) * 40
        let by = Math.round(y / 40) * 40
        let b = bombComponent.createObject(parent, {x: bx, y: by})
        if (b) {
            currentBomb++
            b.onExploded.connect(()=>{ currentBomb-- })
        }
    }

    // 玩家死亡
    function die() {
        if(isDead) return
        isDead = true
        color = "black"
        gameRoot.gameOver = true
    }

    Component { id: bombComponent; Bomb {} }
}
