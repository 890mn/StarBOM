pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import "components"

ApplicationWindow {
    id: root
    width: minimumWidth
    height: minimumHeight
    visible: true
    title: "Link2BOM"
    minimumWidth: 1100
    minimumHeight: 700

    required property var appCtx
    property int renameProjectIndex: -1
    property int renameCategoryIndex: -1
    property bool pinnedTopMost: false
    property bool debugPanelVisible: false
    property var debugEntries: []
    property string debugLogText: ""
    property int debugLogLimit: 500
    property bool showInfoLogs: true
    property bool showWarningLogs: true
    property bool showErrorLogs: true
    property string uiLanguage: uiSettings.language
    property var textMap: uiLanguage === "en-US" ? textEn : textZh
    property int activeTabIndex: 0
    property string bomSearchText: ""
    property string diffSearchText: ""
    property string diffGroupMode: "project"
    property string diffViewMode: "list"
    property var diffItems: []
    property var diffStats: ({})
    property bool syncingTopSearch: false
    property var textZh: ({
        "dialog.selectImportProject": "选择导入项目",
        "dialog.newProjectOr": "或新建项目",
        "dialog.selectLichuangFile": "选择立创导出文件",
        "dialog.selectExportCsvFile": "选择导出 CSV 文件",
        "dialog.inputName": "请输入名称",
        "dialog.newProject": "新建项目",
        "dialog.renameProject": "重命名项目",
        "dialog.newCategory": "新增分类组",
        "dialog.renameCategory": "修改分类组",
        "warn.selectProjectRename": "请先选择一个具体项目再重命名。",
        "warn.selectProjectDelete": "请先选择一个具体项目再删除。",
        "warn.selectCategoryRename": "请先选择要修改的分类组。",
        "warn.selectCategoryDelete": "请先选择要删除的分类组。",
        "notify.categoryDeleted": "分类组已删除: ",
        "tab.bomView": "BOM 视图",
        "tab.diff": "差异分析",
        "search.placeholder": "全文搜索（料号/位号/规格/备注）",
        "common.clear": "清空",
        "common.ok": "确定",
        "common.cancel": "取消",
        "diff.title": "差异分析",
        "diff.todo": "后续接入版本对比、替代料推荐、成本变化趋势。",
        "diff.search.placeholder": "搜索差异（关键料号/字段/值）",
        "diff.group.by": "分组",
        "diff.group.project": "按项目",
        "diff.group.package": "按封装",
        "diff.group.brand": "按品牌",
        "diff.result.count": "差异条目",
        "diff.changed.fields": "差异字段",
        "diff.noresult": "未发现差异条目",
        "diff.view.list": "差异列表",
        "diff.view.bar": "柱状图",
        "diff.view.pie": "饼状图",
        "diff.health.score": "库存健康度",
        "diff.health.total": "总条目",
        "diff.health.unique": "唯一料号",
        "diff.health.lowqty": "低库存",
        "diff.health.missing": "缺失关键字段",
        "diff.health.duplicate": "重复料号",
        "diff.suggestions": "建议",
        "debug.console": "调试控制台",
        "debug.clear": "清空",
        "settings.title": "设置",
        "settings.language": "语言",
        "settings.lang.zh": "中文",
        "settings.lang.en": "English",
        "projects.all": "全部项目",
        "common.new": "新建",
        "common.rename": "重命名",
        "common.delete": "删除",
        "common.reset": "重置",
        "sidebar.import": "导入",
        "sidebar.import.lcsc": "立创导入 (XLS)",
        "sidebar.import.sheet": "导入 XLS/XLSX",
        "sidebar.import.ocr": "OCR 导入（后续）",
        "sidebar.import.ocr.todo": "OCR 流程尚未接入。",
        "sidebar.export": "导出",
        "sidebar.export.csv": "导出 CSV",
        "sidebar.export.todo": "CSV 导出已触发。",
        "sidebar.projects": "项目",
        "sidebar.categories": "分类",
        "sidebar.height": "高度",
        "sidebar.height.auto": "自动高度",
        "sidebar.height.custom": "自定义高度",
        "tree.brand": "品牌",
        "tree.package": "封装",
        "tree.type": "类型",
        "tree.type.clear": "清空类型筛选",
        "type.resistor": "电阻/阻值件",
        "type.capacitor": "电容",
        "type.inductor": "电感",
        "type.ic": "IC/芯片",
        "type.connector": "连接器",
        "type.switch": "开关",
        "type.power": "电源",
        "type.other": "其他",
        "bom.column.config": "列设置",
        "bom.column.insert.left": "左侧新建",
        "bom.column.insert.right": "右侧新建",
        "bom.column.fields": "字段选择",
        "bom.column.width": "自定义宽度",
        "bom.column.ratio": "比例"
    })
    property var textEn: ({
        "dialog.selectImportProject": "Select Import Project",
        "dialog.newProjectOr": "Or create new project",
        "dialog.selectLichuangFile": "Select LCSC export file",
        "dialog.selectExportCsvFile": "Select CSV export file",
        "dialog.inputName": "Please enter a name",
        "dialog.newProject": "New Project",
        "dialog.renameProject": "Rename Project",
        "dialog.newCategory": "New Category Group",
        "dialog.renameCategory": "Rename Category Group",
        "warn.selectProjectRename": "Select a specific project before renaming.",
        "warn.selectProjectDelete": "Select a specific project before deleting.",
        "warn.selectCategoryRename": "Select a category group before renaming.",
        "warn.selectCategoryDelete": "Select a category group before deleting.",
        "notify.categoryDeleted": "Category group deleted: ",
        "tab.bomView": "BOM View",
        "tab.diff": "Diff Analysis",
        "search.placeholder": "Global search (part/ref/spec/note)",
        "common.clear": "Clear",
        "common.ok": "OK",
        "common.cancel": "Cancel",
        "diff.title": "Diff Analysis",
        "diff.todo": "Version diff, alternates suggestion, and cost trend will be added later.",
        "diff.search.placeholder": "Search diffs (key part/field/value)",
        "diff.group.by": "Group By",
        "diff.group.project": "By Project",
        "diff.group.package": "By Package",
        "diff.group.brand": "By Brand",
        "diff.result.count": "Diff Items",
        "diff.changed.fields": "Changed Fields",
        "diff.noresult": "No diff items found",
        "diff.view.list": "Diff List",
        "diff.view.bar": "Bar Chart",
        "diff.view.pie": "Pie Chart",
        "diff.health.score": "Inventory Health",
        "diff.health.total": "Total Rows",
        "diff.health.unique": "Unique Parts",
        "diff.health.lowqty": "Low Stock",
        "diff.health.missing": "Missing Key Fields",
        "diff.health.duplicate": "Duplicate Parts",
        "diff.suggestions": "Suggestions",
        "debug.console": "Debug Console",
        "debug.clear": "Clear",
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.lang.zh": "Chinese",
        "settings.lang.en": "English",
        "projects.all": "All Projects",
        "common.new": "New",
        "common.rename": "Rename",
        "common.delete": "Delete",
        "common.reset": "Reset",
        "sidebar.import": "Import",
        "sidebar.import.lcsc": "LCSC Import (XLS)",
        "sidebar.import.sheet": "Import XLS/XLSX",
        "sidebar.import.ocr": "OCR Import (Later)",
        "sidebar.import.ocr.todo": "OCR flow is not connected yet.",
        "sidebar.export": "Export",
        "sidebar.export.csv": "Export CSV",
        "sidebar.export.todo": "CSV export is triggered.",
        "sidebar.projects": "Projects",
        "sidebar.categories": "Categories",
        "sidebar.height": "Height",
        "sidebar.height.auto": "Auto Height",
        "sidebar.height.custom": "Custom Height",
        "tree.brand": "Brand",
        "tree.package": "Package",
        "tree.type": "Type",
        "tree.type.clear": "Clear Type Filter",
        "type.resistor": "Resistor",
        "type.capacitor": "Capacitor",
        "type.inductor": "Inductor",
        "type.ic": "IC/Chip",
        "type.connector": "Connector",
        "type.switch": "Switch",
        "type.power": "Power",
        "type.other": "Other",
        "bom.column.config": "Column Settings",
        "bom.column.insert.left": "Insert Left",
        "bom.column.insert.right": "Insert Right",
        "bom.column.fields": "Fields",
        "bom.column.width": "Custom Width",
        "bom.column.ratio": "Ratio"
    })

    function tx(key) {
        const table = uiLanguage === "en-US" ? textEn : textZh
        return table[key] !== undefined ? table[key] : key
    }

    function escapeHtml(text) {
        return String(text)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;")
    }

    function levelColor(level) {
        const key = String(level).toUpperCase()
        if (key === "ERROR") return "#EF4444"
        if (key === "WARNING") return "#F59E0B"
        return darkTheme ? "#93C5FD" : "#2563EB"
    }

    Settings {
        id: uiSettings
        category: "UiGeneral"
        property string language: "zh-CN"
    }

    function rebuildDebugLogText() {
        const lines = []
        for (let index = 0; index < debugEntries.length; ++index) {
            const entry = debugEntries[index]
            const visible = (entry.level === "INFO" && showInfoLogs)
                || (entry.level === "WARNING" && showWarningLogs)
                || (entry.level === "ERROR" && showErrorLogs)
            if (visible) {
                const color = levelColor(entry.level)
                const content = "[" + entry.time + "] [" + entry.level + "] [app] " + entry.message
                lines.push("<span style='color:" + color + "'>" + escapeHtml(content) + "</span>")
            }
        }
        debugLogText = lines.join("<br/>")
    }

    function addDebugEntry(time, level, message) {
        const normalized = String(level).toUpperCase()
        const safeLevel = (normalized === "WARNING" || normalized === "ERROR") ? normalized : "INFO"
        const next = debugEntries.slice()
        next.push({
            "time": time,
            "level": safeLevel,
            "message": String(message)
        })
        if (next.length > debugLogLimit) {
            next.splice(0, next.length - debugLogLimit)
        }
        debugEntries = next
        rebuildDebugLogText()
    }

    function appendDebugLog(level, message) {
        if (message === undefined) {
            message = level
            level = "INFO"
        }
        const normalized = String(level).toUpperCase()
        if (normalized === "WARNING") {
            root.appCtx.logWarning(String(message))
        } else if (normalized === "ERROR") {
            root.appCtx.logError(String(message))
        } else {
            root.appCtx.logInfo(String(message))
        }
    }

    function logInfo(message) { root.appCtx.logInfo(String(message)) }
    function logWarning(message) { root.appCtx.logWarning(String(message)) }
    function logError(message) { root.appCtx.logError(String(message)) }
    function refreshDiffAnalysis() {
        diffItems = root.appCtx.bomModel.analyzeDifferences(diffSearchText, diffGroupMode)
        diffStats = root.appCtx.bomModel.buildAnalytics(diffGroupMode)
    }

    onShowInfoLogsChanged: rebuildDebugLogText()
    onShowWarningLogsChanged: rebuildDebugLogText()
    onShowErrorLogsChanged: rebuildDebugLogText()
    onDebugEntriesChanged: rebuildDebugLogText()
    onUiLanguageChanged: uiSettings.language = uiLanguage
    onDebugPanelVisibleChanged: {
        if (debugPanelVisible) {
            logInfo("Debug panel opened")
            debugPopup.open()
        } else {
            logInfo("Debug panel closed")
            debugPopup.close()
        }
    }

    flags: root.pinnedTopMost
        ? (Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint | Qt.WindowStaysOnTopHint)
        : (Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint)

    property bool darkTheme: root.appCtx.theme.currentThemeName === "Dark"
    property color bgColor: darkTheme ? "#141622" : "#F8FAFC"
    property color cardColor: darkTheme ? "#1C2030" : "#FFFFFF"
    property color borderColor: darkTheme ? "#2F3447" : "#D9E2EC"
    property color textColor: darkTheme ? "#E6E1E8" : "#0F172A"
    property color mutedTextColor: darkTheme ? "#9A8FA2" : "#5F6B73"
    property color primaryColor: darkTheme ? "#B08FA8" : "#C9778F"
    property color subtleColor: darkTheme ? "#22283A" : "#F1F5F9"

    function themeColorsObj() {
        return {
            "card": root.cardColor,
            "border": root.borderColor,
            "text": root.textColor,
            "muted": root.mutedTextColor,
            "primary": root.primaryColor,
            "subtle": root.subtleColor
        }
    }

    color: bgColor
    palette.window: bgColor
    palette.windowText: textColor
    palette.base: cardColor
    palette.alternateBase: subtleColor
    palette.text: textColor
    palette.button: subtleColor
    palette.buttonText: textColor
    palette.highlight: primaryColor
    palette.highlightedText: darkTheme ? "#141622" : "#FFFFFF"
    palette.placeholderText: mutedTextColor
    palette.mid: borderColor

    DialogHost {
        id: dialogHost
        anchors.fill: parent
        app: root.appCtx
        themeColors: root.themeColorsObj()
        textColor: root.textColor
        mutedTextColor: root.mutedTextColor
        primaryColor: root.primaryColor
        subtleColor: root.subtleColor
        cardColor: root.cardColor
        borderColor: root.borderColor
        uiLanguage: root.uiLanguage
        textMap: root.textMap
        onLanguageApplied: function(language) {
            root.uiLanguage = language
            root.logInfo("UI language changed: " + root.uiLanguage)
        }
        onInputAccepted: function(mode, value) {
            if (mode === "newProject") {
                root.logInfo("New project: " + value)
                root.appCtx.projects.addProject(value)
            }
            if (mode === "renameProject") {
                root.logInfo("Rename project index " + root.renameProjectIndex + " -> " + value)
                root.appCtx.projects.renameProject(root.renameProjectIndex, value)
            }
            if (mode === "newCategory") {
                root.logInfo("New category: " + value)
                root.appCtx.categories.addCategory(value)
            }
            if (mode === "renameCategory") {
                root.logInfo("Rename category index " + root.renameCategoryIndex + " -> " + value)
                root.appCtx.categories.renameCategory(root.renameCategoryIndex, value)
            }
        }
    }

    Popup {
        id: debugPopup
        width: Math.min(root.width - 40, 920)
        height: Math.min(root.height - 60, 420)
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        modal: false
        focus: true
        padding: 10
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: root.debugPanelVisible = false

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
                    text: root.tx("debug.console")
                    color: root.textColor
                    elide: Text.ElideRight
                    font.bold: true
                }

                CheckBox {
                    id: popupInfoLevelCheck
                    text: "Info"
                    checked: root.showInfoLogs
                    onToggled: root.showInfoLogs = checked
                }

                CheckBox {
                    id: popupWarningLevelCheck
                    text: "Warning"
                    checked: root.showWarningLogs
                    onToggled: root.showWarningLogs = checked
                }

                CheckBox {
                    id: popupErrorLevelCheck
                    text: "Error"
                    checked: root.showErrorLogs
                    onToggled: root.showErrorLogs = checked
                }

                AppButton {
                    themeColors: root.themeColorsObj()
                    text: root.tx("debug.clear")
                    implicitHeight: 28
                    implicitWidth: 72
                    onClicked: {
                        root.debugEntries = []
                        root.debugLogText = ""
                        root.logInfo("Debug logs cleared")
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextArea {
                    id: debugTextArea
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

                    onTextChanged: {
                        cursorPosition = length
                    }
                }
            }
        }
    }

    Connections {
        target: root.appCtx.logRelay
        function onEntryAdded(time, level, message) {
            root.addDebugEntry(time, level, message)
        }
    }

    Connections {
        target: root.appCtx.theme
        function onCurrentIndexChanged() {
            root.logInfo("Theme changed: " + root.appCtx.theme.currentThemeName)
        }
    }

    Connections {
        target: root.appCtx.projects
        function onSelectedProjectChanged() {
            root.logInfo("Selected project changed: " + root.appCtx.projects.selectedProject)
        }
    }

    Connections {
        target: root.appCtx.bomModel
        function onModelReset() {
            if (root.activeTabIndex === 1) {
                root.refreshDiffAnalysis()
            }
        }
        function onHeaderDataChanged() {
            if (root.activeTabIndex === 1) {
                root.refreshDiffAnalysis()
            }
        }
    }

    // 1ST REC
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        SidebarPane {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            app: root.appCtx
            pinnedTopMost: root.pinnedTopMost
            themeColors: root.themeColorsObj()
            uiLanguage: root.uiLanguage
            textMap: root.textMap
            onTogglePinned: {
                root.pinnedTopMost = !root.pinnedTopMost
                root.logInfo("Toggle pin top-most: " + root.pinnedTopMost)
            }
            onOpenSettings: {
                dialogHost.openSettingsDialog()
            }
            onToggleDebugPanel: {
                root.debugPanelVisible = !root.debugPanelVisible
            }
            onRequestImport: {
                root.logInfo("Request import dialog")
                dialogHost.openProjectImportDialog()
            }
            onRequestExport: {
                root.logInfo("Request CSV export dialog")
                dialogHost.openExportDialog()
            }
            onRequestNewProject: {
                root.logInfo("Request new project dialog")
                dialogHost.openInputDialog("newProject", root.tx("dialog.newProject"), "")
            }
            onRequestRenameProject: function(index, currentName) {
                if (index <= 0 || currentName === "All Projects") {
                    root.logWarning("Rename project rejected: no specific project selected")
                    root.appCtx.notify(root.tx("warn.selectProjectRename"))
                    return
                }
                root.logInfo("Request rename project dialog: index " + index + ", name " + currentName)
                root.renameProjectIndex = index
                dialogHost.openInputDialog("renameProject", root.tx("dialog.renameProject"), currentName)
            }
            onRequestDeleteProject: function(index, currentName) {
                if (index <= 0 || currentName === "All Projects") {
                    root.logWarning("Delete project rejected: no specific project selected")
                    root.appCtx.notify(root.tx("warn.selectProjectDelete"))
                    return
                }
                root.logInfo("Delete project request: index " + index + ", name " + currentName)
                if (!root.appCtx.deleteProject(index)) {
                    root.logError("Delete project failed: " + currentName)
                }
            }
            onRequestNewCategory: {
                root.logInfo("Request new category dialog")
                dialogHost.openInputDialog("newCategory", root.tx("dialog.newCategory"), "")
            }
            onRequestRenameCategory: function(index, currentName) {
                if (index < 0) {
                    root.logWarning("Rename category rejected: no category selected")
                    root.appCtx.notify(root.tx("warn.selectCategoryRename"))
                    return
                }
                root.logInfo("Request rename category dialog: index " + index + ", name " + currentName)
                root.renameCategoryIndex = index
                dialogHost.openInputDialog("renameCategory", root.tx("dialog.renameCategory"), currentName)
            }
            onRequestDeleteCategory: function(index, currentName) {
                if (index < 0) {
                    root.logWarning("Delete category rejected: no category selected")
                    root.appCtx.notify(root.tx("warn.selectCategoryDelete"))
                    return
                }
                root.logInfo("Delete category request: index " + index + ", name " + currentName)
                if (!root.appCtx.categories.removeCategory(index)) {
                    root.logError("Delete category failed: " + currentName)
                } else {
                    root.appCtx.notify(root.tx("notify.categoryDeleted") + currentName)
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                TopBar {
                    id: topBar
                    anchors.fill: parent
                    themeColors: root.themeColorsObj()
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                    primaryColor: root.primaryColor
                    textMap: root.textMap
                    currentIndex: root.activeTabIndex
                    searchText: root.activeTabIndex === 0 ? root.bomSearchText : root.diffSearchText
                    onToggleDebugRequested: root.debugPanelVisible = !root.debugPanelVisible
                    onTabChanged: function(index) {
                        root.syncingTopSearch = true
                        root.activeTabIndex = index
                        root.syncingTopSearch = false
                        root.logInfo("View switched: " + (index === 0 ? "BOM" : "Diff"))
                        if (index === 1) {
                            root.refreshDiffAnalysis()
                        }
                    }
                    onSearchEdited: function(text) {
                        if (root.syncingTopSearch) {
                            return
                        }
                        if (root.activeTabIndex === 0) {
                            root.bomSearchText = text
                            root.appCtx.bomModel.setFilterKeyword(text)
                            root.logInfo("Global BOM search changed: \"" + text + "\"")
                        } else {
                            root.diffSearchText = text
                            root.refreshDiffAnalysis()
                            root.logInfo("Diff search changed: \"" + text + "\"")
                        }
                    }
                    onClearRequested: {
                        if (root.activeTabIndex === 0) {
                            root.bomSearchText = ""
                            root.appCtx.bomModel.setFilterKeyword("")
                            root.logInfo("Global BOM search cleared")
                        } else {
                            root.diffSearchText = ""
                            root.refreshDiffAnalysis()
                            root.logInfo("Diff search cleared")
                        }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.activeTabIndex

                BomPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    app: root.appCtx
                    themeColors: root.themeColorsObj()
                    uiLanguage: root.uiLanguage
                    textMap: root.textMap
                    onDebugLog: function(level, message) {
                        root.appendDebugLog(level, "BOM: " + message)
                    }
                }

                DiffPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    themeColors: root.themeColorsObj()
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                    primaryColor: root.primaryColor
                    subtleColor: root.subtleColor
                    darkTheme: root.darkTheme
                    textMap: root.textMap
                    groupMode: root.diffGroupMode
                    viewMode: root.diffViewMode
                    diffItems: root.diffItems
                    diffStats: root.diffStats
                    onGroupModeSelected: function(value) {
                        root.diffGroupMode = value
                        root.refreshDiffAnalysis()
                    }
                    onViewModeSelected: function(value) {
                        root.diffViewMode = value
                    }
                }
            }
        }
    }
}
