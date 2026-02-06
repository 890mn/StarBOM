#include "BomTableModel.h"

#include <algorithm>

BomTableModel::BomTableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

int BomTableModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_sourceRows.size();
}

int BomTableModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_visibleSourceColumns.size();
}

QVariant BomTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || role != Qt::DisplayRole || index.row() >= m_sourceRows.size() || index.column() >= m_visibleSourceColumns.size()) {
        return {};
    }

    const int sourceIndex = m_visibleSourceColumns[index.column()];
    const QStringList &row = m_sourceRows[index.row()];
    if (sourceIndex < 0 || sourceIndex >= row.size()) {
        return {};
    }
    return row[sourceIndex];
}

QVariant BomTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role != Qt::DisplayRole) {
        return {};
    }
    if (orientation == Qt::Horizontal) {
        if (section < 0 || section >= m_visibleSourceColumns.size()) {
            return {};
        }
        const int sourceIndex = m_visibleSourceColumns[section];
        if (sourceIndex < 0 || sourceIndex >= m_sourceHeaders.size()) {
            return {};
        }
        return m_sourceHeaders[sourceIndex];
    }
    return section + 1;
}

QStringList BomTableModel::availableHeaders() const
{
    return m_sourceHeaders;
}

QString BomTableModel::visibleHeaderAt(int slot) const
{
    if (slot < 0 || slot >= m_visibleSourceColumns.size()) {
        return QString();
    }
    const int sourceIndex = m_visibleSourceColumns[slot];
    return m_sourceHeaders.value(sourceIndex);
}

void BomTableModel::setVisibleHeaderAt(int slot, const QString &header)
{
    if (slot < 0 || slot >= m_visibleSourceColumns.size()) {
        return;
    }
    const int sourceIndex = m_sourceHeaders.indexOf(header);
    if (sourceIndex < 0 || sourceIndex == m_visibleSourceColumns[slot]) {
        return;
    }
    m_visibleSourceColumns[slot] = sourceIndex;
    emit headerDataChanged(Qt::Horizontal, slot, slot);
    if (!m_sourceRows.isEmpty()) {
        emit dataChanged(index(0, slot), index(m_sourceRows.size() - 1, slot));
    }
}

int BomTableModel::visibleSlotCount() const
{
    return m_visibleSourceColumns.size();
}

void BomTableModel::sortByVisibleColumn(int slot, bool ascending)
{
    if (slot < 0 || slot >= m_visibleSourceColumns.size()) {
        return;
    }
    const int sourceIndex = m_visibleSourceColumns[slot];
    if (sourceIndex < 0) {
        return;
    }

    beginResetModel();
    std::sort(m_sourceRows.begin(), m_sourceRows.end(), [sourceIndex, ascending](const QStringList &a, const QStringList &b) {
        const QString left = sourceIndex < a.size() ? a[sourceIndex] : QString();
        const QString right = sourceIndex < b.size() ? b[sourceIndex] : QString();
        return ascending ? left < right : left > right;
    });
    endResetModel();
}

void BomTableModel::setSourceData(const QStringList &headers, const QList<QStringList> &rows)
{
    beginResetModel();
    m_sourceHeaders = headers;
    m_sourceRows = rows;
    m_visibleSourceColumns.clear();
    const int visibleCount = qMin(6, m_sourceHeaders.size());
    for (int i = 0; i < visibleCount; ++i) {
        m_visibleSourceColumns.append(i);
    }
    endResetModel();
}
