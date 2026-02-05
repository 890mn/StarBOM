#include "MainWindow.h"

#include <QComboBox>
#include <QFrame>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QInputDialog>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPushButton>
#include <QSplitter>
#include <QStackedWidget>
#include <QTableWidget>
#include <QVBoxLayout>
#include <QWidget>
#include <QApplication>
#include <QTableWidgetItem>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setupUi();
    setupSignals();
    applyTheme(QStringLiteral("Aurora Triad"));
    updateStatus(QStringLiteral("已就绪：选择导入方式开始整理 BOM。"));
}

void MainWindow::setupUi()
{
    setWindowTitle(QStringLiteral("StarBOM - BOM 半自动整理工具"));
    resize(1320, 820);

    m_centralWidget = new QWidget(this);
    auto *mainLayout = new QHBoxLayout(m_centralWidget);
    mainLayout->setContentsMargins(12, 12, 12, 12);
    mainLayout->setSpacing(10);

    auto *splitter = new QSplitter(Qt::Horizontal, m_centralWidget);
    splitter->setChildrenCollapsible(false);

    auto *leftPanel = new QFrame(splitter);
    leftPanel->setObjectName(QStringLiteral("leftPanel"));
    auto *leftLayout = new QVBoxLayout(leftPanel);
    leftLayout->setContentsMargins(10, 10, 10, 10);
    leftLayout->setSpacing(10);

    auto *rightPanel = new QFrame(splitter);
    rightPanel->setObjectName(QStringLiteral("rightPanel"));
    auto *rightLayout = new QVBoxLayout(rightPanel);
    rightLayout->setContentsMargins(10, 10, 10, 10);
    rightLayout->setSpacing(8);

    splitter->addWidget(leftPanel);
    splitter->addWidget(rightPanel);
    splitter->setStretchFactor(0, 2);
    splitter->setStretchFactor(1, 8);

    mainLayout->addWidget(splitter);
    setCentralWidget(m_centralWidget);

    setupLeftPanel();
    setupRightPanel();
}

void MainWindow::setupLeftPanel()
{
    auto *leftPanel = findChild<QFrame *>(QStringLiteral("leftPanel"));
    auto *layout = qobject_cast<QVBoxLayout *>(leftPanel->layout());

    auto *importGroup = new QGroupBox(QStringLiteral("导入"), leftPanel);
    auto *importLayout = new QVBoxLayout(importGroup);

    m_quickImportInput = new QLineEdit(importGroup);
    m_quickImportInput->setPlaceholderText(QStringLiteral("粘贴立创 BOM 链接或关键字"));

    auto *quickImportBtn = new QPushButton(QStringLiteral("立创快速导入"), importGroup);
    auto *xlsImportBtn = new QPushButton(QStringLiteral("从 XLS/XLSX 导入"), importGroup);
    auto *ocrImportBtn = new QPushButton(QStringLiteral("OCR 图片导入"), importGroup);

    importLayout->addWidget(m_quickImportInput);
    importLayout->addWidget(quickImportBtn);
    importLayout->addWidget(xlsImportBtn);
    importLayout->addWidget(ocrImportBtn);

    auto *exportGroup = new QGroupBox(QStringLiteral("导出"), leftPanel);
    auto *exportLayout = new QVBoxLayout(exportGroup);
    auto *csvExportBtn = new QPushButton(QStringLiteral("导出 CSV"), exportGroup);
    auto *reportExportBtn = new QPushButton(QStringLiteral("导出项目报告"), exportGroup);
    auto *sheetExportBtn = new QPushButton(QStringLiteral("导出核对清单"), exportGroup);
    exportLayout->addWidget(csvExportBtn);
    exportLayout->addWidget(reportExportBtn);
    exportLayout->addWidget(sheetExportBtn);

    auto *projectGroup = new QGroupBox(QStringLiteral("项目"), leftPanel);
    auto *projectLayout = new QVBoxLayout(projectGroup);
    m_projectList = new QListWidget(projectGroup);
    m_projectList->addItems({QStringLiteral("电源管理板 RevA"), QStringLiteral("传感器节点 V2"), QStringLiteral("验证样机 Proto-3")});

    auto *projectBtnLayout = new QHBoxLayout();
    auto *newProjectBtn = new QPushButton(QStringLiteral("新建"), projectGroup);
    auto *renameProjectBtn = new QPushButton(QStringLiteral("重命名"), projectGroup);
    projectBtnLayout->addWidget(newProjectBtn);
    projectBtnLayout->addWidget(renameProjectBtn);

    projectLayout->addWidget(m_projectList);
    projectLayout->addLayout(projectBtnLayout);

    auto *categoryGroup = new QGroupBox(QStringLiteral("分类组"), leftPanel);
    auto *categoryLayout = new QVBoxLayout(categoryGroup);
    m_categoryList = new QListWidget(categoryGroup);
    m_categoryList->addItems({QStringLiteral("电阻电容"), QStringLiteral("芯片 IC"), QStringLiteral("连接器"), QStringLiteral("机械件")});

    auto *categoryBtnLayout = new QHBoxLayout();
    auto *newCategoryBtn = new QPushButton(QStringLiteral("新增"), categoryGroup);
    auto *editCategoryBtn = new QPushButton(QStringLiteral("修改"), categoryGroup);
    categoryBtnLayout->addWidget(newCategoryBtn);
    categoryBtnLayout->addWidget(editCategoryBtn);

    categoryLayout->addWidget(m_categoryList);
    categoryLayout->addLayout(categoryBtnLayout);

    auto *themeGroup = new QGroupBox(QStringLiteral("主题"), leftPanel);
    auto *themeLayout = new QVBoxLayout(themeGroup);
    m_themeSelector = new QComboBox(themeGroup);
    m_themeSelector->addItems({QStringLiteral("Aurora Triad"), QStringLiteral("Citrus Triad"), QStringLiteral("Slate Triad")});
    themeLayout->addWidget(new QLabel(QStringLiteral("三元色主题："), themeGroup));
    themeLayout->addWidget(m_themeSelector);

    layout->addWidget(importGroup);
    layout->addWidget(exportGroup);
    layout->addWidget(projectGroup, 2);
    layout->addWidget(categoryGroup, 2);
    layout->addWidget(themeGroup);

    connect(quickImportBtn, &QPushButton::clicked, this, [this] {
        const QString key = m_quickImportInput->text().trimmed();
        updateStatus(key.isEmpty() ? QStringLiteral("请输入立创链接或关键字。")
                                   : QStringLiteral("立创快速导入准备完成：%1").arg(key));
    });

    connect(xlsImportBtn, &QPushButton::clicked, this, [this] {
        updateStatus(QStringLiteral("待接入：XLS/XLSX 导入向导。"));
    });

    connect(ocrImportBtn, &QPushButton::clicked, this, [this] {
        updateStatus(QStringLiteral("待接入：OCR 识别流程（图片/扫描件）。"));
    });

    connect(csvExportBtn, &QPushButton::clicked, this, [this] {
        updateStatus(QStringLiteral("已触发：CSV 导出任务（示例）。"));
    });

    connect(reportExportBtn, &QPushButton::clicked, this, [this] {
        updateStatus(QStringLiteral("已触发：项目报告导出（示例）。"));
    });

    connect(sheetExportBtn, &QPushButton::clicked, this, [this] {
        updateStatus(QStringLiteral("已触发：核对清单导出（示例）。"));
    });

    connect(newProjectBtn, &QPushButton::clicked, this, [this] {
        bool ok = false;
        const QString name = QInputDialog::getText(this, QStringLiteral("新建项目"), QStringLiteral("项目名称："), QLineEdit::Normal, {}, &ok);
        if (ok && !name.trimmed().isEmpty()) {
            m_projectList->addItem(name.trimmed());
            updateStatus(QStringLiteral("已新增项目：%1").arg(name.trimmed()));
        }
    });

    connect(renameProjectBtn, &QPushButton::clicked, this, [this] {
        auto *item = m_projectList->currentItem();
        if (!item) {
            updateStatus(QStringLiteral("请先选择要重命名的项目。"));
            return;
        }
        bool ok = false;
        const QString name = QInputDialog::getText(this, QStringLiteral("重命名项目"), QStringLiteral("新名称："), QLineEdit::Normal, item->text(), &ok);
        if (ok && !name.trimmed().isEmpty()) {
            item->setText(name.trimmed());
            updateStatus(QStringLiteral("项目已重命名为：%1").arg(name.trimmed()));
        }
    });

    connect(newCategoryBtn, &QPushButton::clicked, this, [this] {
        bool ok = false;
        const QString name = QInputDialog::getText(this, QStringLiteral("新增分类组"), QStringLiteral("分类名称："), QLineEdit::Normal, {}, &ok);
        if (ok && !name.trimmed().isEmpty()) {
            m_categoryList->addItem(name.trimmed());
            updateStatus(QStringLiteral("已新增分类组：%1").arg(name.trimmed()));
        }
    });

    connect(editCategoryBtn, &QPushButton::clicked, this, [this] {
        auto *item = m_categoryList->currentItem();
        if (!item) {
            updateStatus(QStringLiteral("请先选择要修改的分类组。"));
            return;
        }
        bool ok = false;
        const QString name = QInputDialog::getText(this, QStringLiteral("修改分类组"), QStringLiteral("新分类名称："), QLineEdit::Normal, item->text(), &ok);
        if (ok && !name.trimmed().isEmpty()) {
            item->setText(name.trimmed());
            updateStatus(QStringLiteral("分类组已修改为：%1").arg(name.trimmed()));
        }
    });
}

void MainWindow::setupRightPanel()
{
    auto *rightPanel = findChild<QFrame *>(QStringLiteral("rightPanel"));
    auto *layout = qobject_cast<QVBoxLayout *>(rightPanel->layout());

    auto *tabStrip = new QWidget(rightPanel);
    tabStrip->setObjectName(QStringLiteral("tabStrip"));
    auto *tabLayout = new QHBoxLayout(tabStrip);
    tabLayout->setContentsMargins(0, 0, 0, 0);
    tabLayout->setSpacing(8);

    auto *bomViewBtn = new QPushButton(QStringLiteral("BOM 视图"), tabStrip);
    auto *inventoryBtn = new QPushButton(QStringLiteral("库存视图"), tabStrip);
    auto *analyzeBtn = new QPushButton(QStringLiteral("差异分析"), tabStrip);
    bomViewBtn->setCheckable(true);
    inventoryBtn->setCheckable(true);
    analyzeBtn->setCheckable(true);
    bomViewBtn->setChecked(true);

    tabLayout->addWidget(bomViewBtn);
    tabLayout->addWidget(inventoryBtn);
    tabLayout->addWidget(analyzeBtn);
    tabLayout->addStretch();

    m_viewStack = new QStackedWidget(rightPanel);

    auto *bomPage = new QWidget(m_viewStack);
    auto *bomLayout = new QVBoxLayout(bomPage);
    m_bomTable = new QTableWidget(6, 7, bomPage);
    m_bomTable->setHorizontalHeaderLabels({QStringLiteral("位号"), QStringLiteral("分类"), QStringLiteral("料号"), QStringLiteral("规格"), QStringLiteral("数量"), QStringLiteral("供应商"), QStringLiteral("备注")});
    m_bomTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_bomTable->verticalHeader()->setVisible(false);

    const QList<QStringList> demoRows {
        {QStringLiteral("R1-R8"), QStringLiteral("电阻电容"), QStringLiteral("RC0603-10K"), QStringLiteral("10K 1% 0603"), QStringLiteral("8"), QStringLiteral("LCSC"), QStringLiteral("常规库存")},
        {QStringLiteral("C1-C4"), QStringLiteral("电阻电容"), QStringLiteral("CC0603-100N"), QStringLiteral("100nF 16V X7R"), QStringLiteral("4"), QStringLiteral("LCSC"), QStringLiteral("去耦")},
        {QStringLiteral("U1"), QStringLiteral("芯片 IC"), QStringLiteral("STM32G0"), QStringLiteral("QFN32"), QStringLiteral("1"), QStringLiteral("LCSC"), QStringLiteral("主控")}
    };

    for (int i = 0; i < demoRows.size(); ++i) {
        for (int j = 0; j < demoRows[i].size(); ++j) {
            m_bomTable->setItem(i, j, new QTableWidgetItem(demoRows[i][j]));
        }
    }
    bomLayout->addWidget(m_bomTable);

    auto *inventoryPage = new QWidget(m_viewStack);
    auto *inventoryLayout = new QVBoxLayout(inventoryPage);
    m_inventoryTable = new QTableWidget(5, 5, inventoryPage);
    m_inventoryTable->setHorizontalHeaderLabels({QStringLiteral("料号"), QStringLiteral("现存"), QStringLiteral("需求"), QStringLiteral("缺口"), QStringLiteral("建议")});
    m_inventoryTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_inventoryTable->verticalHeader()->setVisible(false);
    inventoryLayout->addWidget(m_inventoryTable);

    auto *analysisPage = new QWidget(m_viewStack);
    auto *analysisLayout = new QVBoxLayout(analysisPage);
    auto *analysisHint = new QLabel(QStringLiteral("差异分析视图：后续可接入版本对比、替代料推荐、价格波动提醒。"), analysisPage);
    analysisHint->setWordWrap(true);
    analysisLayout->addWidget(analysisHint);
    analysisLayout->addStretch();

    m_viewStack->addWidget(bomPage);
    m_viewStack->addWidget(inventoryPage);
    m_viewStack->addWidget(analysisPage);

    auto *statusBarBox = new QFrame(rightPanel);
    auto *statusLayout = new QHBoxLayout(statusBarBox);
    statusLayout->setContentsMargins(0, 0, 0, 0);
    m_statusLabel = new QLabel(statusBarBox);
    statusLayout->addWidget(m_statusLabel);

    layout->addWidget(tabStrip, 1);
    layout->addWidget(m_viewStack, 9);
    layout->addWidget(statusBarBox);

    auto setActive = [bomViewBtn, inventoryBtn, analyzeBtn](QPushButton *active) {
        bomViewBtn->setChecked(active == bomViewBtn);
        inventoryBtn->setChecked(active == inventoryBtn);
        analyzeBtn->setChecked(active == analyzeBtn);
    };

    connect(bomViewBtn, &QPushButton::clicked, this, [this, setActive, bomViewBtn] {
        setActive(bomViewBtn);
        m_viewStack->setCurrentIndex(0);
        updateStatus(QStringLiteral("已切换到 BOM 视图。"));
    });

    connect(inventoryBtn, &QPushButton::clicked, this, [this, setActive, inventoryBtn] {
        setActive(inventoryBtn);
        m_viewStack->setCurrentIndex(1);
        updateStatus(QStringLiteral("已切换到库存视图。"));
    });

    connect(analyzeBtn, &QPushButton::clicked, this, [this, setActive, analyzeBtn] {
        setActive(analyzeBtn);
        m_viewStack->setCurrentIndex(2);
        updateStatus(QStringLiteral("已切换到差异分析视图。"));
    });
}

void MainWindow::setupSignals()
{
    connect(m_themeSelector, &QComboBox::currentTextChanged, this, [this](const QString &name) {
        applyTheme(name);
        updateStatus(QStringLiteral("主题已切换：%1").arg(name));
    });
}

void MainWindow::applyTheme(const QString &themeName)
{
    QString primary = QStringLiteral("#2E5BFF");
    QString secondary = QStringLiteral("#FF7A00");
    QString accent = QStringLiteral("#00B8A9");
    QString panel = QStringLiteral("#F5F7FB");
    QString text = QStringLiteral("#1F2937");

    if (themeName == QStringLiteral("Citrus Triad")) {
        primary = QStringLiteral("#306B34");
        secondary = QStringLiteral("#FF7F11");
        accent = QStringLiteral("#4D2D52");
        panel = QStringLiteral("#F8F6F0");
    } else if (themeName == QStringLiteral("Slate Triad")) {
        primary = QStringLiteral("#384E77");
        secondary = QStringLiteral("#D66A6A");
        accent = QStringLiteral("#6AB187");
        panel = QStringLiteral("#F3F5F7");
    }

    const QString style = QString(R"(
        QMainWindow, QWidget {
            background: %1;
            color: %2;
            font-family: "Microsoft YaHei", "Segoe UI", sans-serif;
            font-size: 13px;
        }
        QFrame#leftPanel, QFrame#rightPanel {
            background: white;
            border: 1px solid #D8E0EA;
            border-radius: 10px;
        }
        QGroupBox {
            border: 1px solid #D8E0EA;
            border-radius: 8px;
            margin-top: 10px;
            font-weight: 600;
            padding-top: 10px;
        }
        QGroupBox::title {
            subcontrol-origin: margin;
            left: 12px;
            padding: 0 3px;
            color: %3;
        }
        QPushButton {
            background: %3;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 7px 10px;
        }
        QPushButton:hover { background: %4; }
        QPushButton:checked { background: %5; }
        QLineEdit, QListWidget, QTableWidget, QComboBox {
            border: 1px solid #CCD6E2;
            border-radius: 6px;
            background: white;
            padding: 5px;
        }
        QHeaderView::section {
            background: %3;
            color: white;
            padding: 5px;
            border: none;
        }
        QWidget#tabStrip {
            background: transparent;
        }
    )")
                              .arg(panel, text, primary, secondary, accent);

    qApp->setStyleSheet(style);
}

void MainWindow::updateStatus(const QString &message)
{
    m_statusLabel->setText(message);
}
