pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    required property var themeColors
    required property color textColor
    required property color borderColor
    required property color subtleColor
    required property color cardColor
    required property color primaryColor
    required property string debugLogText
    required property bool showInfoLogs
    required property bool showWarningLogs
    required property bool showErrorLogs
    required property var textMap
    signal infoLogsToggled(bool checked)
    signal warningLogsToggled(bool checked)
    signal errorLogsToggled(bool checked)
    signal clearRequested()

    function txSafe(key, fallback) {
        if (root.textMap && root.textMap[key] !== undefined) {
            return root.textMap[key]
        }
        return fallback
    }

    width: Math.min(parent ? parent.width - 40 : 920, 920)
    height: Math.min(parent ? parent.height - 60 : 420, 420)
    modal: false
    focus: true
    padding: 10
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 12
        color: root.subtleColor
        border.color: root.borderColor
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.txSafe("debug.console", "Debug Console")
                color: root.textColor
                elide: Text.ElideRight
                font.bold: true
            }

            CheckBox {
                text: "Info"
                checked: root.showInfoLogs
                onToggled: root.infoLogsToggled(checked)
            }

            CheckBox {
                text: "Warning"
                checked: root.showWarningLogs
                onToggled: root.warningLogsToggled(checked)
            }

            CheckBox {
                text: "Error"
                checked: root.showErrorLogs
                onToggled: root.errorLogsToggled(checked)
            }

            AppButton {
                themeColors: root.themeColors
                text: root.txSafe("debug.clear", "Clear")
                implicitHeight: 28
                implicitWidth: 72
                onClicked: root.clearRequested()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                readOnly: true
                wrapMode: TextEdit.NoWrap
                textFormat: TextEdit.RichText
                text: root.debugLogText
                color: root.textColor
                selectionColor: root.primaryColor
                selectedTextColor: "#FFFFFF"
                font.pixelSize: 12
                background: Rectangle {
                    color: Qt.rgba(root.cardColor.r, root.cardColor.g, root.cardColor.b, 0.65)
                    radius: 8
                    border.color: root.borderColor
                }

                onTextChanged: cursorPosition = length
            }
        }
    }
}
