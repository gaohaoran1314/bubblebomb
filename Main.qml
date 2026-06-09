import QtQuick.Window 2.15
import QtQuick 2.15

Window {
    width: 800
    height: 600
    visible: true
    title: "泡泡堂"

    // 顶层焦点容器，确保开始界面能响应 Esc
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: {
            Qt.quit()
        }
    }

    // 动态加载游戏场景
    Loader {
        id: gameLoader
        anchors.fill: parent
        onLoaded: {
            gameLoader.item.forceActiveFocus()
        }
        // 当游戏卸载（返回主菜单）时，重新显示开始画面
        onSourceChanged: {
            if (gameLoader.source == "") {
                startScreen.visible = true
            }
        }
    }

    // 开始界面
    Rectangle {
        id: startScreen
        anchors.fill: parent
        color: "#2c3e50"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "泡泡堂"
                font.pixelSize: 64
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 开始游戏按钮
            Rectangle {
                width: 200
                height: 60
                color: "#27ae60"
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "开始游戏"
                    font.pixelSize: 24
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        startScreen.visible = false
                        gameLoader.source = "Game.qml"
                    }
                }
            }

            // 多人游戏按钮（暂无效）
            Rectangle {
                width: 200
                height: 60
                color: "#3498db"
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "多人游戏"
                    font.pixelSize: 24
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("多人游戏待开发")
                    }
                }
            }

            // 游戏玩法介绍按钮
            Rectangle {
                width: 200
                height: 60
                color: "#f39c12"
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "玩法介绍"
                    font.pixelSize: 24
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        introPopup.visible = true
                    }
                }
            }
        }

        // 简易玩法介绍弹窗
        Rectangle {
            id: introPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            color: "#34495e"
            radius: 10
            border.color: "#1abc9c"
            border.width: 2
            visible: false

            Column {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "游戏玩法"
                    font.pixelSize: 28
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "• 使用方向键移动红色角色\n• 空格键放置炸弹，炸毁砖块和怪物\n• 躲避紫色怪物，炸掉所有怪物即可获胜\n• 被怪物碰到则游戏结束"
                    font.pixelSize: 16
                    color: "#ecf0f1"
                    lineHeight: 1.4
                }

                Rectangle {
                    width: 120
                    height: 40
                    color: "#e74c3c"
                    radius: 8
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "关闭"
                        font.pixelSize: 18
                        color: "white"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            introPopup.visible = false
                        }
                    }
                }
            }
        }
    }
}