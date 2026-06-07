#ifndef PIPE_H
#define PIPE_H

#include <QObject>
#include <QQmlListProperty>
#include <QPointF>

class Pipe : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(double topHeight READ topHeight WRITE setTopHeight NOTIFY topHeightChanged)
    Q_PROPERTY(double bottomY READ bottomY WRITE setBottomY NOTIFY bottomYChanged)
    Q_PROPERTY(double bottomHeight READ bottomHeight WRITE setBottomHeight NOTIFY bottomHeightChanged)
    Q_PROPERTY(bool passed READ passed WRITE setPassed NOTIFY passedChanged)

public:
    explicit Pipe(QObject *parent = nullptr);

    double x() const;
    void setX(double x);

    double topHeight() const;
    void setTopHeight(double height);

    double bottomY() const;
    void setBottomY(double y);

    double bottomHeight() const;
    void setBottomHeight(double height);

    bool passed() const;
    void setPassed(bool passed);

signals:
    void xChanged();
    void topHeightChanged();
    void bottomYChanged();
    void bottomHeightChanged();
    void passedChanged();

private:
    double m_x;
    double m_topHeight;
    double m_bottomY;
    double m_bottomHeight;
    bool m_passed;
};

#endif // PIPE_H