import QtQuick 2.15

Rectangle {
    id: gameRoot
    color: "#90EE90"
    width: 1400
    height: 900

    property bool gameOver: false

    Keys.onSpacePressed: {
        if(gameOver){
            resetGame()
        }
    }

    // 障碍物方块
    Block { x: 80; y: 80 }
    Block { x: 200; y: 80 }
    Block { x: 320; y: 80 }
    Block { x: 440; y: 80 }
    Block { x: 560; y: 80 }
    Block { x: 680; y: 80 }
    Block { x: 800; y: 80 }
    Block { x: 920; y: 80 }
    Block { x: 1040; y: 80 }
    Block { x: 1160; y: 80 }
    Block { x: 1280; y: 80 }

    Block { x: 80; y: 200 }
    Block { x: 320; y: 200 }
    Block { x: 560; y: 200 }
    Block { x: 800; y: 200 }
    Block { x: 1040; y: 200 }
    Block { x: 1280; y: 200 }

    Block { x: 200; y: 320 }
    Block { x: 440; y: 320 }
    Block { x: 680; y: 320 }
    Block { x: 920; y: 320 }
    Block { x: 1160; y: 320 }

    Block { x: 80; y: 440 }
    Block { x: 320; y: 440 }
    Block { x: 560; y: 440 }
    Block { x: 800; y: 440 }
    Block { x: 1040; y: 440 }
    Block { x: 1280; y: 440 }

    Block { x: 200; y: 560 }
    Block { x: 440; y: 560 }
    Block { x: 680; y: 560 }
    Block { x: 920; y: 560 }
    Block { x: 1160; y: 560 }

    Block { x: 80; y: 680 }
    Block { x: 320; y: 680 }
    Block { x: 560; y: 680 }
    Block { x: 800; y: 680 }
    Block { x: 1040; y: 680 }
    Block { x: 1280; y: 680 }

    Block { x: 80; y: 800 }
    Block { x: 200; y: 800 }
    Block { x: 320; y: 800 }
    Block { x: 440; y: 800 }
    Block { x: 560; y: 800 }
    Block { x: 680; y: 800 }
    Block { x: 800; y: 800 }
    Block { x: 920; y: 800 }
    Block { x: 1040; y: 800 }
    Block { x: 1160; y: 800 }
    Block { x: 1280; y: 800 }

    // 玩家：尺寸36*36，地图1400*900，精准居中
    Player {
        id: player
        x: (1400 - 36) / 2
        y: (900 - 36) / 2
    }

    Component {
        id: monsterComp
        Monster {}
    }

    Component.onCompleted: {
        spawnMonstersAtCorners()
    }

    // 怪物：40*40尺寸，四角空旷区域，远离方块、墙体
    function spawnMonstersAtCorners(){
        // 左上角
        monsterComp.createObject(gameRoot, { x: 20, y: 20, targetPlayer: player })
        // 右上角
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 20, y: 20, targetPlayer: player })
        // 左下角
        monsterComp.createObject(gameRoot, { x: 20, y: 900 - 40 - 20, targetPlayer: player })
        // 右下角
        monsterComp.createObject(gameRoot, { x: 1400 - 40 - 20, y: 900 - 40 - 20, targetPlayer: player })
    }

    // 重置游戏，坐标同步校准
    function resetGame(){
        gameOver = false

        player.isDead = false
        player.x = (1400 - 36) / 2
        player.y = (900 - 36) / 2
        player.color = "red"
        player.currentBomb = 0

        for(let i = gameRoot.children.length - 1; i >= 0; i--){
            let obj = gameRoot.children[i]
            if(obj.objectName === "monster" || obj.isBomb){
                obj.destroy()
            }
        }

        spawnMonstersAtCorners()
    }

    // 游戏结束弹窗
    Rectangle {
        anchors.centerIn: parent
        width: 320
        height: 180
        color: "#222222"
        opacity: 0.8
        radius: 10
        visible: gameOver

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
}
