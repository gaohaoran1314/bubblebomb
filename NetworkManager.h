#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkInterface>
#include <QByteArray>
#include <QQmlEngine>
#include <QJSEngine>

class NetworkManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool isHost READ isHost NOTIFY isHostChanged)

public:
    static NetworkManager* create(QQmlEngine *, QJSEngine *) {
        static NetworkManager* instance = new NetworkManager();
        return instance;
    }

    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    Q_INVOKABLE bool createServer(quint16 port = 12345);
    Q_INVOKABLE bool joinServer(const QString &ip, quint16 port = 12345);
    Q_INVOKABLE void disconnect();

    Q_INVOKABLE void sendInput(const QString &key, bool pressed);
    Q_INVOKABLE void sendSnapshot(const QJsonObject &snapshot);
    Q_INVOKABLE void sendGameOver(const QString &winner);
    Q_INVOKABLE void sendResetGame();
    Q_INVOKABLE QString getLocalIP() const;
    Q_INVOKABLE void sendHeartbeat() {}

    Q_INVOKABLE void sendBlockDestroyed(int x, int y);
    Q_INVOKABLE void sendPowerUpSpawned(int x, int y, const QString &type);
    Q_INVOKABLE void sendBombPlaced(int x, int y, int range, int ownerId);
    Q_INVOKABLE void sendBombExploded(int x, int y);
    Q_INVOKABLE void sendPowerUpCollected(int x, int y, const QString &type);  // 新增

    bool isHost() const { return m_isHost; }

signals:
    void connected();
    void disconnected();
    void snapshotReceived(const QJsonObject &snapshot);
    void inputReceived(const QJsonObject &input);
    void gameOverReceived(const QString &winner);
    void resetGameReceived();
    void isHostChanged();

    void blockDestroyed(int x, int y);
    void powerUpSpawned(int x, int y, const QString &type);
    void bombPlaced(int x, int y, int range, int ownerId);
    void bombExploded(int x, int y);
    void powerUpCollected(int x, int y, const QString &type);  // 新增

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    void sendJson(const QJsonObject &obj);
    void processMessage(const QJsonObject &msg);
    void parseBuffer();

    QTcpServer *server;
    QTcpSocket *socket;
    bool m_isHost;
    QByteArray m_readBuffer;
};

#endif