#include "pipe.h"

Pipe::Pipe(QObject *parent) : QObject(parent),
    m_x(0),
    m_topHeight(0),
    m_bottomY(0),
    m_bottomHeight(0),
    m_passed(false)
{
}

double Pipe::x() const { return m_x; }
void Pipe::setX(double x) {
    if (qFuzzyCompare(m_x, x)) return;
    m_x = x;
    emit xChanged();
}

double Pipe::topHeight() const { return m_topHeight; }
void Pipe::setTopHeight(double height) {
    if (qFuzzyCompare(m_topHeight, height)) return;
    m_topHeight = height;
    emit topHeightChanged();
}

double Pipe::bottomY() const { return m_bottomY; }
void Pipe::setBottomY(double y) {
    if (qFuzzyCompare(m_bottomY, y)) return;
    m_bottomY = y;
    emit bottomYChanged();
}

double Pipe::bottomHeight() const { return m_bottomHeight; }
void Pipe::setBottomHeight(double height) {
    if (qFuzzyCompare(m_bottomHeight, height)) return;
    m_bottomHeight = height;
    emit bottomHeightChanged();
}

bool Pipe::passed() const { return m_passed; }
void Pipe::setPassed(bool passed) {
    if (m_passed == passed) return;
    m_passed = passed;
    emit passedChanged();
}