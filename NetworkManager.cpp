#include "NetworkManager.h"
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent), server(nullptr), socket(nullptr), m_isHost(false) {}

NetworkManager::~NetworkManager() { disconnect(); }

bool NetworkManager::createServer(quint16 port) {
    if (server) { server->close(); delete server; }
    server = new QTcpServer(this);
    connect(server, &QTcpServer::newConnection, this, &NetworkManager::onNewConnection);
    if (!server->listen(QHostAddress::Any, port)) {
        qWarning() << "Server listen failed:" << server->errorString();
        delete server; server = nullptr; return false;
    }
    m_isHost = true;
    emit isHostChanged();
    return true;
}

bool NetworkManager::joinServer(const QString &ip, quint16 port) {
    if (socket) { socket->close(); delete socket; socket = nullptr; }
    socket = new QTcpSocket(this);
    socket->connectToHost(ip, port);
    if (!socket->waitForConnected(3000)) {
        qWarning() << "Connection failed:" << socket->errorString();
        delete socket; socket = nullptr; return false;
    }
    connect(socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
    connect(socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
    m_isHost = false;
    emit isHostChanged();
    emit connected();
    return true;
}

void NetworkManager::disconnect() {
    if (server) { server->close(); delete server; server = nullptr; }
    if (socket) { socket->disconnectFromHost(); socket->deleteLater(); socket = nullptr; }
    m_readBuffer.clear();
    m_isHost = false;
    emit isHostChanged();
    emit disconnected();
}

void NetworkManager::sendInput(const QString &key, bool pressed) {
    QJsonObject obj;
    obj["type"] = "input";
    obj["key"] = key;
    obj["pressed"] = pressed;
    sendJson(obj);
}

void NetworkManager::sendSnapshot(const QJsonObject &snapshot) {
    QJsonObject obj;
    obj["type"] = "snapshot";
    obj["data"] = snapshot;
    sendJson(obj);
}

void NetworkManager::sendGameOver(const QString &winner) {
    QJsonObject obj; obj["type"] = "gameover"; obj["winner"] = winner;
    sendJson(obj);
}

void NetworkManager::sendResetGame() {
    QJsonObject obj; obj["type"] = "reset";
    sendJson(obj);
}

QString NetworkManager::getLocalIP() const {
    const QList<QHostAddress> addresses = QNetworkInterface::allAddresses();
    for (const QHostAddress &addr : addresses) {
        if (addr != QHostAddress::LocalHost && addr.toIPv4Address()) return addr.toString();
    }
    return "127.0.0.1";
}

void NetworkManager::sendBlockDestroyed(int x, int y) {
    QJsonObject obj;
    obj["type"] = "blockDestroyed";
    obj["x"] = x;
    obj["y"] = y;
    sendJson(obj);
}

void NetworkManager::sendPowerUpSpawned(int x, int y, const QString &type) {
    QJsonObject obj;
    obj["type"] = "powerUpSpawned";
    obj["x"] = x;
    obj["y"] = y;
    obj["powerType"] = type;
    sendJson(obj);
}

void NetworkManager::sendBombPlaced(int x, int y, int range, int ownerId) {
    QJsonObject obj;
    obj["type"] = "bombPlaced";
    obj["x"] = x;
    obj["y"] = y;
    obj["range"] = range;
    obj["ownerId"] = ownerId;
    sendJson(obj);
}

void NetworkManager::sendBombExploded(int x, int y) {
    QJsonObject obj;
    obj["type"] = "bombExploded";
    obj["x"] = x;
    obj["y"] = y;
    sendJson(obj);
}

void NetworkManager::onNewConnection() {
    if (socket) { QTcpSocket *ns = server->nextPendingConnection(); ns->close(); return; }
    socket = server->nextPendingConnection();
    connect(socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
    connect(socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
    emit connected();
}

void NetworkManager::onReadyRead() {
    if (!socket) return;
    m_readBuffer.append(socket->readAll());
    parseBuffer();
}

void NetworkManager::onDisconnected() {
    emit disconnected();
}

void NetworkManager::sendJson(const QJsonObject &obj) {
    if (!socket) return;
    QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    data.append('\n');
    socket->write(data);
    socket->flush();
}

void NetworkManager::processMessage(const QJsonObject &msg) {
    QString type = msg["type"].toString();
    if (type == "input") {
        emit inputReceived(msg);
    } else if (type == "snapshot") {
        if (!m_isHost) {
            QJsonObject data = msg["data"].toObject();
            emit snapshotReceived(data);
        }
    } else if (type == "gameover") {
        emit gameOverReceived(msg["winner"].toString());
    } else if (type == "reset") {
        emit resetGameReceived();
    } else if (type == "blockDestroyed") {
        emit blockDestroyed(msg["x"].toInt(), msg["y"].toInt());
    } else if (type == "powerUpSpawned") {
        emit powerUpSpawned(msg["x"].toInt(), msg["y"].toInt(), msg["powerType"].toString());
    } else if (type == "bombPlaced") {
        emit bombPlaced(msg["x"].toInt(), msg["y"].toInt(), msg["range"].toInt(), msg["ownerId"].toInt());
    } else if (type == "bombExploded") {
        emit bombExploded(msg["x"].toInt(), msg["y"].toInt());
    }
}

void NetworkManager::parseBuffer() {
    while (true) {
        int idx = m_readBuffer.indexOf('\n');
        if (idx < 0) break;
        QByteArray line = m_readBuffer.left(idx);
        m_readBuffer.remove(0, idx + 1);
        if (line.isEmpty()) continue;
        QJsonDocument doc = QJsonDocument::fromJson(line);
        if (doc.isObject()) {
            processMessage(doc.object());
        } else {
            qWarning() << "Invalid JSON:" << line;
        }
    }
}