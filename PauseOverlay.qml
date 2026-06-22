import QtQuick 2.15

Rectangle {
    anchors.fill: parent
    color: "#80000000"
    visible: parent.paused   // 需要父组件有 paused 属性

    Column {
        anchors.centerIn: parent; spacing: 20

        Text { text: "游戏暂停"; font.pixelSize: 42; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }

        MenuButton { text: "继续"; onClicked: parent.parent.paused = false }
        MenuButton { text: "重新开始"; onClicked: { parent.parent.resetGame(); parent.parent.paused = false } }
        MenuButton { text: "返回主菜单"; onClicked: { parent.parent.returnToMainMenu(); parent.parent.paused = false } }
    }

    component MenuButton: Rectangle {
        property alias text: btnText.text
        signal clicked
        width: 180; height: 45; color: "#2ecc71"; radius: 10
        Text { id: btnText; anchors.centerIn: parent; font.pixelSize: 22; color: "white" }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
    }
}