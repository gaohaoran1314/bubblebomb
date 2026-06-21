import QtQuick 2.15
import QtMultimedia

Item {
    id: musicPlayer

    // 爆炸音效
    SoundEffect {
        id: explosionSound
        source: "qrc:/sounds/bombmusic.wav"
        volume: 0.8
        loops: 1
    }

    // 背景音乐 (循环播放)
    MediaPlayer {
        id: bgmPlayer
        audioOutput: AudioOutput {
            volume: 0.3   // 音量调低，不干扰音效
        }
        source: "qrc:/sounds/bgm.mp3"
        loops: MediaPlayer.Infinite
    }

    function playExplosion() {
        if (explosionSound.status === SoundEffect.Ready) {
            explosionSound.play()
        } else {
            explosionSound.source = ""
            explosionSound.source = "qrc:/sounds/bombmusic.wav"
            retryTimer.restart()
        }
    }

    function playBGM() {
        if (bgmPlayer.source != "") {
            bgmPlayer.play()
        }
    }

    function stopBGM() {
        bgmPlayer.stop()
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