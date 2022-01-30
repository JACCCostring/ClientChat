#include "clientinterface.h"

clientInterface::clientInterface(QObject *parent) : QObject(parent)
{
    //initializing socket
    socket = new QTcpSocket(this);
}

void clientInterface::sendMessage(const QString &message, const QString &ip, qint16 port)
{
    //checking if socket is closed if not then instance new obj
    if(! socket->isOpen())
        socket = new QTcpSocket(this);
    //if isConnected is false then re-connect again to server host
    if(! isConnected){
    socket->connectToHost(ip, port);//connecting to host with IP and Port
    isConnected = true;
    }
    //sending message to socket
    if(isConnected)
    socket->write(message.toUtf8());
    //connecting signals when new data arrives from server
    connect(socket, &QTcpSocket::readyRead, this, &clientInterface::onNewDataArrives);
}

void clientInterface::disconnectFromServer()
{
    if(isConnected){ //if client connected to host server then disconnect
    socket->disconnectFromHost(); //disconnecting from server host
    socket->close(); //closing connection
    isConnected = false; //isConnected is false
    qDebug()<<"disconnecting from server";
    }
}

void clientInterface::fixMessage(QString &message)
{
    //making sure message only contains the wannted body, not extra "\n"
    QStringList allowedList = message.split("\n"); //splitting all lines by "\n"
    for(QString &list: allowedList){
        if(list != ""){ //if the reading line it doesn't contains space or "\n" then
            //emiting signal with fixed data to QML side
            emit newMessage(list);
        }
        message.clear();
    }
}

void clientInterface::onNewDataArrives()
{
    //referencing from caller same socket
    QTcpSocket *socketForMessages = qobject_cast<QTcpSocket *>(sender());
    //saving content in variable to avoid data lost since QTcpSocket is asynchronous
    QString message = socketForMessages->readAll();
    //calling to fix obtained message
    fixMessage(message);
}
