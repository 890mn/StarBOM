import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import StarBOM
import "components"

ApplicationWindow {
    id: root
    width: 1500
    height: 920
    visible: true
    title: "StarBOM - QML"

    property string activeProjectForImport: ""

    Dialog {
        id: projectDialog
        title: "选择导入项目"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 420

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            ComboBox {
                id: projectCombo
                Layout.fillWidth: true
                model: app.projects.projectNames(false)
            }
            TextField {
                id: newProjectField
                Layout.fillWidth: true
                placeholderText: "新建项目（可留空）"
            }
        }

        onAccepted: {
            const created = newProjectField.text.trim()
            if (created.length > 0) {
                app.projects.addProject(created)
                activeProjectForImport = created
            } else {
                activeProjectForImport = projectCombo.currentText
            }
            fileDialog.open()
        }
    }

    FileDialog {
        id: fileDialog
        title: "选择立创导出文件"
        nameFilters: ["Spreadsheet Files (*.xlsx *.xls *.csv)", "All Files (*.*)"]
        onAccepted: app.importLichuang(selectedFile, activeProjectForImport)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        SidebarPane {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            app: root.app
            projectDialog: projectDialog
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "white"
            border.color: "#D8E0EA"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12

                TabBar {
                    id: tabs
                    Layout.fillWidth: true
                    TabButton { text: "BOM 视图" }
                    TabButton { text: "库存视图" }
                    TabButton { text: "差异分析" }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: tabs.currentIndex

                    BomPane { app: root.app }
                    Label { text: "库存视图开发中" }
                    Label { text: "差异分析开发中" }
                }

                Label {
                    Layout.fillWidth: true
                    text: app.status
                }
            }
        }
    }
}
