#pragma once

#include <QMainWindow>

class QListWidget;
class QStackedWidget;
class QTableWidget;
class QComboBox;
class QLabel;
class QLineEdit;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);

private:
    void setupUi();
    void setupLeftPanel();
    void setupRightPanel();
    void setupSignals();
    void applyTheme(const QString &themeName);
    void updateStatus(const QString &message);

    QWidget *m_centralWidget = nullptr;
    QListWidget *m_projectList = nullptr;
    QListWidget *m_categoryList = nullptr;
    QStackedWidget *m_viewStack = nullptr;
    QTableWidget *m_bomTable = nullptr;
    QTableWidget *m_inventoryTable = nullptr;
    QComboBox *m_themeSelector = nullptr;
    QLabel *m_statusLabel = nullptr;
    QLineEdit *m_quickImportInput = nullptr;
};
