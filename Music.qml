import QtQuick 2.15
import QtMultimedia

Item {
    id: musicPlayer

    // 可外部修改的音量
    property real bgmVolume: 0.3
    property real sfxVolume: 0.8

    // 爆炸音效
    SoundEffect {
        id: explosionSound
        source: "qrc:/sounds/bombmusic.wav"
        volume: musicPlayer.sfxVolume
        loops: 1
    }

    // 受击音效
    SoundEffect {
        id: hitSound
        source: "qrc:/sounds/hit.wav"
        volume: musicPlayer.sfxVolume
    }

    // 放置炸弹音效
    SoundEffect {
        id: placeBombSound
        source: "qrc:/sounds/put.wav"
        volume: musicPlayer.sfxVolume
    }

    // 胜利音效
    SoundEffect {
        id: winSound
        source: "qrc:/sounds/victory.wav"
        volume: musicPlayer.sfxVolume
    }

    // 失败音效
    SoundEffect {
        id: loseSound
        source: "qrc:/sounds/lose.wav"
        volume: musicPlayer.sfxVolume
    }

    // 背景音乐
    MediaPlayer {
        id: bgmPlayer
        audioOutput: AudioOutput { volume: musicPlayer.bgmVolume }
        source: "qrc:/sounds/bgm.mp3"
        loops: MediaPlayer.Infinite
    }

    // ========== 播放函数 ==========
    function playExplosion() {
        if (explosionSound.status === SoundEffect.Ready) {
            explosionSound.play()
        } else {
            explosionSound.source = ""
            explosionSound.source = "qrc:/sounds/bombmusic.wav"
            retryTimer.restart()
        }
    }

    function playHit() {
        if (hitSound.status === SoundEffect.Ready) {
            hitSound.play()
        } else {
            hitSound.source = ""
            hitSound.source = "qrc:/sounds/hit.wav"
            Qt.callLater(function() {
                if (hitSound.status === SoundEffect.Ready) hitSound.play()
            })
        }
    }

    function playPlaceBomb() {
        if (placeBombSound.status === SoundEffect.Ready) {
            placeBombSound.play()
        } else {
            placeBombSound.source = ""
            placeBombSound.source = "qrc:/sounds/put.wav"
            Qt.callLater(function() {
                if (placeBombSound.status === SoundEffect.Ready) placeBombSound.play()
            })
        }
    }

    function playWin() {
        if (winSound.status === SoundEffect.Ready) {
            winSound.play()
        } else {
            winSound.source = ""
            winSound.source = "qrc:/sounds/win.wav"
            Qt.callLater(function() {
                if (winSound.status === SoundEffect.Ready) winSound.play()
            })
        }
    }

    function playLose() {
        if (loseSound.status === SoundEffect.Ready) {
            loseSound.play()
        } else {
            loseSound.source = ""
            loseSound.source = "qrc:/sounds/lose.wav"
            Qt.callLater(function() {
                if (loseSound.status === SoundEffect.Ready) loseSound.play()
            })
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

    // 音量调整
    function adjustBGMVolume(vol) {
        bgmVolume = vol
        bgmPlayer.audioOutput.volume = vol
    }

    function adjustSFXVolume(vol) {
        sfxVolume = vol
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