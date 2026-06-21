import QtQuick.Window 2.15
import QtQuick 2.15

Window {
    width: 800
    height: 600
    visible: true
    title: "泡泡堂"

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

        Column {
            anchors.centerIn: parent
            spacing: 25

            Text {
                text: "泡泡堂"
                font.pixelSize: 72; font.bold: true
                color: "#f1c40f"
                style: Text.Outline; styleColor: "#8e44ad"
                anchors.horizontalCenter: parent.horizontalCenter
            }

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
                    onExited: btnStart.scale = 1.0
                    onPressed: btnStart.scale = 0.95
                    onReleased: {
                        btnStart.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Game.qml", { "mode": "single" })
                    }
                    onCanceled: btnStart.scale = 1.0
                }
            }

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
                    onExited: btnMulti.scale = 1.0
                    onPressed: btnMulti.scale = 0.95
                    onReleased: {
                        btnMulti.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Game.qml", { "mode": "multi" })
                    }
                    onCanceled: btnMulti.scale = 1.0
                }
            }

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
                    onExited: btnOnline.scale = 1.0
                    onPressed: btnOnline.scale = 0.95
                    onReleased: {
                        btnOnline.scale = 1.0
                        startScreen.visible = false
                        gameLoader.setSource("Lobby.qml")
                    }
                    onCanceled: btnOnline.scale = 1.0
                }
            }

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
                    onExited: btnHelp.scale = 1.0
                    onPressed: btnHelp.scale = 0.95
                    onReleased: {
                        btnHelp.scale = 1.0
                        introPopup.visible = true
                    }
                    onCanceled: btnHelp.scale = 1.0
                }
            }
        }
    }

    Rectangle {
        id: introPopup
        anchors.centerIn: parent
        width: 420; height: 320
        color: "#2c3e50"; radius: 15; border.color: "#1abc9c"; border.width: 2
        visible: false

        Column {
            anchors.centerIn: parent; spacing: 15
            Text {
                text: "游戏玩法"; font.pixelSize: 32; color: "white"; font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "• 方向键 / WASD 移动\n• 空格键放置炸弹\n• 炸毁砖块可掉落道具\n• 消灭所有怪物即可获胜\n• 小心别被怪物碰到！"
                font.pixelSize: 18; color: "#ecf0f1"; lineHeight: 1.5
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                width: 120; height: 45; color: "#e74c3c"; radius: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "关闭"; font.pixelSize: 20; color: "white"; font.bold: true
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: introPopup.visible = false
                }
            }
        }
    }
}