import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 320; height: 220
    color: "#2c3e50"; radius: 12
    border.color: "#1abc9c"; border.width: 2

    property real bgmVol: 0.3
    property real sfxVol: 0.8

    Column {
        anchors.centerIn: parent
        spacing: 18

        Text { text: "音量设置"; font.pixelSize: 26; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

        Row { spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "BGM"; color: "white"; width: 40; anchors.verticalCenter: parent.verticalCenter }
            Slider {
                from: 0; to: 1; value: bgmVol; width: 180
                onValueChanged: { bgmVol = value; if (typeof musicPlayer !== "undefined") musicPlayer.adjustBGMVolume(value) }
            }
        }
        Row { spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "音效"; color: "white"; width: 40; anchors.verticalCenter: parent.verticalCenter }
            Slider {
                from: 0; to: 1; value: sfxVol; width: 180
                onValueChanged: { sfxVol = value; if (typeof musicPlayer !== "undefined") musicPlayer.adjustSFXVolume(value) }
            }
        }

        Rectangle {
            width: 90; height: 36; color: "#e74c3c"; radius: 8; anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "关闭"; color: "white"; anchors.centerIn: parent; font.pixelSize: 16 }
            MouseArea { anchors.fill: parent; onClicked: root.visible = false }
        }
    }
}