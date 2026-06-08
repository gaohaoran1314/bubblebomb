import QtQuick 2.15

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 20
    color: "#3cb4ff"
    border.color: "#0066cc"
    border.width: 2

    signal onExploded()
    property bool isBomb: true  // 标记为炸弹，用于碰撞检测

    Component {
        id: firePrefab
        Rectangle {
            width: 40
            height: 40
            color: "#ff5500"
            opacity: 0.9
            Timer {
                interval: 300
                running: true
                onTriggered: parent.destroy()
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: explode()
    }

    Timer {
        id: deleteTimer
        interval: 400
        running: false
        onTriggered: {
            onExploded()
            root.destroy()
        }
    }

    function explode() {
        color = "orange"
        radius = 0

        createFire(x, y)
        createFire(x-40,y)
        createFire(x+40,y)
        createFire(x,y-40)
        createFire(x,y+40)

        hitTargets()
        deleteTimer.start()
    }

    function createFire(fx,fy){
        let f = firePrefab.createObject(parent)
        f.x=fx; f.y=fy
    }

    function hitTargets(){
        let list = parent.children
        for(var i=0;i<list.length;i++){
            let o=list[i]
            let dx=Math.abs(o.x-x)
            let dy=Math.abs(o.y-y)
            if(dx<80&&dy<80){
                if(o.objectName==="monster"&&o.alive) o.die()
                if(o.isBlock&&o.alive) o.die()
            }
        }
    }
}
