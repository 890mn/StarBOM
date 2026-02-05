# StarBOM

StarBOM 是一个基于 Qt 6 Widgets 的桌面原型，用于导入 BOM 并进行半自动整理和项目化管理。

## 当前原型特性
- 左侧 20% 导航工作区：导入、导出、项目管理、分类组管理、主题切换。
- 右侧 80% 内容区：顶部 10% 视图切换（BOM / 库存 / 差异分析），底部 90% 展示主视图内容。
- 提供三元色主题切换（Aurora / Citrus / Slate）。
- 预留导入通道：立创快速导入、XLS/XLSX、OCR。
- 预留导出通道：CSV、项目报告、核对清单。

## 构建
```bash
cmake -S . -B build
cmake --build build
```
