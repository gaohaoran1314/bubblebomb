import QtQuick 2.15

Rectangle {
    id: root
    width: 420; height: 360
    color: "#2c3e50"; radius: 12
    border.color: "#f1c40f"; border.width: 2

    property var bindings        // 外部传入 KeyBindings 实例
    property bool capturing: false
    property string currentAction: ""

    // 捕获按键
    Keys.onPressed: function(event) {
        if (!capturing) return
        event.accepted = true
        var code = event.key
        // 更新对应键位
        if (currentAction === "left") bindings.keyLeft = code
        else if (currentAction === "right") bindings.keyRight = code
        else if (currentAction === "up") bindings.keyUp = code
        else if (currentAction === "down") bindings.keyDown = code
        else if (currentAction === "bomb") bindings.keyBomb = code
        else if (currentAction === "2left") bindings.key2Left = code
        else if (currentAction === "2right") bindings.key2Right = code
        else if (currentAction === "2up") bindings.key2Up = code
        else if (currentAction === "2down") bindings.key2Down = code
        else if (currentAction === "2bomb") bindings.key2Bomb = code
        capturing = false
        currentAction = ""
    }

    Column {
        anchors.centerIn: parent; spacing: 12

        Text { text: "键位设置"; font.pixelSize: 26; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

        // 玩家1
        Text { text: "玩家1"; font.pixelSize: 18; color: "#ff6666"; anchors.horizontalCenter: parent.horizontalCenter }
        KeyRow { label: "左"; action: "left"; root: root }
        KeyRow { label: "右"; action: "right"; root: root }
        KeyRow { label: "上"; action: "up"; root: root }
        KeyRow { label: "下"; action: "down"; root: root }
        KeyRow { label: "炸弹"; action: "bomb"; root: root }

        // 玩家2
        Text { text: "玩家2"; font.pixelSize: 18; color: "#6666ff"; anchors.horizontalCenter: parent.horizontalCenter }
        KeyRow { label: "左"; action: "2left"; root: root }
        KeyRow { label: "右"; action: "2right"; root: root }
        KeyRow { label: "上"; action: "2up"; root: root }
        KeyRow { label: "下"; action: "2down"; root: root }
        KeyRow { label: "炸弹"; action: "2bomb"; root: root }

        Rectangle {
            width: 90; height: 36; color: "#e74c3c"; radius: 8; anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "关闭"; color: "white"; anchors.centerIn: parent; font.pixelSize: 16 }
            MouseArea { anchors.fill: parent; onClicked: root.visible = false }
        }
    }

    // 每一行：标签 + 当前键名按钮
    component KeyRow: Row {
        property string label
        property string action
        property var root
        spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
        Text { text: label; color: "white"; width: 30; anchors.verticalCenter: parent.verticalCenter }
        Rectangle {
            width: 100; height: 30; color: "#34495e"; radius: 6
            Text {
                anchors.centerIn: parent
                text: root.bindings.keyName(root.bindings[action]) ?? "?"
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.capturing = true
                    root.currentAction = action
                }
            }
        }
    }
}