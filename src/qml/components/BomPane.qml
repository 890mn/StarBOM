import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var app
    required property var palette

    property var columnWidths: [180, 180, 180, 180, 180, 180]
    property var slotAscending: [true, true, true, true, true, true]

    function ensureColumnWidthSize() {
        while (columnWidths.length < 6) columnWidths.push(180)
        while (slotAscending.length < 6) slotAscending.push(true)
    }

    function slotWidth(slot) {
        ensureColumnWidthSize()
        return columnWidths[slot]
    }

    function setSlotWidth(slot, widthValue) {
        ensureColumnWidthSize()
        columnWidths[slot] = Math.max(110, Math.min(420, widthValue))
        tableView.forceLayout()
        selectorTable.forceLayout()
    }

    function toggleSort(slot) {
        ensureColumnWidthSize()
        app.bomModel.sortByVisibleColumn(slot, slotAscending[slot])
        slotAscending[slot] = !slotAscending[slot]
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: palette.card
        border.color: palette.border

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
                    color: palette.primary
                    border.color: palette.card
                    Text { anchors.centerIn: parent; color: "white"; text: display; font.bold: true }
                }
            }

            // 第一行配置：左下拉切列，右按钮切排序，右边缘拖拉调宽
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
                    id: cfgCell
                    implicitHeight: 40
                    color: palette.subtle
                    border.color: palette.border

                    property real dragStartX: 0
                    property real dragStartWidth: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 8
                        spacing: 4

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

                        ToolButton {
                            text: root.slotAscending[column] ? "↑" : "↓"
                            onClicked: root.toggleSort(column)
                        }
                    }

                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 8
                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.SizeHorCursor
                            onPressed: function(mouse) {
                                cfgCell.dragStartX = mouse.x
                                cfgCell.dragStartWidth = root.slotWidth(column)
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    const delta = mouse.x - cfgCell.dragStartX
                                    root.setSlotWidth(column, cfgCell.dragStartWidth + delta)
                                }
                            }
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
                columnWidthProvider: function(column) { return root.slotWidth(column) }

                delegate: Rectangle {
                    implicitHeight: 34
                    color: row % 2 === 0 ? palette.card : palette.subtle
                    border.color: palette.border
                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: display === undefined ? "" : display
                        color: palette.text
                    }
                }
            }
        }
    }
}
