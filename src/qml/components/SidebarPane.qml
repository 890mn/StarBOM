import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var app
    required property Dialog projectDialog

    radius: 10
    color: "white"
    border.color: "#D8E0EA"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                Label { text: "StarBOM"; font.pixelSize: 34; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "<span style='font-size:12px'>🐙</span> <a href='https://github.com/890mn/StarBOM'>890mn</a>"
                    textFormat: Text.RichText
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "主题：" }
                Button { text: root.app.theme.currentThemeName; flat: true; onClicked: root.app.cycleTheme() }
                Item { Layout.fillWidth: true }
                Label { text: "v0.3.0"; color: "#6B7280"; font.pixelSize: 12 }
            }
        }

        GroupBox {
            title: "导入"
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                Button { text: "立创导入（XLS）"; Layout.fillWidth: true; onClicked: root.projectDialog.open() }
                Button { text: "从 XLS/XLSX 导入"; Layout.fillWidth: true; onClicked: root.projectDialog.open() }
                Button { text: "OCR 图片导入（后续）"; Layout.fillWidth: true }
            }
        }

        GroupBox {
            title: "导出"
            Layout.fillWidth: true
            ColumnLayout { anchors.fill: parent; Button { text: "导出 CSV"; Layout.fillWidth: true } }
        }

        GroupBox {
            title: "项目"
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.app.projects.model
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: model.display
                        highlighted: root.app.projects.selectedProject === model.display
                        onClicked: root.app.projects.selectedProject = model.display
                    }
                }
            }
        }
    }
}
