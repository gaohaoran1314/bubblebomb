#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "NetworkManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 创建网络管理器实例
    NetworkManager netManager;
    // 注册到 QML 全局上下文，让所有 QML 文件都能通过 "networkManager" 访问
    engine.rootContext()->setContextProperty("networkManager", &netManager);

    const QUrl url(u"qrc:/qt/qml/bubblebomb/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}