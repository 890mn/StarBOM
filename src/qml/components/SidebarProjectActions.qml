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

    signal requestNewProject()
    signal requestRenameProject(int index, string currentName)
    signal requestDeleteProject(int index, string currentName)

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
        title: root.txSafe("sidebar.projects", "Projects")
        themeColors: root.themeColors
        darkTheme: root.app.theme.currentThemeName === "Dark"
        collapsed: root.collapsed
        normalHeight: 260
        onCollapsedChanged: root.collapsed = collapsed

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
                    text: projectName === "All Projects" ? root.txSafe("projects.all", "All Projects") : projectName
                    contentItem: Text {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        text: projectDelegate.text
                        color: root.themeColors.text
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    background: Rectangle {
                        color: root.app.projects.selectedProject === projectDelegate.projectName ? Qt.rgba(root.themeColors.primary.r, root.themeColors.primary.g, root.themeColors.primary.b, 0.14) : "transparent"
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.app.projects.selectedProject === projectDelegate.projectName ? 5 : 2
                            height: parent.height * 0.72
                            radius: 2
                            color: root.app.projects.selectedProject === projectDelegate.projectName ? root.themeColors.primary : "transparent"
                        }
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
}
