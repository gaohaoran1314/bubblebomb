#include "NetworkManager.h"
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent), server(nullptr), socket(nullptr), m_isHost(false)
{
}

NetworkManager::~NetworkManager()
{
    disconnect();
}

bool NetworkManager::createServer(quint16 port)
{
    if (server) {
        server->close();
        delete server;
    }
    server = new QTcpServer(this);
    connect(server, &QTcpServer::newConnection, this, &NetworkManager::onNewConnection);
    if (!server->listen(QHostAddress::Any, port)) {
        qWarning() << "Server listen failed:" << server->errorString();
        delete server;
        server = nullptr;
        return false;
    }
    m_isHost = true;
    emit isHostChanged();
    qDebug() << "Server listening on port" << port;
    return true;
}

bool NetworkManager::joinServer(const QString &ip, quint16 port)
{
    if (socket) {
        socket->close();
        delete socket;
        socket = nullptr;
    }
    socket = new QTcpSocket(this);
    socket->connectToHost(ip, port);
    if (!socket->waitForConnected(3000)) {
        qWarning() << "Connection failed:" << socket->errorString();
        delete socket;
        socket = nullptr;
        return false;
    }
    connect(socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
    connect(socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
    m_isHost = false;
    emit isHostChanged();
    emit connected();  // 客户端连接成功即触发
    return true;
}

void NetworkManager::disconnect()
{
    if (server) {
        server->close();
        delete server;
        server = nullptr;
    }
    if (socket) {
        socket->disconnectFromHost();
        socket->deleteLater();
        socket = nullptr;
    }
    m_isHost = false;
    emit isHostChanged();
    emit disconnected();
}

void NetworkManager::sendInput(const QString &key, bool pressed)
{
    QJsonObject obj;
    obj["type"] = "input";
    obj["key"] = key;
    obj["pressed"] = pressed;
    sendJson(obj);
}

void NetworkManager::sendSnapshot(const QJsonObject &snapshot)
{
    QJsonObject obj;
    obj["type"] = "snapshot";
    obj["data"] = snapshot;
    sendJson(obj);
}

void NetworkManager::sendGameOver(const QString &winner)
{
    QJsonObject obj;
    obj["type"] = "gameover";
    obj["winner"] = winner;
    sendJson(obj);
}

void NetworkManager::sendResetGame()
{
    QJsonObject obj;
    obj["type"] = "reset";
    sendJson(obj);
}

QString NetworkManager::getLocalIP() const
{
    const QList<QHostAddress> addresses = QNetworkInterface::allAddresses();
    for (const QHostAddress &addr : addresses) {
        if (addr != QHostAddress::LocalHost && addr.toIPv4Address()) {
            return addr.toString();
        }
    }
    return "127.0.0.1";
}

void NetworkManager::onNewConnection()
{
    if (socket) {
        // 只允许一个客户端连接
        QTcpSocket *newSocket = server->nextPendingConnection();
        newSocket->close();
        return;
    }
    socket = server->nextPendingConnection();
    connect(socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
    connect(socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
    qDebug() << "Client connected";
    emit connected();  // 主机收到客户端连接后触发
}

void NetworkManager::onReadyRead()
{
    if (!socket) return;
    QByteArray data = socket->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        processMessage(doc.object());
    }
}

void NetworkManager::onDisconnected()
{
    qDebug() << "Disconnected";
    emit disconnected();
}

void NetworkManager::sendJson(const QJsonObject &obj)
{
    if (!socket) return;
    QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    socket->write(data + "\n");
    socket->flush();
}

void NetworkManager::processMessage(const QJsonObject &msg)
{
    QString type = msg["type"].toString();
    if (type == "input") {
        if (m_isHost) {
            emit inputReceived(msg);
        }
    } else if (type == "snapshot") {
        if (!m_isHost) {
            QJsonObject data = msg["data"].toObject();
            emit snapshotReceived(data);
        }
    } else if (type == "gameover") {
        emit gameOverReceived(msg["winner"].toString());
    } else if (type == "reset") {
        emit resetGameReceived();
    }
}