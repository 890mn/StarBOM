import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var app
    property bool ascendingSort: true
    property int sortSlot: 0
    property var columnWidths: [180, 180, 180, 180, 180, 180]

    function ensureColumnWidthSize() {
        while (columnWidths.length < 6) {
            columnWidths.push(180)
        }
    }

    function slotWidth(slot) {
        ensureColumnWidthSize()
        return columnWidths[slot]
    }

    function adjustSlotWidth(slot, delta) {
        ensureColumnWidthSize()
        const next = Math.max(100, Math.min(360, columnWidths[slot] + delta))
        columnWidths[slot] = next
        tableView.forceLayout()
        selectorTable.forceLayout()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 8
            color: "#F8FAFC"
            border.color: "#E2E8F0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                TextField {
                    id: searchField
                    Layout.preferredWidth: 300
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
                Item { Layout.fillWidth: true }
                Label { text: "排序列：" }
                ComboBox {
                    id: sortByCombo
                    Layout.preferredWidth: 180
                    model: root.app.bomModel.availableHeaders()
                    onActivated: function(activatedIndex) {
                        root.sortSlot = activatedIndex
                    }
                }
                Button {
                    text: root.ascendingSort ? "升序" : "降序"
                    onClicked: {
                        root.app.bomModel.sortByVisibleColumn(root.sortSlot, root.ascendingSort)
                        root.ascendingSort = !root.ascendingSort
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "white"
            border.color: "#E2E8F0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 1

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
                    }
                }

                // 表格第一行：列显示选择 + 单列宽度调整 + 右侧排序
                TableView {
                    id: selectorTable
                    Layout.fillWidth: true
                    implicitHeight: 42
                    interactive: false
                    model: 1
                    columnSpacing: 1
                    rowSpacing: 0
                    columnWidthProvider: function(column) { return root.slotWidth(column) }

                    delegate: Rectangle {
                        implicitHeight: 40
                        color: "#F8FAFC"
                        border.color: "#E2E8F0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 3
                            spacing: 2

                            ComboBox {
                                id: selector
                                Layout.fillWidth: true
                                model: root.app.bomModel.availableHeaders()

                                function syncIndex() {
                                    const currentHeader = root.app.bomModel.visibleHeaderAt(column)
                                    const idx = model.indexOf(currentHeader)
                                    currentIndex = idx >= 0 ? idx : 0
                                }

                                Component.onCompleted: syncIndex()
                                onActivated: function(_activatedIndex) {
                                    root.app.bomModel.setVisibleHeaderAt(column, currentText)
                                }

                                Connections {
                                    target: root.app.bomModel
                                    function onModelReset() { selector.syncIndex() }
                                }
                            }

                            ToolButton { text: "-"; onClicked: root.adjustSlotWidth(column, -12) }
                            ToolButton { text: "+"; onClicked: root.adjustSlotWidth(column, 12) }
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
                    columnWidthProvider: function(column) { return root.slotWidth(column) }

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
    }
}
