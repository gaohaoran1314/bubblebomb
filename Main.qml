import QtQuick.Window 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15   // 需要 Slider

Window {
    width: 800
    height: 600
    visible: true
    title: "泡泡堂"

    // 顶层焦点处理 ESC 返回
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: {
            if (gameLoader.source != "") {
                gameLoader.source = ""
            } else {
                Qt.quit()
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        onLoaded: {
            gameLoader.item.forceActiveFocus()
            if (gameLoader.item.returnToMenu) {
                gameLoader.item.returnToMenu.connect(function() {
                    gameLoader.source = ""
                })
            }
        }
        onSourceChanged: {
            if (gameLoader.source == "") startScreen.visible = true
        }
    }

    // 主菜单背景层（星空）
    Rectangle {
        id: startScreen
        anchors.fill: parent
        color: "#0a0a2e"

        Repeater {
            model: 80
            Rectangle {
                width: 4; height: 4; radius: 2
                color: Qt.rgba(1, 1, 1, 0.5 + Math.random() * 0.5)
                x: Math.random() * parent.width
                y: Math.random() * parent.height
                SequentialAnimation on opacity {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: 0.1; duration: 500 + Math.random() * 1000 }
                    NumberAnimation { to: 0.9; duration: 500 + Math.random() * 1000 }
                }
                SequentialAnimation on x {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: x + (Math.random() * 20 - 10); duration: 2000 + Math.random() * 3000 }
                }
                SequentialAnimation on y {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: y + (Math.random() * 20 - 10); duration: 2000 + Math.random() * 3000 }
                }
            }
        }

        // 主菜单按钮区域
        Column {
            anchors.centerIn: parent
            spacing: 25

            // 标题
            Text {
                text: "泡泡堂"
                font.pixelSize: 72; font.bold: true
                color: "#f1c40f"
                style: Text.Outline; styleColor: "#8e44ad"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 开始游戏按钮
            Rectangle {
                id: btnStart
                width: 220; height: 65; color: "#27ae60"; radius: 15
                border.color: "#2ecc71"; border.width: 2; scale: 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text {
                    text: "开始游戏"; font.pixelSize: 26; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: btnStart.scale = 1.08
                    onExited:  btnStart.scale = 1.0
                    onPressed: btnStart.scale = 0.95
                    onReleased: {
                        btnStart.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Game.qml", { "mode": "single" })
                    }
                    onCanceled: btnStart.scale = 1.0
                }
            }

            // 多人游戏按钮
            Rectangle {
                id: btnMulti
                width: 220; height: 65; color: "#2980b9"; radius: 15
                border.color: "#3498db"; border.width: 2; scale: 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text {
                    text: "多人游戏"; font.pixelSize: 26; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: btnMulti.scale = 1.08
                    onExited:  btnMulti.scale = 1.0
                    onPressed: btnMulti.scale = 0.95
                    onReleased: {
                        btnMulti.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Game.qml", { "mode": "multi" })
                    }
                    onCanceled: btnMulti.scale = 1.0
                }
            }

            // 多人联机按钮
            Rectangle {
                id: btnOnline
                width: 220; height: 65; color: "#8e44ad"; radius: 15
                border.color: "#9b59b6"; border.width: 2; scale: 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text {
                    text: "多人联机"; font.pixelSize: 26; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: btnOnline.scale = 1.08
                    onExited:  btnOnline.scale = 1.0
                    onPressed: btnOnline.scale = 0.95
                    onReleased: {
                        btnOnline.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Lobby.qml")
                    }
                    onCanceled: btnOnline.scale = 1.0
                }
            }

            // 玩法说明按钮
            Rectangle {
                id: btnHelp
                width: 220; height: 65; color: "#e67e22"; radius: 15
                border.color: "#f39c12"; border.width: 2; scale: 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text {
                    text: "玩法说明"; font.pixelSize: 26; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: btnHelp.scale = 1.08
                    onExited:  btnHelp.scale = 1.0
                    onPressed: btnHelp.scale = 0.95
                    onReleased: {
                        btnHelp.scale = 1.0
                        introPopup.visible = true
                    }
                    onCanceled: btnHelp.scale = 1.0
                }
            }

            // 设置按钮（新增）
            Rectangle {
                id: btnSettings
                width: 220; height: 65; color: "#9b59b6"; radius: 15
                border.color: "#c39bd3"; border.width: 2; scale: 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text {
                    text: "设置"; font.pixelSize: 26; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: btnSettings.scale = 1.08
                    onExited:  btnSettings.scale = 1.0
                    onPressed: btnSettings.scale = 0.95
                    onReleased: {
                        btnSettings.scale = 1.0
                        settingsPanel.visible = true
                    }
                    onCanceled: btnSettings.scale = 1.0
                }
            }
        }
    }

    // 玩法说明弹窗（保持不变）
    Rectangle {
        id: introPopup
        anchors.centerIn: parent
        width: 420; height: 320
        color: "#2c3e50"; radius: 15; border.color: "#1abc9c"; border.width: 2
        visible: false
        Column {
            anchors.centerIn: parent; spacing: 15
            Text { text: "游戏玩法"; font.pixelSize: 32; color: "white"; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "• 方向键 / WASD 移动\n• 空格键放置炸弹\n• 炸毁砖块可掉落道具\n• 消灭所有怪物即可获胜\n• 小心别被怪物碰到！"
                font.pixelSize: 18; color: "#ecf0f1"; lineHeight: 1.5; anchors.horizontalCenter: parent.horizontalCenter }
            Rectangle {
                width: 120; height: 45; color: "#e74c3c"; radius: 10; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "关闭"; font.pixelSize: 20; color: "white"; font.bold: true; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; onClicked: introPopup.visible = false }
            }
        }
    }

    // 设置面板（新增）
    Rectangle {
        id: settingsPanel
        anchors.centerIn: parent
        width: 320; height: 280
        color: "#34495e"; radius: 15; border.color: "#1abc9c"; border.width: 2
        visible: false

        Column {
            anchors.centerIn: parent; spacing: 20

            Text { text: "设置"; font.pixelSize: 30; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

            Rectangle {
                width: 200; height: 50; color: "#e67e22"; radius: 10
                Text { text: "音量控制"; font.pixelSize: 22; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        volumePanel.visible = true
                        settingsPanel.visible = false
                    }
                }
            }

            Rectangle {
                width: 200; height: 50; color: "#3498db"; radius: 10
                Text { text: "键位设置"; font.pixelSize: 22; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        keyConfig.visible = true
                        settingsPanel.visible = false
                    }
                }
            }

            Rectangle {
                width: 120; height: 40; color: "#e74c3c"; radius: 8
                Text { text: "关闭"; font.pixelSize: 18; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: settingsPanel.visible = false
                }
            }
        }
    }

    // 音量控制面板（新增）
    Rectangle {
        id: volumePanel
        anchors.centerIn: parent
        width: 340; height: 240
        color: "#2c3e50"; radius: 15; border.color: "#1abc9c"; border.width: 2
        visible: false

        Column {
            anchors.centerIn: parent; spacing: 20

            Text { text: "音量设置"; font.pixelSize: 28; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

            // BGM 滑块
            Row {
                spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "BGM"; color: "white"; width: 50; anchors.verticalCenter: parent.verticalCenter }
                Slider {
                    id: bgmSlider
                    from: 0; to: 1; value: 0.3; width: 200
                    onValueChanged: {
                        if (typeof gameLoader.item !== "undefined" && gameLoader.item.music) {
                            gameLoader.item.music.adjustBGMVolume(value)
                        }
                    }
                }
            }
            // 音效滑块
            Row {
                spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "音效"; color: "white"; width: 50; anchors.verticalCenter: parent.verticalCenter }
                Slider {
                    id: sfxSlider
                    from: 0; to: 1; value: 0.8; width: 200
                    onValueChanged: {
                        if (typeof gameLoader.item !== "undefined" && gameLoader.item.music) {
                            gameLoader.item.music.adjustSFXVolume(value)
                        }
                    }
                }
            }

            Rectangle {
                width: 90; height: 36; color: "#e74c3c"; radius: 8
                Text { text: "返回"; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        volumePanel.visible = false
                        settingsPanel.visible = true
                    }
                }
            }
        }
    }

    // 键位设置面板（新增）
    Rectangle {
        id: keyConfig
        anchors.centerIn: parent
        width: 420; height: 380
        color: "#2c3e50"; radius: 15; border.color: "#f1c40f"; border.width: 2
        visible: false

        // 键位绑定实例（共享 Settings）
        KeyBindings { id: keyBindings }

        property bool capturing: false
        property string currentAction: ""

        Keys.onPressed: function(event) {
            if (!capturing) return
            event.accepted = true
            var code = event.key
            if (currentAction === "left") keyBindings.keyLeft = code
            else if (currentAction === "right") keyBindings.keyRight = code
            else if (currentAction === "up") keyBindings.keyUp = code
            else if (currentAction === "down") keyBindings.keyDown = code
            else if (currentAction === "bomb") keyBindings.keyBomb = code
            else if (currentAction === "2left") keyBindings.key2Left = code
            else if (currentAction === "2right") keyBindings.key2Right = code
            else if (currentAction === "2up") keyBindings.key2Up = code
            else if (currentAction === "2down") keyBindings.key2Down = code
            else if (currentAction === "2bomb") keyBindings.key2Bomb = code
            capturing = false
            currentAction = ""
        }

        Column {
            anchors.centerIn: parent; spacing: 10

            Text { text: "键位设置"; font.pixelSize: 28; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

            Text { text: "玩家1"; font.pixelSize: 20; color: "#ff6666"; anchors.horizontalCenter: parent.horizontalCenter }
            Row { spacing: 10
                Text { text: "左"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.keyLeft); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "left" } }
                }
            }
            Row { spacing: 10
                Text { text: "右"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.keyRight); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "right" } }
                }
            }
            Row { spacing: 10
                Text { text: "上"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.keyUp); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "up" } }
                }
            }
            Row { spacing: 10
                Text { text: "下"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.keyDown); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "down" } }
                }
            }
            Row { spacing: 10
                Text { text: "炸弹"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.keyBomb); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "bomb" } }
                }
            }

            Text { text: "玩家2"; font.pixelSize: 20; color: "#6666ff"; anchors.horizontalCenter: parent.horizontalCenter }
            Row { spacing: 10
                Text { text: "左"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.key2Left); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "2left" } }
                }
            }
            Row { spacing: 10
                Text { text: "右"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.key2Right); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "2right" } }
                }
            }
            Row { spacing: 10
                Text { text: "上"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.key2Up); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "2up" } }
                }
            }
            Row { spacing: 10
                Text { text: "下"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.key2Down); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "2down" } }
                }
            }
            Row { spacing: 10
                Text { text: "炸弹"; color: "white"; width: 40 }
                Rectangle { width: 100; height: 30; color: "#34495e"; radius: 5
                    Text { anchors.centerIn: parent; text: keyBindings.keyName(keyBindings.key2Bomb); color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: { keyConfig.capturing = true; keyConfig.currentAction = "2bomb" } }
                }
            }

            Rectangle {
                width: 90; height: 36; color: "#e74c3c"; radius: 8; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "返回"; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        keyConfig.visible = false
                        settingsPanel.visible = true
                    }
                }
            }
        }
    }
}