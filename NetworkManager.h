#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkInterface>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isHost READ isHost NOTIFY isHostChanged)

public:
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

    bool isHost() const { return m_isHost; }

signals:
    void connected();
    void disconnected();
    void snapshotReceived(const QJsonObject &snapshot);
    void inputReceived(const QJsonObject &input);
    void gameOverReceived(const QString &winner);
    void resetGameReceived();
    void isHostChanged();

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    void sendJson(const QJsonObject &obj);
    void processMessage(const QJsonObject &msg);

    QTcpServer *server;
    QTcpSocket *socket;
    bool m_isHost;
};

#endif // NETWORKMANAGER_H