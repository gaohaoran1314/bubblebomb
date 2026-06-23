#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "NetworkManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 设置组织信息，让 QSettings 正常工作
    QCoreApplication::setOrganizationName("BubbleBomb");
    QCoreApplication::setOrganizationDomain("bubblebomb.game");

    QQmlApplicationEngine engine;


    const QUrl url(u"qrc:/qt/qml/bubblebomb/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}