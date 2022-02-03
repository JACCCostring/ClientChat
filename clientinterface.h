#ifndef CLIENTINTERFACE_H
#define CLIENTINTERFACE_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>

class clientInterface : public QObject
{
    Q_OBJECT
public:
    explicit clientInterface(QObject *parent = nullptr);
    //method send message
    Q_INVOKABLE void sendMessage(const QString &, const QString &, qint16);
    Q_INVOKABLE void disconnectFromServer();

private:
    //emthod for fixing message to send
     void fixMessage(QString &);

signals:
    void newMessage(const QString &newMsg);

private slots:
    void onNewDataArrives();

private:
    QTcpSocket *socket;
    bool isConnected = false;
};

#endif // CLIENTINTERFACE_H
