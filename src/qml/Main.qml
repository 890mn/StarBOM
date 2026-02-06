import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"

ApplicationWindow {
    id: root
    width: 1500
    height: 920
    visible: true
    title: "StarBOM"
    color: "#F5F7FB"

    property var appCtx: app
    property string activeProjectForImport: ""
    property int renameProjectIndex: -1
    property int renameCategoryIndex: -1

    Dialog {
        id: projectForImportDialog
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
                placeholderText: "或新建项目"
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
            newProjectField.clear()
        }
    }

    FileDialog {
        id: fileDialog
        title: "选择立创导出文件"
        nameFilters: ["Spreadsheet Files (*.xlsx *.xls *.csv)", "All Files (*.*)"]
        onAccepted: app.importLichuang(selectedFile, activeProjectForImport)
    }

    Dialog {
        id: inputDialog
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string mode: ""

        ColumnLayout {
            anchors.fill: parent
            TextField { id: dialogInput; Layout.fillWidth: true; placeholderText: "请输入名称" }
        }

        onAccepted: {
            const value = dialogInput.text.trim()
            if (mode === "newProject") app.projects.addProject(value)
            if (mode === "renameProject") app.projects.renameProject(renameProjectIndex, value)
            if (mode === "newCategory") app.categories.addCategory(value)
            if (mode === "renameCategory") app.categories.renameCategory(renameCategoryIndex, value)
            dialogInput.clear()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        SidebarPane {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            app: root.appCtx
            onRequestImport: projectForImportDialog.open()
            onRequestNewProject: {
                inputDialog.title = "新建项目"
                inputDialog.mode = "newProject"
                inputDialog.open()
            }
            onRequestRenameProject: function(index, currentName) {
                if (index <= 0 || currentName === "全部项目") {
                    app.notify("请先选择一个具体项目再重命名。")
                    return
                }
                renameProjectIndex = index
                inputDialog.title = "重命名项目"
                inputDialog.mode = "renameProject"
                dialogInput.text = currentName
                inputDialog.open()
            }
            onRequestNewCategory: {
                inputDialog.title = "新增分类组"
                inputDialog.mode = "newCategory"
                inputDialog.open()
            }
            onRequestRenameCategory: function(index, currentName) {
                if (index < 0) {
                    app.notify("请先选择要修改的分类组。")
                    return
                }
                renameCategoryIndex = index
                inputDialog.title = "修改分类组"
                inputDialog.mode = "renameCategory"
                dialogInput.text = currentName
                inputDialog.open()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "white"
            border.color: "#D8E0EA"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

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

                    BomPane { app: root.appCtx }

                    Rectangle {
                        color: "#FFFFFF"
                        border.color: "#E2E8F0"
                        radius: 8
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            Label { text: "库存视图"; font.bold: true }
                            Label { text: "现存、需求、缺口与建议将与导入数据联动（待接入）"; color: "#475569" }
                        }
                    }

                    Rectangle {
                        color: "#FFFFFF"
                        border.color: "#E2E8F0"
                        radius: 8
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            Label { text: "差异分析"; font.bold: true }
                            Label { text: "后续接入版本对比、替代料推荐、成本变化趋势。"; color: "#475569" }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 6
                    color: "#F8FAFC"
                    border.color: "#E2E8F0"
                    Label {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        text: app.status
                        color: "#334155"
                    }
                }
            }
        }
    }
}
