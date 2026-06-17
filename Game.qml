import QtQuick 2.15

Rectangle {
    id: gameRoot
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#7cfc00" }
        GradientStop { position: 1.0; color: "#228b22" }
    }
    width: 1400; height: 900
    focus: true

    property string mode: "single"

    property bool gameOver: false
    property bool victory: false
    property bool monstersSpawned: false

    property var networkManager: null

    // 环境光点（飘浮灰尘）—— 已修正为显式目标动画
    Repeater {
        model: 40
        Rectangle {
            id: dust
            width: 2; height: 2; radius: 1
            color: Qt.rgba(1, 1, 1, 0.2 + Math.random() * 0.3)
            x: Math.random() * gameRoot.width
            y: Math.random() * gameRoot.height

            ParallelAnimation {
                running: true
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation { target: dust; property: "x"; to: dust.x + (Math.random() * 40 - 20); duration: 3000 + Math.random() * 3000; easing.type: Easing.InOutQuad }
                }
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation { target: dust; property: "y"; to: dust.y + (Math.random() * 30 - 15); duration: 3000 + Math.random() * 3000; easing.type: Easing.InOutQuad }
                }
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation { target: dust; property: "opacity"; to: 0.05; duration: 1500 + Math.random() * 1500 }
                    NumberAnimation { target: dust; property: "opacity"; to: 0.3; duration: 1500 + Math.random() * 1500 }
                }
            }
        }
    }

    // 屏幕震动动画（轻柔版）
    SequentialAnimation {
        id: shakeAnimation
        loops: 2
        PropertyAnimation { target: gameRoot; property: "x"; to: gameRoot.x + 2; duration: 30 }
        PropertyAnimation { target: gameRoot; property: "x"; to: gameRoot.x - 2; duration: 30 }
        PropertyAnimation { target: gameRoot; property: "y"; to: gameRoot.y + 1; duration: 25 }
        PropertyAnimation { target: gameRoot; property: "y"; to: gameRoot.y - 1; duration: 25 }
        PropertyAnimation { target: gameRoot; property: "x"; to: gameRoot.x; duration: 10 }
        PropertyAnimation { target: gameRoot; property: "y"; to: gameRoot.y; duration: 10 }
        running: false
    }

    function shakeScreen() {
        shakeAnimation.restart()
    }

    // 受伤屏幕边框红色闪光
    Rectangle {
        id: damageFlash
        anchors.fill: parent
        color: "transparent"
        border.color: "red"
        border.width: 0
        opacity: 0
        Behavior on border.width { NumberAnimation { duration: 100 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        function show() {
            border.width = 12
            opacity = 0.6
            flashTimer.restart()
        }

        Timer {
            id: flashTimer
            interval: 200
            onTriggered: {
                damageFlash.border.width = 0
                damageFlash.opacity = 0
            }
        }
    }

    function showDamageFlash() {
        damageFlash.show()
    }

    Loader {
        id: player2Loader
        active: mode === "multi" || mode === "host" || mode === "client"
        source: "Player.qml"
        onLoaded: {
            if (item) {
                item.color = "blue"
                item.x = (1400 - 36) / 2 + 100
                item.y = 400
            }
        }
    }

    Player {
        id: player1
        x: mode === "single" ? (1400 - 36) / 2 : (1400 - 36) / 2 - 100
        y: 400
        color: "red"
    }

    function getPlayer2() { return player2Loader.item }

    Keys.onPressed: function(event) {
        if (gameOver) {
            if (event.key === Qt.Key_Space || (mode === "multi" && event.key === Qt.Key_Return)) {
                if (victory) returnToMainMenu()
                else resetGame()
            }
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_A) player1.keyLeft = true
        if (event.key === Qt.Key_D) player1.keyRight = true
        if (event.key === Qt.Key_W) player1.keyUp = true
        if (event.key === Qt.Key_S) player1.keyDown = true
        if (event.key === Qt.Key_Space) {
            if (mode !== "client") { player1.bombAction() }
            else { if (networkManager) networkManager.sendInput("bomb", true) }
        }

        if (mode === "multi" || mode === "host") {
            var p2 = getPlayer2()
            if (p2) {
                if (event.key === Qt.Key_Left)  p2.keyLeft = true
                if (event.key === Qt.Key_Right) p2.keyRight = true
                if (event.key === Qt.Key_Up)    p2.keyUp = true
                if (event.key === Qt.Key_Down)  p2.keyDown = true
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) p2.bombAction()
            }
        } else if (mode === "client") {
            if (networkManager) {
                if (event.key === Qt.Key_Left)  networkManager.sendInput("left", true)
                if (event.key === Qt.Key_Right) networkManager.sendInput("right", true)
                if (event.key === Qt.Key_Up)    networkManager.sendInput("up", true)
                if (event.key === Qt.Key_Down)  networkManager.sendInput("down", true)
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) networkManager.sendInput("bomb", true)
            }
        }

        event.accepted = true
    }

    Keys.onReleased: function(event) {
        if (event.key === Qt.Key_A) player1.keyLeft = false
        if (event.key === Qt.Key_D) player1.keyRight = false
        if (event.key === Qt.Key_W) player1.keyUp = false
        if (event.key === Qt.Key_S) player1.keyDown = false
        if (event.key === Qt.Key_Space) {
            if (mode !== "client") player1.stopBombAction()
            else if (networkManager) networkManager.sendInput("bomb", false)
        }

        if (mode === "multi" || mode === "host") {
            var p2 = getPlayer2()
            if (p2) {
                if (event.key === Qt.Key_Left)  p2.keyLeft = false
                if (event.key === Qt.Key_Right) p2.keyRight = false
                if (event.key === Qt.Key_Up)    p2.keyUp = false
                if (event.key === Qt.Key_Down)  p2.keyDown = false
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) p2.stopBombAction()
            }
        } else if (mode === "client") {
            if (networkManager) {
                if (event.key === Qt.Key_Left)  networkManager.sendInput("left", false)
                if (event.key === Qt.Key_Right) networkManager.sendInput("right", false)
                if (event.key === Qt.Key_Up)    networkManager.sendInput("up", false)
                if (event.key === Qt.Key_Down)  networkManager.sendInput("down", false)
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) networkManager.sendInput("bomb", false)
            }
        }

        event.accepted = true
    }

    Keys.onEscapePressed: { returnToMainMenu() }

    Music { id: music }
    Component { id: powerUpTemplate; PowerUp {} }

    function spawnPowerUpAt(x, y) {
        var types = ["bomb", "bomb", "speed", "speed", "health", "range"]
        var type = types[Math.floor(Math.random() * types.length)]
        powerUpTemplate.createObject(gameRoot, { "x": x, "y": y, "type": type })
    }

    Row {
        x: gameRoot.width - ( (mode === "multi" || mode === "host" || mode === "client") ? 420 : 210)
        y: 15
        spacing: 15

        Rectangle {
            width: 180; height: 55
            color: "#66ff0000"
            radius: 12
            border.color: "#ff6666"; border.width: 2

            Row {
                anchors.centerIn: parent; spacing: 10
                Repeater { model: player1.hp; Text { text: "❤️"; font.pixelSize: 22 } }
                Text { text: "💣" + (player1.maxBomb - player1.currentBomb); color: "white"; font.pixelSize: 22; font.bold: true }
                Text { text: "🔥" + player1.bombRange; color: "white"; font.pixelSize: 22; font.bold: true }
            }
        }

        Loader {
            active: mode === "multi" || mode === "host" || mode === "client"
            sourceComponent: Component {
                Rectangle {
                    width: 180; height: 55
                    color: "#660000ff"
                    radius: 12
                    border.color: "#6666ff"; border.width: 2

                    Row {
                        anchors.centerIn: parent; spacing: 10
                        Repeater { model: getPlayer2() ? getPlayer2().hp : 0; Text { text: "❤️"; font.pixelSize: 22 } }
                        Text { text: "💣" + (getPlayer2() ? getPlayer2().maxBomb - getPlayer2().currentBomb : 0); color: "white"; font.pixelSize: 22; font.bold: true }
                        Text { text: "🔥" + (getPlayer2() ? getPlayer2().bombRange : 0); color: "white"; font.pixelSize: 22; font.bold: true }
                    }
                }
            }
        }
    }

    Timer {
        id: networkTimer
        interval: 50; running: (mode === "host" || mode === "client"); repeat: true
        onTriggered: {
            if (mode === "host") {
                if (networkManager) {
                    var snapshot = collectSnapshot()
                    networkManager.sendSnapshot(snapshot)
                }
            } else if (mode === "client") {
                if (networkManager) { networkManager.sendHeartbeat() }
            }
        }
    }

    function collectSnapshot() {
        var data = { players: [], bombs: [], monsters: [], blocks: [] }
        data.players.push({
            id: 1, x: player1.x, y: player1.y, hp: player1.hp,
            maxBomb: player1.maxBomb, currentBomb: player1.currentBomb,
            bombRange: player1.bombRange, color: player1.color, isDead: player1.isDead
        })
        if (mode === "host") {
            var p2 = getPlayer2()
            if (p2) {
                data.players.push({
                    id: 2, x: p2.x, y: p2.y, hp: p2.hp,
                    maxBomb: p2.maxBomb, currentBomb: p2.currentBomb,
                    bombRange: p2.bombRange, color: p2.color, isDead: p2.isDead
                })
            }
        }
        for (var i = 0; i < gameRoot.children.length; i++) {
            var obj = gameRoot.children[i]
            if (obj.isBomb && !obj.exploded && obj.alive !== false) {
                data.bombs.push({ x: obj.x, y: obj.y, range: obj.range })
            }
        }
        for (var j = 0; j < gameRoot.children.length; j++) {
            var m = gameRoot.children[j]
            if (m.objectName === "monster" && m.alive) { data.monsters.push({ x: m.x, y: m.y, alive: true }) }
        }
        return data
    }

    function applySnapshot(snapshot) {
        if (!snapshot) return
        if (snapshot.players && snapshot.players.length > 0) {
            var p1 = snapshot.players[0]
            player1.x = p1.x; player1.y = p1.y
            player1.hp = p1.hp; player1.maxBomb = p1.maxBomb; player1.currentBomb = p1.currentBomb
            player1.bombRange = p1.bombRange; player1.color = p1.color; player1.isDead = p1.isDead
        }
        var p2 = getPlayer2()
        if (p2 && snapshot.players && snapshot.players.length > 1) {
            var p2data = snapshot.players[1]
            p2.x = p2data.x; p2.y = p2data.y
            p2.hp = p2data.hp; p2.maxBomb = p2data.maxBomb; p2.currentBomb = p2data.currentBomb
            p2.bombRange = p2data.bombRange; p2.color = p2data.color; p2.isDead = p2data.isDead
        }
        for (var k = gameRoot.children.length-1; k >= 0; k--) {
            if (gameRoot.children[k].objectName === "monster") gameRoot.children[k].destroy()
        }
        if (snapshot.monsters) {
            for (var m = 0; m < snapshot.monsters.length; m++) {
                var md = snapshot.monsters[m]
                monsterComp.createObject(gameRoot, { x: md.x, y: md.y, alive: md.alive })
            }
        }
        for (var b = gameRoot.children.length-1; b >= 0; b--) {
            if (gameRoot.children[b].isBomb) gameRoot.children[b].destroy()
        }
        if (snapshot.bombs) {
            for (var n = 0; n < snapshot.bombs.length; n++) {
                var bd = snapshot.bombs[n]
                bombComponent.createObject(gameRoot, { x: bd.x, y: bd.y, range: bd.range, owner: null })
            }
        }
    }

    Component.onCompleted: {
        if (mode === "host" || mode === "client") {
            if (networkManager) {
                networkManager.onSnapshotReceived.connect(applySnapshot)
                networkManager.onGameOver.connect(function(winner) {
                    gameOver = true
                    victory = (winner === "player1" && mode === "host") || (winner === "player2" && mode === "client")
                })
                networkManager.onResetGame.connect(resetGame)
            }
        }
        spawnMonstersAtCorners()
    }

    Timer {
        interval: 500; running: (mode !== "client"); repeat: true
        onTriggered: {
            if (victory || gameOver || !monstersSpawned) return
            var alive = false
            for (var i = 0; i < gameRoot.children.length; i++) {
                var obj = gameRoot.children[i]
                if (obj.objectName === "monster" && obj.alive) { alive = true; break }
            }
            if (!alive) {
                victory = true; gameOver = true
                if (mode === "host" && networkManager) { networkManager.sendGameOver("host") }
            }
        }
    }

    // ========== 四周边界墙 ==========
    Wall { x: 0;    y: 0 }   Wall { x: 40;   y: 0 }   Wall { x: 80;   y: 0 }
    Wall { x: 120;  y: 0 }   Wall { x: 160;  y: 0 }   Wall { x: 200;  y: 0 }
    Wall { x: 240;  y: 0 }   Wall { x: 280;  y: 0 }   Wall { x: 320;  y: 0 }
    Wall { x: 360;  y: 0 }   Wall { x: 400;  y: 0 }   Wall { x: 440;  y: 0 }
    Wall { x: 480;  y: 0 }   Wall { x: 520;  y: 0 }   Wall { x: 560;  y: 0 }
    Wall { x: 600;  y: 0 }   Wall { x: 640;  y: 0 }   Wall { x: 680;  y: 0 }
    Wall { x: 720;  y: 0 }   Wall { x: 760;  y: 0 }   Wall { x: 800;  y: 0 }
    Wall { x: 840;  y: 0 }   Wall { x: 880;  y: 0 }   Wall { x: 920;  y: 0 }
    Wall { x: 960;  y: 0 }   Wall { x: 1000; y: 0 }   Wall { x: 1040; y: 0 }
    Wall { x: 1080; y: 0 }   Wall { x: 1120; y: 0 }   Wall { x: 1160; y: 0 }
    Wall { x: 1200; y: 0 }   Wall { x: 1240; y: 0 }   Wall { x: 1280; y: 0 }
    Wall { x: 1320; y: 0 }   Wall { x: 1360; y: 0 }

    Wall { x: 0;    y: 860 } Wall { x: 40;   y: 860 } Wall { x: 80;   y: 860 }
    Wall { x: 120;  y: 860 } Wall { x: 160;  y: 860 } Wall { x: 200;  y: 860 }
    Wall { x: 240;  y: 860 } Wall { x: 280;  y: 860 } Wall { x: 320;  y: 860 }
    Wall { x: 360;  y: 860 } Wall { x: 400;  y: 860 } Wall { x: 440;  y: 860 }
    Wall { x: 480;  y: 860 } Wall { x: 520;  y: 860 } Wall { x: 560;  y: 860 }
    Wall { x: 600;  y: 860 } Wall { x: 640;  y: 860 } Wall { x: 680;  y: 860 }
    Wall { x: 720;  y: 860 } Wall { x: 760;  y: 860 } Wall { x: 800;  y: 860 }
    Wall { x: 840;  y: 860 } Wall { x: 880;  y: 860 } Wall { x: 920;  y: 860 }
    Wall { x: 960;  y: 860 } Wall { x: 1000; y: 860 } Wall { x: 1040; y: 860 }
    Wall { x: 1080; y: 860 } Wall { x: 1120; y: 860 } Wall { x: 1160; y: 860 }
    Wall { x: 1200; y: 860 } Wall { x: 1240; y: 860 } Wall { x: 1280; y: 860 }
    Wall { x: 1320; y: 860 } Wall { x: 1360; y: 860 }

    Wall { x: 0; y: 40 }    Wall { x: 0; y: 80 }    Wall { x: 0; y: 120 }
    Wall { x: 0; y: 160 }   Wall { x: 0; y: 200 }   Wall { x: 0; y: 240 }
    Wall { x: 0; y: 280 }   Wall { x: 0; y: 320 }   Wall { x: 0; y: 360 }
    Wall { x: 0; y: 400 }   Wall { x: 0; y: 440 }   Wall { x: 0; y: 480 }
    Wall { x: 0; y: 520 }   Wall { x: 0; y: 560 }   Wall { x: 0; y: 600 }
    Wall { x: 0; y: 640 }   Wall { x: 0; y: 680 }   Wall { x: 0; y: 720 }
    Wall { x: 0; y: 760 }   Wall { x: 0; y: 800 }   Wall { x: 0; y: 840 }

    Wall { x: 1360; y: 40 }  Wall { x: 1360; y: 80 }  Wall { x: 1360; y: 120 }
    Wall { x: 1360; y: 160 } Wall { x: 1360; y: 200 } Wall { x: 1360; y: 240 }
    Wall { x: 1360; y: 280 } Wall { x: 1360; y: 320 } Wall { x: 1360; y: 360 }
    Wall { x: 1360; y: 400 } Wall { x: 1360; y: 440 } Wall { x: 1360; y: 480 }
    Wall { x: 1360; y: 520 } Wall { x: 1360; y: 560 } Wall { x: 1360; y: 600 }
    Wall { x: 1360; y: 640 } Wall { x: 1360; y: 680 } Wall { x: 1360; y: 720 }
    Wall { x: 1360; y: 760 } Wall { x: 1360; y: 800 } Wall { x: 1360; y: 840 }

    // ========== 内部障碍物 ==========
    Wall { x: 80; y: 80 } Wall { x: 360; y: 80 } Wall { x: 680; y: 80 } Wall { x: 1000; y: 80 } Wall { x: 1280; y: 80 }
    Block { x: 120; y: 80 } Block { x: 200; y: 80 } Block { x: 280; y: 80 }
    Block { x: 400; y: 80 } Block { x: 480; y: 80 } Block { x: 560; y: 80 }
    Block { x: 720; y: 80 } Block { x: 800; y: 80 } Block { x: 880; y: 80 }
    Block { x: 1040; y: 80 } Block { x: 1120; y: 80 } Block { x: 1200; y: 80 }
    Block { x: 1320; y: 80 }

    Block { x: 80; y: 120 } Block { x: 160; y: 120 } Block { x: 240; y: 120 } Block { x: 320; y: 120 }
    Block { x: 400; y: 120 } Block { x: 480; y: 120 } Block { x: 560; y: 120 } Block { x: 640; y: 120 }
    Block { x: 720; y: 120 } Block { x: 800; y: 120 } Block { x: 880; y: 120 } Block { x: 960; y: 120 }
    Block { x: 1040; y: 120 } Block { x: 1120; y: 120 } Block { x: 1200; y: 120 } Block { x: 1280; y: 120 }
    Block { x: 1360; y: 120 }

    Wall { x: 240; y: 200 } Wall { x: 560; y: 200 } Wall { x: 880; y: 200 } Wall { x: 1200; y: 200 }
    Block { x: 80; y: 200 } Block { x: 160; y: 200 } Block { x: 320; y: 200 }
    Block { x: 400; y: 200 } Block { x: 480; y: 200 } Block { x: 640; y: 200 }
    Block { x: 720; y: 200 } Block { x: 800; y: 200 } Block { x: 960; y: 200 }
    Block { x: 1040; y: 200 } Block { x: 1120; y: 200 } Block { x: 1280; y: 200 }
    Block { x: 1360; y: 200 }

    Block { x: 80; y: 240 } Block { x: 200; y: 240 } Block { x: 320; y: 240 } Block { x: 440; y: 240 }
    Block { x: 560; y: 240 } Block { x: 680; y: 240 } Block { x: 800; y: 240 } Block { x: 920; y: 240 }
    Block { x: 1040; y: 240 } Block { x: 1160; y: 240 } Block { x: 1280; y: 240 }

    Wall { x: 80; y: 320 } Wall { x: 400; y: 320 } Wall { x: 720; y: 320 } Wall { x: 1040; y: 320 }
    Block { x: 120; y: 320 } Block { x: 200; y: 320 } Block { x: 280; y: 320 }
    Block { x: 440; y: 320 } Block { x: 520; y: 320 } Block { x: 600; y: 320 }
    Block { x: 760; y: 320 } Block { x: 840; y: 320 } Block { x: 920; y: 320 }
    Block { x: 1080; y: 320 } Block { x: 1160; y: 320 } Block { x: 1240; y: 320 }
    Block { x: 1320; y: 320 }

    Block { x: 80; y: 360 } Block { x: 200; y: 360 } Block { x: 320; y: 360 } Block { x: 440; y: 360 }
    Block { x: 560; y: 360 } Block { x: 680; y: 360 } Block { x: 800; y: 360 } Block { x: 920; y: 360 }
    Block { x: 1040; y: 360 } Block { x: 1160; y: 360 } Block { x: 1280; y: 360 }

    Wall { x: 240; y: 440 } Wall { x: 560; y: 440 } Wall { x: 880; y: 440 } Wall { x: 1200; y: 440 }
    Block { x: 80; y: 440 } Block { x: 160; y: 440 } Block { x: 320; y: 440 }
    Block { x: 400; y: 440 } Block { x: 480; y: 440 } Block { x: 640; y: 440 }
    Block { x: 720; y: 440 } Block { x: 800; y: 440 } Block { x: 960; y: 440 }
    Block { x: 1040; y: 440 } Block { x: 1120; y: 440 } Block { x: 1280; y: 440 }
    Block { x: 1360; y: 440 }

    Block { x: 80; y: 480 } Block { x: 200; y: 480 } Block { x: 320; y: 480 } Block { x: 440; y: 480 }
    Block { x: 560; y: 480 } Block { x: 680; y: 480 } Block { x: 800; y: 480 } Block { x: 920; y: 480 }
    Block { x: 1040; y: 480 } Block { x: 1160; y: 480 } Block { x: 1280; y: 480 }

    Wall { x: 80; y: 560 } Wall { x: 400; y: 560 } Wall { x: 720; y: 560 } Wall { x: 1040; y: 560 }
    Block { x: 120; y: 560 } Block { x: 200; y: 560 } Block { x: 280; y: 560 }
    Block { x: 440; y: 560 } Block { x: 520; y: 560 } Block { x: 600; y: 560 }
    Block { x: 760; y: 560 } Block { x: 840; y: 560 } Block { x: 920; y: 560 }
    Block { x: 1080; y: 560 } Block { x: 1160; y: 560 } Block { x: 1240; y: 560 }
    Block { x: 1320; y: 560 }

    Block { x: 80; y: 600 } Block { x: 200; y: 600 } Block { x: 320; y: 600 } Block { x: 440; y: 600 }
    Block { x: 560; y: 600 } Block { x: 680; y: 600 } Block { x: 800; y: 600 } Block { x: 920; y: 600 }
    Block { x: 1040; y: 600 } Block { x: 1160; y: 600 } Block { x: 1280; y: 600 }

    Wall { x: 240; y: 680 } Wall { x: 560; y: 680 } Wall { x: 880; y: 680 } Wall { x: 1200; y: 680 }
    Block { x: 80; y: 680 } Block { x: 160; y: 680 } Block { x: 320; y: 680 }
    Block { x: 400; y: 680 } Block { x: 480; y: 680 } Block { x: 640; y: 680 }
    Block { x: 720; y: 680 } Block { x: 800; y: 680 } Block { x: 960; y: 680 }
    Block { x: 1040; y: 680 } Block { x: 1120; y: 680 } Block { x: 1280; y: 680 }
    Block { x: 1360; y: 680 }

    Block { x: 80; y: 720 } Block { x: 200; y: 720 } Block { x: 320; y: 720 } Block { x: 440; y: 720 }
    Block { x: 560; y: 720 } Block { x: 680; y: 720 } Block { x: 800; y: 720 } Block { x: 920; y: 720 }
    Block { x: 1040; y: 720 } Block { x: 1160; y: 720 } Block { x: 1280; y: 720 }

    Wall { x: 80; y: 760 } Wall { x: 360; y: 760 } Wall { x: 680; y: 760 } Wall { x: 1000; y: 760 } Wall { x: 1280; y: 760 }
    Block { x: 120; y: 760 } Block { x: 200; y: 760 } Block { x: 280; y: 760 }
    Block { x: 400; y: 760 } Block { x: 480; y: 760 } Block { x: 560; y: 760 }
    Block { x: 720; y: 760 } Block { x: 800; y: 760 } Block { x: 880; y: 760 }
    Block { x: 1040; y: 760 } Block { x: 1120; y: 760 } Block { x: 1200; y: 760 }
    Block { x: 1320; y: 760 }

    Wall { x: 200; y: 120 } Wall { x: 200; y: 160 }
    Wall { x: 520; y: 120 } Wall { x: 520; y: 160 }
    Wall { x: 880; y: 120 } Wall { x: 880; y: 160 }
    Wall { x: 1160; y: 120 } Wall { x: 1160; y: 160 }

    Wall { x: 360; y: 360 } Wall { x: 360; y: 400 }
    Wall { x: 720; y: 360 } Wall { x: 720; y: 400 }
    Wall { x: 1040; y: 360 } Wall { x: 1040; y: 400 }

    Wall { x: 160; y: 600 } Wall { x: 160; y: 640 }
    Wall { x: 480; y: 600 } Wall { x: 480; y: 640 }
    Wall { x: 840; y: 600 } Wall { x: 840; y: 640 }
    Wall { x: 1200; y: 600 } Wall { x: 1200; y: 640 }

    Component { id: monsterComp; Monster {} }
    Component { id: bombComponent; Bomb {} }

    function spawnMonstersAtCorners(){
        monsterComp.createObject(gameRoot, { x: 40, y: 40 })
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 40, y: 40 })
        monsterComp.createObject(gameRoot, { x: 40, y: 900 - 40 - 40 })
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 40, y: 900 - 40 - 40 })
        monstersSpawned = true
    }

    function checkGameEnd() {
        if (gameOver) return
        if (victory) return
        if (mode === "single") {
            if (player1.isDead) { gameOver = true; victory = false }
        } else if (mode === "multi" || mode === "host") {
            var p2 = getPlayer2()
            if (player1.isDead && (p2 ? p2.isDead : true)) { gameOver = true; victory = false }
        }
    }

    function resetGame(){
        gameOver = false; victory = false; monstersSpawned = false
        player1.isDead = false; player1.hp = 3; player1.maxBomb = 1; player1.bombRange = 1
        player1.moveSpeed = 3.0; player1.color = "red"
        player1.x = mode === "single" ? (1400 - 36) / 2 : (1400 - 36) / 2 - 100
        player1.y = 400; player1.currentBomb = 0; player1.invincible = false; player1.opacity = 1.0

        if (mode === "multi" || mode === "host" || mode === "client") {
            var p2 = getPlayer2()
            if (p2) {
                p2.isDead = false; p2.hp = 3; p2.maxBomb = 1; p2.bombRange = 1
                p2.moveSpeed = 3.0; p2.color = "blue"
                p2.x = (1400 - 36) / 2 + 100; p2.y = 400
                p2.currentBomb = 0; p2.invincible = false; p2.opacity = 1.0
            }
        }

        for(var i = gameRoot.children.length - 1; i >= 0; i--){
            var obj = gameRoot.children[i]
            if (obj.objectName === "powerup" || obj.objectName === "monster" || obj.isBomb) {
                obj.destroy()
            }
        }

        for(var j = 0; j < gameRoot.children.length; j++){
            var block = gameRoot.children[j]
            if (block.isBlock && block.isBreakable) {
                block.alive = true
                block.color = "#7f8c8d"
            }
        }

        spawnMonstersAtCorners()
        gameRoot.forceActiveFocus()
    }

    function returnToMainMenu() {
        if (mode === "host" || mode === "client") { if (networkManager) networkManager.disconnect() }
        if (parent && parent.source !== undefined) parent.source = ""
    }

    // 游戏失败弹窗（弹性）
    Rectangle {
        id: losePopup
        anchors.centerIn: parent; width: 340; height: 200
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#aa333333" }
            GradientStop { position: 1.0; color: "#dd111111" }
        }
        radius: 15
        border.color: "#ff4444"; border.width: 2
        visible: gameOver && !victory
        scale: visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.topMargin: 35
            text: "游戏结束！"; font.pixelSize: 42; font.bold: true; color: "#ff8888"
        }
        Text {
            anchors.centerIn: parent
            text: "按 空格 重新开始"; font.pixelSize: 24; color: "#dddddd"
        }
    }

    // 胜利弹窗（弹性）
    Rectangle {
        id: winPopup
        anchors.centerIn: parent; width: 340; height: 200
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#aa2e7d32" }
            GradientStop { position: 1.0; color: "#dd1b5e20" }
        }
        radius: 15
        border.color: "#ffd700"; border.width: 2
        visible: victory
        scale: visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.topMargin: 35
            text: "胜利！"; font.pixelSize: 48; font.bold: true; color: "#ffd700"
        }
        Text {
            anchors.centerIn: parent
            text: "你消灭了所有怪物！\n按 空格 返回主菜单"
            font.pixelSize: 22; color: "white"; horizontalAlignment: Text.AlignHCenter
        }
    }
}