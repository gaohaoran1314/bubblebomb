import QtQuick 2.15
import QtCore

Item {
    id: bindings

    // 键位属性，直接绑定到 Settings
    property int keyLeft: s.value("keyLeft", Qt.Key_A)
    property int keyRight: s.value("keyRight", Qt.Key_D)
    property int keyUp: s.value("keyUp", Qt.Key_W)
    property int keyDown: s.value("keyDown", Qt.Key_S)
    property int keyBomb: s.value("keyBomb", Qt.Key_Space)

    property int key2Left: s.value("key2Left", Qt.Key_Left)
    property int key2Right: s.value("key2Right", Qt.Key_Right)
    property int key2Up: s.value("key2Up", Qt.Key_Up)
    property int key2Down: s.value("key2Down", Qt.Key_Down)
    property int key2Bomb: s.value("key2Bomb", Qt.Key_Return)

    // 持久化对象
    Settings {
        id: s
        category: "KeyBindings"
    }

    // 保存键位（修改后调用）
    function save() {
        s.setValue("keyLeft", keyLeft)
        s.setValue("keyRight", keyRight)
        s.setValue("keyUp", keyUp)
        s.setValue("keyDown", keyDown)
        s.setValue("keyBomb", keyBomb)
        s.setValue("key2Left", key2Left)
        s.setValue("key2Right", key2Right)
        s.setValue("key2Up", key2Up)
        s.setValue("key2Down", key2Down)
        s.setValue("key2Bomb", key2Bomb)
    }

    // 将按键代码转为可读字符串
    function keyName(code) {
        switch (code) {
            case Qt.Key_A: return "A"
            case Qt.Key_B: return "B"
            case Qt.Key_C: return "C"
            case Qt.Key_D: return "D"
            case Qt.Key_E: return "E"
            case Qt.Key_F: return "F"
            case Qt.Key_G: return "G"
            case Qt.Key_H: return "H"
            case Qt.Key_I: return "I"
            case Qt.Key_J: return "J"
            case Qt.Key_K: return "K"
            case Qt.Key_L: return "L"
            case Qt.Key_M: return "M"
            case Qt.Key_N: return "N"
            case Qt.Key_O: return "O"
            case Qt.Key_P: return "P"
            case Qt.Key_Q: return "Q"
            case Qt.Key_R: return "R"
            case Qt.Key_S: return "S"
            case Qt.Key_T: return "T"
            case Qt.Key_U: return "U"
            case Qt.Key_V: return "V"
            case Qt.Key_W: return "W"
            case Qt.Key_X: return "X"
            case Qt.Key_Y: return "Y"
            case Qt.Key_Z: return "Z"
            case Qt.Key_Space: return "Space"
            case Qt.Key_Return: return "Enter"
            case Qt.Key_Left: return "←"
            case Qt.Key_Right: return "→"
            case Qt.Key_Up: return "↑"
            case Qt.Key_Down: return "↓"
            default: return "?"
        }
    }
}