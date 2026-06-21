import QtQuick 2.15

Rectangle {
    color: "#2c3e50"; anchors.fill: parent; focus: true
    Keys.onEscapePressed: returnToMenu()
    signal returnToMenu()

    Column {
        anchors.centerIn: parent; spacing: 20

        Text {
            text: "多人联机"; font.pixelSize: 48; color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: 200; height: 60; color: "#27ae60"; radius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "创建游戏"; font.pixelSize: 24; color: "white"; anchors.centerIn: parent }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (typeof networkManager !== "undefined") {
                        if (networkManager.createServer()) {
                            ipText.text = "本机 IP: " + networkManager.getLocalIP()
                            statusText.text = "等待客户端连接..."
                        } else { statusText.text = "创建失败，端口可能被占用" }
                    } else { statusText.text = "网络管理器未初始化" }
                }
            }
        }

        Rectangle {
            width: 300; height: 150; color: "#34495e"; radius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            Column {
                anchors.centerIn: parent; spacing: 10
                Text { text: "加入游戏"; font.pixelSize: 20; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }
                Rectangle {
                    width: 200; height: 40; color: "white"; radius: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    TextInput {
                        id: ipInput; anchors.fill: parent; anchors.margins: 5
                        font.pixelSize: 16; text: "输入主机IP"; color: "black"
                    }
                }
                Rectangle {
                    width: 120; height: 40; color: "#3498db"; radius: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "连接"; font.pixelSize: 18; color: "white"; anchors.centerIn: parent }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof networkManager !== "undefined" && ipInput.text != "") {
                                if (networkManager.joinServer(ipInput.text)) {
                                    statusText.text = "连接成功，等待开始..."; startTimer.start()
                                } else { statusText.text = "连接失败，检查IP和网络" }
                            }
                        }
                    }
                }
            }
        }

        Text { id: ipText; text: ""; font.pixelSize: 16; color: "#f39c12"; anchors.horizontalCenter: parent.horizontalCenter }
        Text { id: statusText; text: ""; font.pixelSize: 18; color: "#ecf0f1"; anchors.horizontalCenter: parent.horizontalCenter }

        Rectangle {
            width: 120; height: 40; color: "#7f8c8d"; radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "返回"; font.pixelSize: 18; color: "white"; anchors.centerIn: parent }
            MouseArea { anchors.fill: parent; onClicked: returnToMenu() }
        }
    }

    Timer {
        id: startTimer; interval: 2000
        onTriggered: {
            if (typeof gameLoader !== "undefined") {
                var mode = (typeof networkManager !== "undefined" && networkManager.isHost) ? "host" : "client"
                gameLoader.setSource("Game.qml", {"mode": mode})
            }
        }
    }

    Component.onCompleted: {
        if (typeof networkManager !== "undefined") {
            networkManager.connected.connect(function() {
                statusText.text = "已连接！正在进入游戏..."
                startTimer.start()
            })
        }
    }
}