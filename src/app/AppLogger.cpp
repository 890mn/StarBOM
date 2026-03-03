#include "AppLogger.h"

#include <QDir>
#include <QMetaObject>
#include <QDateTime>
#include <QStandardPaths>
#include <QtGlobal>

#include <memory>
#include <mutex>
#include <cstdlib>
#include <chrono>
#include <atomic>

#include <spdlog/async.h>
#include <spdlog/async_logger.h>
#include <spdlog/details/log_msg.h>
#include <spdlog/logger.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/base_sink.h>
#include <spdlog/sinks/msvc_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

namespace {
std::once_flag g_initOnce;
std::shared_ptr<spdlog::logger> g_logger;
QString g_logFilePath;
std::atomic<LogRelay *> g_relay{nullptr};

class QtRelaySink final : public spdlog::sinks::base_sink<std::mutex>
{
protected:
    void sink_it_(const spdlog::details::log_msg &msg) override
    {
        LogRelay *relay = g_relay.load(std::memory_order_acquire);
        if (!relay) {
            return;
        }

        const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(msg.time.time_since_epoch()).count();
        const QString time = QDateTime::fromMSecsSinceEpoch(ms).toString(QStringLiteral("hh:mm:ss.zzz"));
        const QString level = QString::fromUtf8(spdlog::level::to_string_view(msg.level).data()).toUpper();
        const QString payload = QString::fromUtf8(msg.payload.data(), static_cast<int>(msg.payload.size()));

        QMetaObject::invokeMethod(relay, "publish", Qt::QueuedConnection,
                                  Q_ARG(QString, time),
                                  Q_ARG(QString, level),
                                  Q_ARG(QString, payload));
    }

    void flush_() override {}
};

void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context)
    switch (type) {
    case QtDebugMsg:
        AppLogger::debug(QStringLiteral("Qt: %1").arg(message));
        break;
    case QtInfoMsg:
        AppLogger::info(QStringLiteral("Qt: %1").arg(message));
        break;
    case QtWarningMsg:
        AppLogger::warn(QStringLiteral("Qt: %1").arg(message));
        break;
    case QtCriticalMsg:
        AppLogger::error(QStringLiteral("Qt: %1").arg(message));
        break;
    case QtFatalMsg:
        AppLogger::error(QStringLiteral("Qt fatal: %1").arg(message));
        abort();
    }
}

std::shared_ptr<spdlog::logger> loggerInstance()
{
    AppLogger::initialize();
    return g_logger;
}
} // namespace

LogRelay::LogRelay(QObject *parent)
    : QObject(parent)
{
}

void LogRelay::publish(const QString &time, const QString &level, const QString &message)
{
    emit entryAdded(time, level, message);
}

void AppLogger::initialize()
{
    std::call_once(g_initOnce, [] {
        try {
            const QString logDir = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation))
                                       .filePath(QStringLiteral("logs"));
            QDir().mkpath(logDir);
            g_logFilePath = QDir(logDir).filePath(QStringLiteral("Link2BOM.log"));

            std::vector<spdlog::sink_ptr> sinks;
            sinks.push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(g_logFilePath.toStdString(), true));
            sinks.push_back(std::make_shared<QtRelaySink>());
#ifdef _WIN32
            sinks.push_back(std::make_shared<spdlog::sinks::msvc_sink_mt>());
#else
            sinks.push_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
#endif

            if (!spdlog::thread_pool()) {
                spdlog::init_thread_pool(8192, 1);
            }

            g_logger = std::make_shared<spdlog::async_logger>(
                "app",
                sinks.begin(),
                sinks.end(),
                spdlog::thread_pool(),
                spdlog::async_overflow_policy::overrun_oldest);
            g_logger->set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%^%l%$] [%n] %v");
            g_logger->set_level(spdlog::level::debug);
            g_logger->flush_on(spdlog::level::warn);
            spdlog::set_default_logger(g_logger);

            qInstallMessageHandler(qtMessageHandler);
            g_logger->info("AppLogger initialized, file={}", g_logFilePath.toStdString());
        } catch (const spdlog::spdlog_ex &) {
            g_logger = spdlog::default_logger();
        }
    });
}

void AppLogger::attachRelay(LogRelay *relay)
{
    initialize();
    g_relay.store(relay, std::memory_order_release);
}

QString AppLogger::logFilePath()
{
    initialize();
    return g_logFilePath;
}

void AppLogger::debug(const QString &message)
{
    loggerInstance()->debug(message.toStdString());
}

void AppLogger::info(const QString &message)
{
    loggerInstance()->info(message.toStdString());
}

void AppLogger::warn(const QString &message)
{
    loggerInstance()->warn(message.toStdString());
}

void AppLogger::error(const QString &message)
{
    loggerInstance()->error(message.toStdString());
}
