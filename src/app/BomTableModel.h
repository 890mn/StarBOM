#pragma once

#include <QAbstractTableModel>

class BomTableModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    explicit BomTableModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;

    Q_INVOKABLE QStringList availableHeaders() const;
    Q_INVOKABLE QString visibleHeaderAt(int slot) const;
    Q_INVOKABLE void setVisibleHeaderAt(int slot, const QString &header);
    Q_INVOKABLE int visibleSlotCount() const;
    Q_INVOKABLE void sortByVisibleColumn(int slot, bool ascending);

    void setSourceData(const QStringList &headers, const QList<QStringList> &rows);

private:
    QStringList m_sourceHeaders;
    QList<QStringList> m_sourceRows;
    QList<int> m_visibleSourceColumns;
};
