pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    id: root
    required property var app
    required property var themeColors
    required property color textColor
    required property color mutedTextColor
    required property color primaryColor
    required property color subtleColor
    required property color cardColor
    required property color borderColor
    required property string uiLanguage
    required property var textMap
    signal languageApplied(string language)
    signal inputAccepted(string mode, string value)

    function txSafe(key, fallback) {
        if (root.textMap && root.textMap[key] !== undefined) {
            return root.textMap[key]
        }
        return fallback
    }

    function openProjectImportDialog() {
        projectForImportDialog.open()
    }

    function openInputDialog(mode, titleText, currentText) {
        inputDialog.mode = mode
        inputDialog.titleText = titleText
        dialogInput.text = currentText === undefined ? "" : currentText
        inputDialog.open()
    }

    function openSettingsDialog() {
        settingsDialog.open()
    }

    property string activeProjectForImport: ""

    Popup {
        id: projectForImportDialog
        modal: true
        focus: true
        width: 420
        implicitHeight: importDialogContent.implicitHeight + 20
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 10

        background: Rectangle {
            radius: 12
            color: root.subtleColor
            border.color: root.borderColor
        }

        ColumnLayout {
            id: importDialogContent
            anchors.fill: parent
            spacing: 10

            Label {
                text: root.txSafe("dialog.selectImportProject", "Select Import Project")
                color: root.textColor
                font.bold: true
            }

            ComboBox {
                id: projectCombo
                Layout.fillWidth: true
                model: root.app.projects.projectNames(false)
                implicitHeight: 36
                font.pixelSize: 13
                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 24
                    text: projectCombo.displayText
                    color: root.textColor
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    radius: 10
                    color: root.cardColor
                    border.color: root.borderColor
                }
            }

            TextField {
                id: newProjectField
                Layout.fillWidth: true
                placeholderText: root.txSafe("dialog.newProjectOr", "Or create new project")
                implicitHeight: 36
                color: root.textColor
                placeholderTextColor: root.mutedTextColor
                selectionColor: root.primaryColor
                selectedTextColor: "#FFFFFF"
                background: Rectangle {
                    radius: 10
                    color: root.cardColor
                    border.color: root.borderColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.cancel", "Cancel")
                    onClicked: projectForImportDialog.close()
                }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.ok", "OK")
                    accent: true
                    onClicked: {
                        const created = newProjectField.text.trim()
                        if (created.length > 0) {
                            root.app.projects.addProject(created)
                            root.activeProjectForImport = created
                        } else {
                            root.activeProjectForImport = projectCombo.currentText
                        }
                        fileDialog.open()
                        newProjectField.clear()
                        projectForImportDialog.close()
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: root.txSafe("dialog.selectLichuangFile", "Select LCSC export file")
        nameFilters: ["Spreadsheet Files (*.xlsx *.xls *.csv)", "All Files (*.*)"]
        onAccepted: root.app.importLichuang(selectedFile, root.activeProjectForImport)
    }

    FileDialog {
        id: exportFileDialog
        title: root.txSafe("dialog.selectExportCsvFile", "Select CSV export file")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: ["CSV Files (*.csv)", "All Files (*.*)"]
        onAccepted: root.app.exportCsv(selectedFile)
    }

    function openExportDialog() {
        exportFileDialog.open()
    }

    Popup {
        id: inputDialog
        modal: true
        focus: true
        property string mode: ""
        property string titleText: ""
        width: 420
        implicitHeight: inputDialogContent.implicitHeight + 20
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 10

        background: Rectangle {
            radius: 12
            color: root.subtleColor
            border.color: root.borderColor
        }

        ColumnLayout {
            id: inputDialogContent
            anchors.fill: parent
            spacing: 10

            Label {
                text: inputDialog.titleText
                color: root.textColor
                font.bold: true
            }

            TextField {
                id: dialogInput
                Layout.fillWidth: true
                placeholderText: root.txSafe("dialog.inputName", "Please enter a name")
                implicitHeight: 36
                color: root.textColor
                placeholderTextColor: root.mutedTextColor
                selectionColor: root.primaryColor
                selectedTextColor: "#FFFFFF"
                background: Rectangle {
                    radius: 10
                    color: root.cardColor
                    border.color: root.borderColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.cancel", "Cancel")
                    onClicked: inputDialog.close()
                }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.ok", "OK")
                    accent: true
                    onClicked: {
                        root.inputAccepted(inputDialog.mode, dialogInput.text.trim())
                        dialogInput.clear()
                        inputDialog.close()
                    }
                }
            }
        }
    }

    Popup {
        id: settingsDialog
        modal: true
        focus: true
        width: 340
        implicitHeight: settingsContent.implicitHeight + 20
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 10
        property string pendingLanguage: root.uiLanguage

        background: Rectangle {
            radius: 12
            color: root.subtleColor
            border.color: root.borderColor
        }

        ColumnLayout {
            id: settingsContent
            anchors.fill: parent
            spacing: 10

            Label {
                text: root.txSafe("settings.title", "Settings")
                color: root.textColor
                font.bold: true
            }

            Label {
                text: root.txSafe("settings.language", "Language")
                color: root.textColor
            }

            ComboBox {
                id: languageCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "value"
                implicitHeight: 36
                font.pixelSize: 13
                model: [
                    { "label": root.txSafe("settings.lang.zh", "Chinese"), "value": "zh-CN" },
                    { "label": root.txSafe("settings.lang.en", "English"), "value": "en-US" }
                ]
                Component.onCompleted: currentIndex = root.uiLanguage === "en-US" ? 1 : 0
                onActivated: settingsDialog.pendingLanguage = currentValue
                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 24
                    text: languageCombo.displayText
                    color: root.textColor
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    radius: 10
                    color: root.cardColor
                    border.color: root.borderColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.cancel", "Cancel")
                    onClicked: settingsDialog.close()
                }

                AppButton {
                    themeColors: root.themeColors
                    text: root.txSafe("common.ok", "OK")
                    accent: true
                    onClicked: {
                        root.languageApplied(settingsDialog.pendingLanguage)
                        settingsDialog.close()
                    }
                }
            }
        }

        onOpened: {
            languageCombo.currentIndex = root.uiLanguage === "en-US" ? 1 : 0
            pendingLanguage = root.uiLanguage
        }
    }
}
