pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

Item {
    id: root
    required property var app
    required property var themeColors
    required property bool pinnedTopMost
    required property string uiLanguage
    required property var tx

    signal togglePinned()
    signal openSettings()
    signal requestImport()
    signal requestNewProject()
    signal requestRenameProject(int index, string currentName)
    signal requestDeleteProject(int index, string currentName)
    signal requestNewCategory()
    signal requestRenameCategory(int index, string currentName)
    signal requestDeleteCategory(int index, string currentName)
    signal toggleDebugPanel()

    property int selectedCategoryIndex: -1
    property string selectedCategoryName: ""
    property var brandTreeGroups: []
    property var brandTreeChildren: ({})
    property var brandTreeExpanded: ({})
    property var packageTreeGroups: []
    property var packageTreeChildren: ({})
    property var packageTreeExpanded: ({})
    property var typeTreeGroups: []
    property var typeTreeChildren: ({})
    property var typeTreeExpanded: ({})

    function txSafe(key, fallback) {
        if (root.tx) {
            const value = root.tx(key)
            if (value !== key) {
                return value
            }
        }
        return fallback
    }

    function displayProjectName(name) {
        return name === "All Projects" ? txSafe("projects.all", "All Projects") : name
    }

    function primaryTint(alpha) {
        return Qt.rgba(root.themeColors.primary.r, root.themeColors.primary.g, root.themeColors.primary.b, alpha)
    }

    function majorKind(text) {
        const value = String(text).toLowerCase()
        if (value.includes("resistor")) return txSafe("type.resistor", "Resistor")
        if (value.includes("capacitor") || value.includes("cap")) return txSafe("type.capacitor", "Capacitor")
        if (value.includes("inductor")) return txSafe("type.inductor", "Inductor")
        if (value.includes("ic") || value.includes("mcu")) return txSafe("type.ic", "IC/Chip")
        if (value.includes("connector")) return txSafe("type.connector", "Connector")
        if (value.includes("switch")) return txSafe("type.switch", "Switch")
        if (value.includes("power") || value.includes("regulator") || value.includes("dc-dc")) return txSafe("type.power", "Power")
        return txSafe("type.other", "Other")
    }

    function buildTreeByInitial(values) {
        const groups = []
        const childrenMap = {}
        const expandedMap = {}
        for (let i = 0; i < values.length; ++i) {
            const value = String(values[i]).trim()
            if (value.length === 0) continue
            const key = value[0].toUpperCase()
            if (!childrenMap[key]) {
                childrenMap[key] = []
                groups.push(key)
                expandedMap[key] = true
            }
            childrenMap[key].push(value)
        }
        groups.sort()
        return { "groups": groups, "children": childrenMap, "expanded": expandedMap }
    }

    function buildTypeTree(values) {
        const groups = []
        const childrenMap = {}
        const expandedMap = {}
        for (let i = 0; i < values.length; ++i) {
            const value = String(values[i]).trim()
            if (value.length === 0) continue
            const group = majorKind(value)
            if (!childrenMap[group]) {
                childrenMap[group] = []
                groups.push(group)
                expandedMap[group] = true
            }
            childrenMap[group].push(value)
        }
        return { "groups": groups, "children": childrenMap, "expanded": expandedMap }
    }

    function refreshCategoryBuckets() {
        const brandValues = root.app.bomModel.distinctValuesByHeaderAliases(["brand"], 2)
        const packageValues = root.app.bomModel.distinctValuesByHeaderAliases(["package"], 4)
        const typeValues = root.app.bomModel.distinctValuesByHeaderAliases(["name", "description"], 5)

        const brandTree = buildTreeByInitial(brandValues)
        brandTreeGroups = brandTree.groups
        brandTreeChildren = brandTree.children
        brandTreeExpanded = brandTree.expanded

        const packageTree = buildTreeByInitial(packageValues)
        packageTreeGroups = packageTree.groups
        packageTreeChildren = packageTree.children
        packageTreeExpanded = packageTree.expanded

        const typeTree = buildTypeTree(typeValues)
        typeTreeGroups = typeTree.groups
        typeTreeChildren = typeTree.children
        typeTreeExpanded = typeTree.expanded
    }

    FontLoader {
        id: audioWide
        source: "qrc:/assets/Audiowide-Regular.ttf"
    }

    Settings {
        id: sidebarSettings
        category: "Sidebar"
        property bool importCollapsed: false
        property bool exportCollapsed: false
        property bool projectsCollapsed: false
        property bool categoriesCollapsed: false
        property bool categoriesAutoHeight: true
        property int categoriesCustomHeight: 430
    }

    Component.onCompleted: refreshCategoryBuckets()

    Connections {
        target: root.app.bomModel
        function onModelReset() { root.refreshCategoryBuckets() }
        function onHeaderDataChanged() { root.refreshCategoryBuckets() }
    }

    component TreeSection: Column {
        id: treeSection
        required property string title
        required property var groups
        required property var childrenMap
        required property var expandedMap
        required property color textColor
        required property color mutedColor
        required property color subtleColor
        required property color borderColor
        required property color activeColor
        property string activeValue: ""
        property bool clickableLeaves: false
        signal toggleGroup(string groupKey)
        signal leafClicked(string value)
        width: parent ? parent.width : 280
        spacing: 2

        Label { text: treeSection.title; color: treeSection.mutedColor; font.pixelSize: 12; font.bold: true }

        Repeater {
            model: treeSection.groups
            delegate: Column {
                id: groupNode
                required property string modelData
                width: treeSection.width
                spacing: 1

                Rectangle {
                    width: parent.width
                    height: 28
                    radius: 8
                    color: treeSection.subtleColor
                    border.color: treeSection.borderColor
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Label { text: treeSection.expandedMap[groupNode.modelData] ? "▼" : "▶"; color: treeSection.mutedColor }
                        Label { Layout.fillWidth: true; text: groupNode.modelData; color: treeSection.textColor; font.bold: true; elide: Text.ElideRight }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            treeSection.toggleGroup(groupNode.modelData)
                        }
                    }
                }

                Column {
                    width: parent.width
                    visible: !!treeSection.expandedMap[groupNode.modelData]
                    spacing: 0
                    Repeater {
                        model: treeSection.childrenMap[groupNode.modelData] ? treeSection.childrenMap[groupNode.modelData] : []
                        delegate: Rectangle {
                            id: leafNode
                            required property string modelData
                            width: treeSection.width
                            height: 24
                            color: "transparent"
                            Rectangle { x: 10; y: 0; width: 1; height: parent.height; color: treeSection.borderColor }
                            Rectangle { x: 10; y: parent.height / 2; width: 12; height: 1; color: treeSection.borderColor }
                            Label {
                                anchors.left: parent.left
                                anchors.leftMargin: 28
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 32
                                text: leafNode.modelData
                                color: treeSection.activeValue === leafNode.modelData ? treeSection.activeColor : treeSection.textColor
                                elide: Text.ElideRight
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: treeSection.clickableLeaves
                                onClicked: treeSection.leafClicked(leafNode.modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // Title bar
    Rectangle {
        id: headerCard
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        //anchors.topMargin: 6
        height: 95
        radius: 12
        color: root.themeColors.card
        border.color: root.themeColors.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6

            Image {
                source: root.app.theme.currentThemeName === "Dark" ? "qrc:/assets/Github-dark.png" : "qrc:/assets/Github-light.png"
                Layout.preferredWidth: 90
                Layout.preferredHeight: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://github.com/890mn/Link2BOM") }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 20
                    Label { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "Link2BOM"; font.family: audioWide.name; font.pixelSize: 28; font.bold: true; color: root.themeColors.primary }
                    Image { visible: root.pinnedTopMost; source: root.app.theme.currentThemeName === "Dark" ? "qrc:/assets/pin-dark.png" : "qrc:/assets/pin-light.png"; anchors.right: parent.right; anchors.top: parent.top; anchors.topMargin: 4; width: 16; height: 16; fillMode: Image.PreserveAspectFit }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.togglePinned() }
                }

                Label {
                    text: "Settings / Themes / V1"
                    color: root.themeColors.muted
                    font.pixelSize: 16
                    font.family: audioWide.name
                    MouseArea { anchors.fill: parent; onPressAndHold: root.toggleDebugPanel() }
                }

                RowLayout {
                    spacing: 8
                    Layout.topMargin: -2

                    Item {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: root.app.theme.currentThemeName === "Dark"
                                ? "qrc:/assets/setting-dark.png"
                                : "qrc:/assets/setting-light.png"
                            smooth: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.openSettings()
                        }
                    }

                    //Item { Layout.preferredWidth: 57 }

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            id: themeDot
                            required property int index
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            radius: 8
                            color: root.app.theme.currentIndex === index ? root.themeColors.primary : "transparent"
                            border.color: root.themeColors.primary
                            MouseArea { anchors.fill: parent; onClicked: root.app.theme.currentIndex = themeDot.index }
                        }
                    }
                }
            }
        }
    }

    // left all
    Item {
        id: modulesArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerCard.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 8
        //anchors.bottomMargin: 4

        Flickable {
            id: modulesFlick
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: modulesColumn.childrenRect.height + 12
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: modulesColumn
                width: modulesFlick.width
                spacing: 10

                SidebarModuleCard {
                    width: modulesColumn.width
                    title: root.txSafe("sidebar.import", "Import")
                    themeColors: root.themeColors
                    darkTheme: root.app.theme.currentThemeName === "Dark"
                    collapsed: sidebarSettings.importCollapsed
                    normalHeight: 176
                    onCollapsedChanged: sidebarSettings.importCollapsed = collapsed
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8
                        AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.import.lcsc", "LCSC Import (XLS)"); Layout.fillWidth: true; onClicked: root.requestImport() }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.import.sheet", "Import XLS/XLSX"); Layout.fillWidth: true; onClicked: root.requestImport() }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.import.ocr", "OCR Import (Later)"); Layout.fillWidth: true; onClicked: root.app.notify(root.txSafe("sidebar.import.ocr.todo", "OCR flow is not connected yet.")) }
                    }
                }

            SidebarModuleCard {
                width: modulesColumn.width
                title: root.txSafe("sidebar.export", "Export")
                themeColors: root.themeColors
                darkTheme: root.app.theme.currentThemeName === "Dark"
                collapsed: sidebarSettings.exportCollapsed
                normalHeight: 96
                onCollapsedChanged: sidebarSettings.exportCollapsed = collapsed
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.export.csv", "Export CSV"); Layout.fillWidth: true; onClicked: root.app.notify(root.txSafe("sidebar.export.todo", "CSV export is triggered.")) }
                }
            }

            SidebarModuleCard {
                width: modulesColumn.width
                title: root.txSafe("sidebar.projects", "Projects")
                themeColors: root.themeColors
                darkTheme: root.app.theme.currentThemeName === "Dark"
                collapsed: sidebarSettings.projectsCollapsed
                normalHeight: 260
                onCollapsedChanged: sidebarSettings.projectsCollapsed = collapsed
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    ListView {
                        id: projectList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.app.projects.model
                        delegate: ItemDelegate {
                            id: projectDelegate
                            required property int index
                            width: ListView.view.width
                            leftPadding: 14
                            rightPadding: 8
                            property string projectName: root.app.projects.model.data(root.app.projects.model.index(projectDelegate.index, 0), Qt.DisplayRole) ?? ""
                            text: root.displayProjectName(projectName)
                            contentItem: Text { anchors.fill: parent; anchors.leftMargin: 18; text: projectDelegate.text; color: root.themeColors.text; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                            background: Rectangle {
                                color: root.app.projects.selectedProject === projectDelegate.projectName ? root.primaryTint(0.14) : "transparent"
                                Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: root.app.projects.selectedProject === projectDelegate.projectName ? 5 : 2; height: parent.height * 0.72; radius: 2; color: root.app.projects.selectedProject === projectDelegate.projectName ? root.themeColors.primary : "transparent" }
                            }
                            onClicked: {
                                projectList.currentIndex = projectDelegate.index
                                root.app.projects.selectedProject = projectDelegate.projectName
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.new", "New"); Layout.fillWidth: true; onClicked: root.requestNewProject() }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.rename", "Rename"); Layout.fillWidth: true; onClicked: root.requestRenameProject(projectList.currentIndex, root.app.projects.selectedProject) }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.delete", "Delete"); Layout.fillWidth: true; onClicked: root.requestDeleteProject(projectList.currentIndex, root.app.projects.selectedProject) }
                    }
                }
            }

            SidebarModuleCard {
                id: categoriesCard
                width: modulesColumn.width
                title: root.txSafe("sidebar.categories", "Categories")
                themeColors: root.themeColors
                darkTheme: root.app.theme.currentThemeName === "Dark"
                collapsed: sidebarSettings.categoriesCollapsed
                normalHeight: sidebarSettings.categoriesAutoHeight ? Math.max(430, categoriesContent.implicitHeight + 86) : sidebarSettings.categoriesCustomHeight
                onCollapsedChanged: sidebarSettings.categoriesCollapsed = collapsed
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.height.auto", "Auto Height"); Layout.fillWidth: true; accent: sidebarSettings.categoriesAutoHeight; onClicked: sidebarSettings.categoriesAutoHeight = true }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("sidebar.height.custom", "Custom Height"); Layout.fillWidth: true; accent: !sidebarSettings.categoriesAutoHeight; onClicked: sidebarSettings.categoriesAutoHeight = false }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: !sidebarSettings.categoriesAutoHeight
                        Label { text: root.txSafe("sidebar.height", "Height") + ": " + sidebarSettings.categoriesCustomHeight; color: root.themeColors.text; font.pixelSize: 12 }
                        Slider {
                            Layout.fillWidth: true
                            from: 320; to: 860; stepSize: 10
                            value: sidebarSettings.categoriesCustomHeight
                            onMoved: sidebarSettings.categoriesCustomHeight = Math.round(value)
                            onValueChanged: if (pressed) sidebarSettings.categoriesCustomHeight = Math.round(value)
                        }
                    }

                    ListView {
                        id: categoryGroupList
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        model: root.app.categories.model
                        clip: true
                        spacing: 2
                        currentIndex: root.selectedCategoryIndex
                        delegate: ItemDelegate {
                            id: categoryDelegate
                            required property int index
                            width: ListView.view.width
                            leftPadding: 14
                            rightPadding: 8
                            text: root.app.categories.model.data(root.app.categories.model.index(categoryDelegate.index, 0), Qt.DisplayRole) ?? ""
                            contentItem: Text { anchors.fill: parent; anchors.leftMargin: 18; text: categoryDelegate.text; color: root.themeColors.text; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                            background: Rectangle {
                                color: root.selectedCategoryIndex === categoryDelegate.index ? root.primaryTint(0.14) : "transparent"
                                Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: root.selectedCategoryIndex === categoryDelegate.index ? 5 : 2; height: parent.height * 0.72; radius: 2; color: root.selectedCategoryIndex === categoryDelegate.index ? root.themeColors.primary : "transparent" }
                            }
                            onClicked: { root.selectedCategoryIndex = categoryDelegate.index; root.selectedCategoryName = text }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.new", "New"); Layout.fillWidth: true; onClicked: root.requestNewCategory() }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.rename", "Rename"); Layout.fillWidth: true; onClicked: root.requestRenameCategory(root.selectedCategoryIndex, root.selectedCategoryName) }
                        AppButton { themeColors: root.themeColors; text: root.txSafe("common.delete", "Delete"); Layout.fillWidth: true; onClicked: root.requestDeleteCategory(root.selectedCategoryIndex, root.selectedCategoryName) }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        Column {
                            id: categoriesContent
                            width: categoriesCard.width - 36
                            spacing: 8
                            TreeSection {
                                title: root.txSafe("tree.brand", "Brand")
                                groups: root.brandTreeGroups
                                childrenMap: root.brandTreeChildren
                                expandedMap: root.brandTreeExpanded
                                textColor: root.themeColors.text
                                mutedColor: root.themeColors.muted
                                subtleColor: root.themeColors.subtle
                                borderColor: root.themeColors.border
                                activeColor: root.themeColors.primary
                                onToggleGroup: function(groupKey) {
                                    const next = Object.assign({}, root.brandTreeExpanded)
                                    next[groupKey] = !root.brandTreeExpanded[groupKey]
                                    root.brandTreeExpanded = next
                                }
                            }
                            TreeSection {
                                title: root.txSafe("tree.package", "Package")
                                groups: root.packageTreeGroups
                                childrenMap: root.packageTreeChildren
                                expandedMap: root.packageTreeExpanded
                                textColor: root.themeColors.text
                                mutedColor: root.themeColors.muted
                                subtleColor: root.themeColors.subtle
                                borderColor: root.themeColors.border
                                activeColor: root.themeColors.primary
                                onToggleGroup: function(groupKey) {
                                    const next = Object.assign({}, root.packageTreeExpanded)
                                    next[groupKey] = !root.packageTreeExpanded[groupKey]
                                    root.packageTreeExpanded = next
                                }
                            }
                            TreeSection {
                                title: root.txSafe("tree.type", "Type")
                                groups: root.typeTreeGroups
                                childrenMap: root.typeTreeChildren
                                expandedMap: root.typeTreeExpanded
                                textColor: root.themeColors.text
                                mutedColor: root.themeColors.muted
                                subtleColor: root.themeColors.subtle
                                borderColor: root.themeColors.border
                                activeColor: root.themeColors.primary
                                activeValue: root.app.bomModel.typeFilter
                                clickableLeaves: true
                                onToggleGroup: function(groupKey) {
                                    const next = Object.assign({}, root.typeTreeExpanded)
                                    next[groupKey] = !root.typeTreeExpanded[groupKey]
                                    root.typeTreeExpanded = next
                                }
                                onLeafClicked: function(value) { root.app.bomModel.setTypeFilter(value) }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        AppButton { themeColors: root.themeColors; text: root.txSafe("tree.type.clear", "Clear Type Filter"); Layout.fillWidth: true; onClicked: root.app.bomModel.clearTypeFilter() }
                    }
                }
            }

                Item { width: 1; height: 12 }
            }
        }
    }
}
