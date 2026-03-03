#pragma once

#include <QObject>
#include <QString>

class LogRelay : public QObject
{
    Q_OBJECT
public:
    explicit LogRelay(QObject *parent = nullptr);

public slots:
    void publish(const QString &time, const QString &level, const QString &message);

signals:
    void entryAdded(const QString &time, const QString &level, const QString &message);
};

namespace AppLogger {

void initialize();
void attachRelay(LogRelay *relay);
QString logFilePath();

void debug(const QString &message);
void info(const QString &message);
void warn(const QString &message);
void error(const QString &message);

} // namespace AppLogger
