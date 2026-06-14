import QtQuick 2.15
import QtMultimedia

Item {
    id: musicPlayer

    SoundEffect {
        id: explosionSound
        source: "file:///root/bubblebomb/music/bombmusic.wav"
        volume: 0.8
    }

    function playExplosion() {
        explosionSound.play()
    }
}