#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "FileHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    FileHandler fileHandler;
    engine.rootContext()->setContextProperty("fileHandler", &fileHandler);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Calendar", "Main");

    return app.exec();
}
