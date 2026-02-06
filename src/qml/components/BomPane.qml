import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var app
    property bool ascendingSort: true

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Label { text: "显示列：" }
            Repeater {
                model: 6
                ComboBox {
                    Layout.preferredWidth: 140
                    model: root.app.bomModel.availableHeaders()
                    Component.onCompleted: currentIndex = Math.max(0, model.indexOf(root.app.bomModel.visibleHeaderAt(index)))
                    onActivated: root.app.bomModel.setVisibleHeaderAt(index, currentText)
                }
            }
            Item { Layout.fillWidth: true }
        }

        HorizontalHeaderView {
            id: header
            Layout.fillWidth: true
            syncView: tableView
            delegate: Rectangle {
                implicitHeight: 34
                color: "#2E5BFF"
                border.color: "white"
                Text { anchors.centerIn: parent; color: "white"; text: display }
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
            columnSpacing: 1
            rowSpacing: 1
            columnWidthProvider: function(column) { return 160 }
            delegate: Rectangle {
                implicitHeight: 34
                color: "white"
                border.color: "#E5E7EB"
                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: display
                }
            }
        }
    }
}
