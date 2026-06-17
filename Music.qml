import QtQuick 2.15
import QtMultimedia

Item {
    id: musicPlayer

    SoundEffect {
        id: explosionSound
        source: "file:///root/bubblebomb/music/bombmusic.wav"
        volume: 0.8
        loops: 1
    }

    // 播放前确保音效已加载
    function playExplosion() {
        if (explosionSound.status === SoundEffect.Ready) {
            explosionSound.play()
        } else {
            // 如果还没准备好，尝试重新设置 source 并等待
            explosionSound.source = ""
            explosionSound.source = "file:///root/bubblebomb/music/bombmusic.wav"
            // 稍后再次尝试播放
            retryTimer.restart()
        }
    }

    Timer {
        id: retryTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (explosionSound.status === SoundEffect.Ready) {
                explosionSound.play()
            }
        }
    }
}