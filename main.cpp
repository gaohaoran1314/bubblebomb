#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "pipe.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<Pipe>("GameLogic", 1, 0, "Pipe");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/benniaoxianfei/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}