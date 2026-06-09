import QtQuick 2.15

Rectangle {
    id: gameRoot
    color: "#90EE90"
    width: 1400
    height: 900
    focus: true

    property bool gameOver: false
    property bool victory: false
    property bool monstersSpawned: false

    Keys.forwardTo: [player]

    Keys.onSpacePressed: {
        if (gameOver) {
            if (victory) {
                returnToMainMenu()
            } else {
                resetGame()
            }
        }
    }

    Keys.onEscapePressed: {
        Qt.quit()
    }

    // 游戏内信息面板（右上角）
    Rectangle {
        x: gameRoot.width - width - 10
        y: 10
        width: 160
        height: 50
        color: "#000000"
        opacity: 0.5
        radius: 8

        Row {
            anchors.centerIn: parent
            spacing: 15

            // 生命值
            Row {
                spacing: 2
                Repeater {
                    model: player.hp
                    Text {
                        text: "❤️"
                        font.pixelSize: 22
                    }
                }
            }

            // 分隔线
            Rectangle {
                width: 1; height: 30
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            // 炸弹数量
            Row {
                spacing: 4
                Text {
                    text: "💣"
                    font.pixelSize: 22
                }
                Text {
                    text: player.maxBomb - player.currentBomb
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                }
            }
        }
    }

    // 胜利检测定时器
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if (victory || gameOver || !monstersSpawned) return
            let monstersAlive = false
            for (let i = 0; i < gameRoot.children.length; i++) {
                let obj = gameRoot.children[i]
                if (obj.objectName === "monster" && obj.alive) {
                    monstersAlive = true
                    break
                }
            }
            if (!monstersAlive) {
                victory = true
                gameOver = true
            }
        }
    }

    // ========== 四周边界墙 (Wall) ==========
    // 上边界
    Wall { x: 0;    y: 0 }
    Wall { x: 40;   y: 0 }
    Wall { x: 80;   y: 0 }
    Wall { x: 120;  y: 0 }
    Wall { x: 160;  y: 0 }
    Wall { x: 200;  y: 0 }
    Wall { x: 240;  y: 0 }
    Wall { x: 280;  y: 0 }
    Wall { x: 320;  y: 0 }
    Wall { x: 360;  y: 0 }
    Wall { x: 400;  y: 0 }
    Wall { x: 440;  y: 0 }
    Wall { x: 480;  y: 0 }
    Wall { x: 520;  y: 0 }
    Wall { x: 560;  y: 0 }
    Wall { x: 600;  y: 0 }
    Wall { x: 640;  y: 0 }
    Wall { x: 680;  y: 0 }
    Wall { x: 720;  y: 0 }
    Wall { x: 760;  y: 0 }
    Wall { x: 800;  y: 0 }
    Wall { x: 840;  y: 0 }
    Wall { x: 880;  y: 0 }
    Wall { x: 920;  y: 0 }
    Wall { x: 960;  y: 0 }
    Wall { x: 1000; y: 0 }
    Wall { x: 1040; y: 0 }
    Wall { x: 1080; y: 0 }
    Wall { x: 1120; y: 0 }
    Wall { x: 1160; y: 0 }
    Wall { x: 1200; y: 0 }
    Wall { x: 1240; y: 0 }
    Wall { x: 1280; y: 0 }
    Wall { x: 1320; y: 0 }
    Wall { x: 1360; y: 0 }

    // 下边界
    Wall { x: 0;    y: 860 }
    Wall { x: 40;   y: 860 }
    Wall { x: 80;   y: 860 }
    Wall { x: 120;  y: 860 }
    Wall { x: 160;  y: 860 }
    Wall { x: 200;  y: 860 }
    Wall { x: 240;  y: 860 }
    Wall { x: 280;  y: 860 }
    Wall { x: 320;  y: 860 }
    Wall { x: 360;  y: 860 }
    Wall { x: 400;  y: 860 }
    Wall { x: 440;  y: 860 }
    Wall { x: 480;  y: 860 }
    Wall { x: 520;  y: 860 }
    Wall { x: 560;  y: 860 }
    Wall { x: 600;  y: 860 }
    Wall { x: 640;  y: 860 }
    Wall { x: 680;  y: 860 }
    Wall { x: 720;  y: 860 }
    Wall { x: 760;  y: 860 }
    Wall { x: 800;  y: 860 }
    Wall { x: 840;  y: 860 }
    Wall { x: 880;  y: 860 }
    Wall { x: 920;  y: 860 }
    Wall { x: 960;  y: 860 }
    Wall { x: 1000; y: 860 }
    Wall { x: 1040; y: 860 }
    Wall { x: 1080; y: 860 }
    Wall { x: 1120; y: 860 }
    Wall { x: 1160; y: 860 }
    Wall { x: 1200; y: 860 }
    Wall { x: 1240; y: 860 }
    Wall { x: 1280; y: 860 }
    Wall { x: 1320; y: 860 }
    Wall { x: 1360; y: 860 }

    // 左边界
    Wall { x: 0; y: 40 }
    Wall { x: 0; y: 80 }
    Wall { x: 0; y: 120 }
    Wall { x: 0; y: 160 }
    Wall { x: 0; y: 200 }
    Wall { x: 0; y: 240 }
    Wall { x: 0; y: 280 }
    Wall { x: 0; y: 320 }
    Wall { x: 0; y: 360 }
    Wall { x: 0; y: 400 }
    Wall { x: 0; y: 440 }
    Wall { x: 0; y: 480 }
    Wall { x: 0; y: 520 }
    Wall { x: 0; y: 560 }
    Wall { x: 0; y: 600 }
    Wall { x: 0; y: 640 }
    Wall { x: 0; y: 680 }
    Wall { x: 0; y: 720 }
    Wall { x: 0; y: 760 }
    Wall { x: 0; y: 800 }
    Wall { x: 0; y: 840 }

    // 右边界
    Wall { x: 1360; y: 40 }
    Wall { x: 1360; y: 80 }
    Wall { x: 1360; y: 120 }
    Wall { x: 1360; y: 160 }
    Wall { x: 1360; y: 200 }
    Wall { x: 1360; y: 240 }
    Wall { x: 1360; y: 280 }
    Wall { x: 1360; y: 320 }
    Wall { x: 1360; y: 360 }
    Wall { x: 1360; y: 400 }
    Wall { x: 1360; y: 440 }
    Wall { x: 1360; y: 480 }
    Wall { x: 1360; y: 520 }
    Wall { x: 1360; y: 560 }
    Wall { x: 1360; y: 600 }
    Wall { x: 1360; y: 640 }
    Wall { x: 1360; y: 680 }
    Wall { x: 1360; y: 720 }
    Wall { x: 1360; y: 760 }
    Wall { x: 1360; y: 800 }
    Wall { x: 1360; y: 840 }

    // ========== 内部障碍物 ==========
    // 第1行（y=80）
    Wall { x: 80; y: 80 }
    Block { x: 120; y: 80 }
    Block { x: 200; y: 80 }
    Wall { x: 320; y: 80 }
    Block { x: 360; y: 80 }
    Block { x: 440; y: 80 }
    Wall { x: 560; y: 80 }
    Block { x: 600; y: 80 }
    Block { x: 680; y: 80 }
    Wall { x: 800; y: 80 }
    Block { x: 840; y: 80 }
    Block { x: 920; y: 80 }
    Wall { x: 1040; y: 80 }
    Block { x: 1080; y: 80 }
    Block { x: 1160; y: 80 }
    Wall { x: 1280; y: 80 }
    Block { x: 1320; y: 80 }

    // y=120 行
    Block { x: 80; y: 120 }
    Block { x: 200; y: 120 }
    Block { x: 320; y: 120 }
    Block { x: 440; y: 120 }
    Block { x: 560; y: 120 }
    Block { x: 680; y: 120 }
    Block { x: 800; y: 120 }
    Block { x: 920; y: 120 }
    Block { x: 1040; y: 120 }
    Block { x: 1160; y: 120 }
    Block { x: 1280; y: 120 }

    // 第2行（y=200）
    Wall { x: 80; y: 200 }
    Block { x: 320; y: 200 }
    Wall { x: 560; y: 200 }
    Block { x: 800; y: 200 }
    Wall { x: 1040; y: 200 }
    Block { x: 1280; y: 200 }

    // y=240 行
    Block { x: 80; y: 240 }
    Block { x: 200; y: 240 }
    Block { x: 320; y: 240 }
    Block { x: 440; y: 240 }
    Block { x: 560; y: 240 }
    Block { x: 680; y: 240 }
    Block { x: 800; y: 240 }
    Block { x: 920; y: 240 }
    Block { x: 1040; y: 240 }
    Block { x: 1160; y: 240 }
    Block { x: 1280; y: 240 }

    // 第3行（y=320）
    Block { x: 200; y: 320 }
    Wall { x: 440; y: 320 }
    Block { x: 680; y: 320 }
    Wall { x: 920; y: 320 }
    Block { x: 1160; y: 320 }
    Block { x: 80; y: 320 }
    Block { x: 320; y: 320 }
    Block { x: 560; y: 320 }
    Block { x: 800; y: 320 }
    Block { x: 1040; y: 320 }
    Block { x: 1280; y: 320 }

    // 第4行（y=440）
    Wall { x: 80; y: 440 }
    Block { x: 320; y: 440 }
    Wall { x: 560; y: 440 }
    Block { x: 800; y: 440 }
    Wall { x: 1040; y: 440 }
    Block { x: 1280; y: 440 }
    Block { x: 200; y: 440 }
    Block { x: 440; y: 440 }
    Block { x: 680; y: 440 }
    Block { x: 920; y: 440 }
    Block { x: 1160; y: 440 }

    // 第5行（y=560）
    Block { x: 200; y: 560 }
    Wall { x: 440; y: 560 }
    Block { x: 680; y: 560 }
    Wall { x: 920; y: 560 }
    Block { x: 1160; y: 560 }
    Block { x: 80; y: 560 }
    Block { x: 320; y: 560 }
    Block { x: 560; y: 560 }
    Block { x: 800; y: 560 }
    Block { x: 1040; y: 560 }
    Block { x: 1280; y: 560 }

    // 第6行（y=680）
    Wall { x: 80; y: 680 }
    Block { x: 320; y: 680 }
    Wall { x: 560; y: 680 }
    Block { x: 800; y: 680 }
    Wall { x: 1040; y: 680 }
    Block { x: 1280; y: 680 }

    // 第7行（y=800）
    Wall { x: 80; y: 800 }
    Block { x: 200; y: 800 }
    Wall { x: 320; y: 800 }
    Block { x: 440; y: 800 }
    Wall { x: 560; y: 800 }
    Block { x: 680; y: 800 }
    Wall { x: 800; y: 800 }
    Block { x: 920; y: 800 }
    Wall { x: 1040; y: 800 }
    Block { x: 1160; y: 800 }
    Wall { x: 1280; y: 800 }

    // 额外竖墙
    Wall { x: 200; y: 160 }
    Wall { x: 680; y: 160 }
    Wall { x: 1040; y: 160 }
    Wall { x: 440; y: 360 }
    Wall { x: 440; y: 400 }
    Wall { x: 920; y: 360 }
    Wall { x: 920; y: 400 }
    Wall { x: 320; y: 600 }
    Wall { x: 320; y: 640 }
    Wall { x: 800; y: 600 }
    Wall { x: 800; y: 640 }

    // 零散 Block
    Block { x: 80; y: 280 }
    Block { x: 440; y: 280 }
    Block { x: 800; y: 280 }
    Block { x: 1160; y: 280 }
    Block { x: 200; y: 480 }
    Block { x: 680; y: 480 }
    Block { x: 1040; y: 480 }
    Block { x: 320; y: 720 }
    Block { x: 920; y: 720 }

    // 玩家（安全出生点）
    Player {
        id: player
        x: (1400 - 36) / 2
        y: 400
    }

    Component {
        id: monsterComp
        Monster {}
    }

    Component.onCompleted: {
        spawnMonstersAtCorners()
    }

    function spawnMonstersAtCorners(){
        monsterComp.createObject(gameRoot, { x: 40, y: 40, targetPlayer: player })
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 40, y: 40, targetPlayer: player })
        monsterComp.createObject(gameRoot, { x: 40, y: 900 - 40 - 40, targetPlayer: player })
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 40, y: 900 - 40 - 40, targetPlayer: player })
        monstersSpawned = true
    }

    function resetGame(){
        gameOver = false
        victory = false
        monstersSpawned = false
        player.isDead = false
        player.hp = 3
        player.invincible = false
        player.opacity = 1.0
        player.x = (1400 - 36) / 2
        player.y = 400
        player.color = "red"
        player.currentBomb = 0

        for(let i = gameRoot.children.length - 1; i >= 0; i--){
            let obj = gameRoot.children[i]
            if(obj.objectName === "monster" || obj.isBomb){
                obj.destroy()
            }
        }
        spawnMonstersAtCorners()
        gameRoot.forceActiveFocus()
    }

    function returnToMainMenu() {
        // Game.qml 被 Loader 加载，它的 parent 就是 Loader
        if (parent && parent.source !== undefined) {
            parent.source = ""
        }
    }

    // 游戏失败弹窗
    Rectangle {
        anchors.centerIn: parent
        width: 320
        height: 180
        color: "#222222"
        opacity: 0.8
        radius: 10
        visible: gameOver && !victory

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            text: "游戏结束！"
            font.pixelSize: 36
            color: "white"
        }
        Text {
            anchors.centerIn: parent
            text: "按 空格 重新开始"
            font.pixelSize: 20
            color: "#dddddd"
        }
    }

    // 胜利弹窗
    Rectangle {
        anchors.centerIn: parent
        width: 320
        height: 180
        color: "#2e7d32"
        opacity: 0.9
        radius: 10
        visible: victory

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            text: "胜利！"
            font.pixelSize: 40
            color: "gold"
        }
        Text {
            anchors.centerIn: parent
            text: "你消灭了所有怪物！\n按 空格 返回主菜单"
            font.pixelSize: 20
            color: "white"
        }
    }
}