import QtQuick 2.15

Rectangle {
    id: powerUp
    width: 32
    height: 32
    radius: 6
    color: "gold"
    border.color: "#d4a017"
    border.width: 2
    objectName: "powerup"

    property string type: "bomb"
    property int amount: 1
    property bool alive: true

    Text {
        anchors.centerIn: parent
        text: {
            switch (powerUp.type) {
                case "bomb":   return "💣+"
                case "speed":  return "⚡"
                case "health": return "❤️"
                case "range":  return "🔥+"
                default:       return "?"
            }
        }
        font.pixelSize: 16
        color: "black"
    }

    Timer {
        id: disappearTimer
        interval: 30000
        running: true
        repeat: false
        onTriggered: {
            if (powerUp.alive) {
                powerUp.alive = false
                powerUp.destroy()
            }
        }
    }

    function collect() {
        if (!alive) return
        alive = false
        disappearTimer.stop()
        destroy()
    }
}