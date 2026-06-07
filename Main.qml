import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: mainWindow
    width: 400
    height: 600
    visible: true
    title: "笨鸟先飞 - 修正管道版"
    color: "#87CEEB"

    property bool gamePlaying: false
    property bool gameOver: false
    property int score: 0
    property int bestScore: 0

    property double birdY: height / 2
    property double birdVY: 0
    readonly property double birdRadius: 15
    readonly property double gravity: 0.2
    readonly property double jumpForce: -4.8
    readonly property double birdX: 80

    readonly property double pipeWidth: 60
    readonly property double pipeGap: 150
    readonly property double pipeSpeed: 2.5
    readonly property double pipeSpawnInterval: 2000

    ListModel { id: pipeModel }

    Item {
        id: gameArea
        anchors.fill: parent
        focus: true

        Rectangle {
            id: bird
            width: birdRadius * 2
            height: birdRadius * 2
            radius: birdRadius
            color: "#FFD700"
            border.color: "#B8860B"
            border.width: 2
            x: birdX - birdRadius
            y: birdY - birdRadius
            Rectangle {
                width: 5; height: 5; radius: 2.5; color: "white"
                x: parent.width * 0.6; y: parent.height * 0.3
                Rectangle { width: 2; height: 2; radius: 1; color: "black"; x: 1.5; y: 1.5 }
            }
        }

        Repeater {
            model: pipeModel
            delegate: Item {
                x: model.x
                // 上管道 - 修正点：直接 y:0
                Rectangle {
                    width: pipeWidth
                    height: model.topHeight
                    color: "#228B22"
                    border.color: "#006400"
                    border.width: 2
                    radius: 4
                    y: 0
                }
                // 下管道
                Rectangle {
                    width: pipeWidth
                    height: model.bottomHeight
                    color: "#228B22"
                    border.color: "#006400"
                    border.width: 2
                    radius: 4
                    y: model.bottomY
                }
            }
        }

        Text {
            id: scoreText
            text: "得分: 0"
            font.pixelSize: 24; font.bold: true; color: "white"
            anchors.top: parent.top; anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline; styleColor: "black"
        }

        Text {
            id: bestScoreText
            text: "最高分: 0"
            font.pixelSize: 16; font.bold: true; color: "white"
            anchors.top: scoreText.bottom; anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline; styleColor: "black"
        }

        Text {
            id: endGameText
            text: "游戏结束"
            font.pixelSize: 32; font.bold: true; color: "red"
            anchors.centerIn: parent; anchors.verticalCenterOffset: -30
            visible: false; style: Text.Outline; styleColor: "white"
        }

        Text {
            id: restartHint
            text: "点击或按空格重新开始"
            font.pixelSize: 16; color: "white"
            anchors.top: endGameText.bottom; anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false; style: Text.Outline; styleColor: "black"
        }

        Text {
            id: startHint
            text: "点击屏幕或按空格开始"
            font.pixelSize: 20; font.bold: true; color: "white"
            anchors.centerIn: parent
            visible: !gamePlaying && !gameOver
            style: Text.Outline; styleColor: "black"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: jump()
        }

        Keys.onSpacePressed: function(event) { jump(); event.accepted = true; }
    }

    Timer {
        id: gameLoop
        interval: 16; repeat: true
        onTriggered: if (gamePlaying) updateGame()
    }

    Timer {
        id: spawnTimer
        interval: pipeSpawnInterval; repeat: true
        onTriggered: if (gamePlaying) spawnPipe()
    }

    function spawnPipe() {
        var minGapY = 100
        var maxGapY = gameArea.height - pipeGap - 100
        var gapCenterY = Math.random() * (maxGapY - minGapY) + minGapY
        var topHeight = gapCenterY - pipeGap / 2
        var bottomY = gapCenterY + pipeGap / 2
        var bottomHeight = gameArea.height - bottomY

        pipeModel.append({
            x: gameArea.width,
            topHeight: topHeight,
            bottomY: bottomY,
            bottomHeight: bottomHeight,
            passed: false
        })
    }

    function updateGame() {
        birdVY += gravity
        birdY += birdVY
        if (birdY - birdRadius <= 0) {
            birdY = birdRadius; birdVY = 0; endGame(); return
        }
        if (birdY + birdRadius >= gameArea.height) {
            birdY = gameArea.height - birdRadius; endGame(); return
        }
        bird.y = birdY

        for (var i = 0; i < pipeModel.count; ++i) {
            var p = pipeModel.get(i)
            var newX = p.x - pipeSpeed
            pipeModel.setProperty(i, "x", newX)

            if (checkCollision(p)) { endGame(); return }

            if (!p.passed && newX + pipeWidth < birdX) {
                pipeModel.setProperty(i, "passed", true)
                score++
                scoreText.text = "得分: " + score
                if (score > bestScore) {
                    bestScore = score
                    bestScoreText.text = "最高分: " + bestScore
                }
            }

            if (newX + pipeWidth < 0) {
                pipeModel.remove(i)
                i--
            }
        }
    }

    function checkCollision(pipe) {
        var cx = birdX, cy = birdY, r = birdRadius
        if (cx + r > pipe.x && cx - r < pipe.x + pipeWidth &&
            cy + r > 0 && cy - r < pipe.topHeight)
            return true
        if (cx + r > pipe.x && cx - r < pipe.x + pipeWidth &&
            cy + r > pipe.bottomY && cy - r < pipe.bottomY + pipe.bottomHeight)
            return true
        return false
    }

    function endGame() {
        if (!gamePlaying) return
        gamePlaying = false; gameOver = true
        gameLoop.stop(); spawnTimer.stop()
        endGameText.visible = true; restartHint.visible = true
    }

    function startGame() {
        pipeModel.clear()
        birdY = gameArea.height / 2; birdVY = 0; bird.y = birdY
        score = 0; scoreText.text = "得分: 0"
        endGameText.visible = false; restartHint.visible = false
        gamePlaying = true; gameOver = false
        gameLoop.start(); spawnTimer.start()
        spawnPipe()
    }

    function jump() {
        if (gamePlaying) birdVY = jumpForce
        else if (gameOver) startGame()
        else startGame()
    }

    Component.onCompleted: {
        bird.y = birdY
        startHint.visible = true
        gamePlaying = false; gameOver = false
    }
}