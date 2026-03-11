pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var app
    required property var themeColors
    required property var textMap
    property bool collapsed: false
    property int selectedCategoryIndex: -1
    property string selectedCategoryName: ""

    signal requestNewCategory()
    signal requestRenameCategory(int index, string currentName)
    signal requestDeleteCategory(int index, string currentName)

    function txSafe(key, fallback) {
        if (root.textMap && root.textMap[key] !== undefined) {
            const value = root.textMap[key]
            if (value !== undefined && value !== key) {
                return value
            }
        }
        return fallback
    }

    implicitWidth: moduleCard.implicitWidth
    implicitHeight: moduleCard.implicitHeight

    SidebarModuleCard {
        id: moduleCard
        width: parent ? parent.width : 280
        title: root.txSafe("sidebar.categories", "Categories")
        themeColors: root.themeColors
        darkTheme: root.app.theme.currentThemeName === "Dark"
        collapsed: root.collapsed
        normalHeight: 190
        onCollapsedChanged: root.collapsed = collapsed

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            ListView {
                id: categoryGroupList
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                    contentItem: Text {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        text: categoryDelegate.text
                        color: root.themeColors.text
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    background: Rectangle {
                        color: root.selectedCategoryIndex === categoryDelegate.index ? Qt.rgba(root.themeColors.primary.r, root.themeColors.primary.g, root.themeColors.primary.b, 0.14) : "transparent"
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.selectedCategoryIndex === categoryDelegate.index ? 5 : 2
                            height: parent.height * 0.72
                            radius: 2
                            color: root.selectedCategoryIndex === categoryDelegate.index ? root.themeColors.primary : "transparent"
                        }
                    }
                    onClicked: {
                        root.selectedCategoryIndex = categoryDelegate.index
                        root.selectedCategoryName = text
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                AppButton { themeColors: root.themeColors; text: root.txSafe("common.new", "New"); Layout.fillWidth: true; onClicked: root.requestNewCategory() }
                AppButton { themeColors: root.themeColors; text: root.txSafe("common.rename", "Rename"); Layout.fillWidth: true; onClicked: root.requestRenameCategory(root.selectedCategoryIndex, root.selectedCategoryName) }
                AppButton { themeColors: root.themeColors; text: root.txSafe("common.delete", "Delete"); Layout.fillWidth: true; onClicked: root.requestDeleteCategory(root.selectedCategoryIndex, root.selectedCategoryName) }
            }
        }
    }
}
