import QtQuick 2.15

Rectangle {
    id: powerUp
    width: 32; height: 32; radius: 6
    color: "gold"; border.color: "#d4a017"; border.width: 2
    objectName: "powerup"

    property string type: "bomb"
    property int amount: 1
    property bool alive: true

    SequentialAnimation on y {
        loops: Animation.Infinite; running: true
        NumberAnimation { to: y - 4; duration: 600; easing.type: Easing.InOutQuad }
        NumberAnimation { to: y + 4; duration: 600; easing.type: Easing.InOutQuad }
    }

    RotationAnimation on rotation {
        loops: Animation.Infinite; running: true
        from: 0; to: 360; duration: 3000
    }

    Text {
        anchors.centerIn: parent
        text: {
            switch (powerUp.type) {
                case "bomb": return "💣+"
                case "speed": return "⚡"
                case "health": return "❤️"
                case "range": return "🔥+"
                default: return "?"
            }
        }
        font.pixelSize: 16; color: "black"
    }

    Timer {
        id: disappearTimer
        interval: 30000; running: true
        onTriggered: {
            if (powerUp.alive) {
                powerUp.alive = false;
                powerUp.destroy();
            }
        }
    }

    function collect() {
        if (!alive) return;
        alive = false;
        disappearTimer.stop();

        // 主机通知客户端该道具已被收集
        if (typeof gameRoot !== "undefined" && gameRoot.mode === "host" && typeof NetworkManager !== "undefined") {
            NetworkManager.sendPowerUpCollected(x, y, type);
        }
        destroy();
    }
}