import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var app
    property bool ascendingSort: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Label { text: "显示列：" }
            Repeater {
                model: 6
                ComboBox {
                    id: selector
                    Layout.preferredWidth: 145
                    model: root.app.bomModel.availableHeaders()

                    function syncIndex() {
                        const currentHeader = root.app.bomModel.visibleHeaderAt(index)
                        const idx = model.indexOf(currentHeader)
                        currentIndex = idx >= 0 ? idx : 0
                    }

                    Component.onCompleted: syncIndex()
                    onActivated: root.app.bomModel.setVisibleHeaderAt(index, currentText)

                    Connections {
                        target: root.app.bomModel
                        function onModelReset() { selector.syncIndex() }
                    }
                }
            }
            Item { Layout.fillWidth: true }
            TextField {
                id: searchField
                Layout.preferredWidth: 280
                placeholderText: "全文搜索（料号/位号/规格/备注）"
                onTextChanged: root.app.bomModel.setFilterKeyword(text)
            }
            Button {
                text: "清空"
                onClicked: {
                    searchField.clear()
                    root.app.bomModel.setFilterKeyword("")
                }
            }
        }

        HorizontalHeaderView {
            id: header
            Layout.fillWidth: true
            syncView: tableView
            clip: true
            delegate: Rectangle {
                implicitHeight: 34
                color: "#2E5BFF"
                border.color: "#FFFFFF"
                Text { anchors.centerIn: parent; color: "white"; text: display; font.bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.app.bomModel.sortByVisibleColumn(column, root.ascendingSort)
                        root.ascendingSort = !root.ascendingSort
                    }
                }
            }
        }

        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.app.bomModel
            boundsBehavior: Flickable.StopAtBounds
            rowSpacing: 1
            columnSpacing: 1
            columnWidthProvider: function(column) { return 170 }

            delegate: Rectangle {
                implicitHeight: 34
                color: row % 2 === 0 ? "#FFFFFF" : "#F8FAFC"
                border.color: "#E5E7EB"
                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: display === undefined ? "" : display
                    color: "#0F172A"
                }
            }
        }
    }
}
