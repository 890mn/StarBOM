pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var themeColors
    required property color textColor
    required property color mutedTextColor
    required property color primaryColor
    required property var textMap
    property int currentIndex: 0
    property string searchText: ""
    signal tabChanged(int index)
    signal searchEdited(string text)
    signal clearRequested()
    signal toggleDebugRequested()

    function txSafe(key, fallback) {
        if (root.textMap && root.textMap[key] !== undefined) {
            return root.textMap[key]
        }
        return fallback
    }

    onSearchTextChanged: {
        if (globalSearch.text !== root.searchText) {
            globalSearch.text = root.searchText
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onLongPressed: root.toggleDebugRequested()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 290
            Layout.minimumWidth: 290
            Layout.maximumWidth: 290
            Layout.preferredHeight: 42
            radius: 12
            color: root.themeColors.card
            border.color: root.themeColors.border

            TabBar {
                id: tabs
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.bottomMargin: -1
                spacing: 6
                padding: 0
                currentIndex: root.currentIndex
                background: Rectangle {
                    radius: 10
                    color: "transparent"
                }
                onCurrentIndexChanged: root.tabChanged(currentIndex)

                TabButton {
                    text: root.txSafe("tab.bomView", "BOM View")
                    height: tabs.height
                    implicitWidth: 136
                    implicitHeight: 36
                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 0
                    rightPadding: 0
                    background: Rectangle {
                        anchors.fill: parent
                        radius: 10
                        antialiasing: true
                        color: tabs.currentIndex === 0 ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.18) : "transparent"
                        border.color: tabs.currentIndex === 0 ? root.primaryColor : "transparent"
                        border.width: tabs.currentIndex === 0 ? 1 : 0
                    }
                    contentItem: Text {
                        text: root.txSafe("tab.bomView", "BOM View")
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.bold: tabs.currentIndex === 0
                    }
                }

                TabButton {
                    text: root.txSafe("tab.diff", "Diff Analysis")
                    height: tabs.height
                    implicitWidth: 136
                    implicitHeight: 36
                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 0
                    rightPadding: 0
                    background: Rectangle {
                        anchors.fill: parent
                        radius: 10
                        antialiasing: true
                        color: tabs.currentIndex === 1 ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.18) : "transparent"
                        border.color: tabs.currentIndex === 1 ? root.primaryColor : "transparent"
                        border.width: tabs.currentIndex === 1 ? 1 : 0
                    }
                    contentItem: Text {
                        text: root.txSafe("tab.diff", "Diff Analysis")
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.bold: tabs.currentIndex === 1
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            radius: 12
            color: root.themeColors.card
            border.color: root.themeColors.border

            TextField {
                id: globalSearch
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                placeholderText: tabs.currentIndex === 0
                    ? root.txSafe("search.placeholder", "Global search")
                    : root.txSafe("diff.search.placeholder", "Search diffs")
                color: root.textColor
                placeholderTextColor: root.mutedTextColor
                verticalAlignment: TextInput.AlignVCenter
                background: Item {}
                onTextChanged: root.searchEdited(text)
            }
        }

        AppButton {
            themeColors: root.themeColors
            text: root.txSafe("common.clear", "Clear")
            font.pixelSize: 14
            cornerRadius: 10
            implicitHeight: 42
            implicitWidth: 78
            onClicked: root.clearRequested()
        }
    }
}
