import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Controls 1.4
import QtMultimedia 5.5
import QtQml 2.0

Window {
    id: mainFrame
    width: 490
    height: 602
    maximumWidth: 490
    minimumWidth: 490
    maximumHeight: 602
    minimumHeight: 602
    visible: true
    title: qsTr("Chatter")
    color: "GhostWhite"
    //effect for kewPress
    SoundEffect{
        id: keyPressEffect
        volume: 0.1
        source: "qrc:/soundEffects/keyPress.wav"
    }
    //effect for receivedMessage
    SoundEffect{
        id: messageReceivedEffect
        volume: 0.2
        source: "qrc:/soundEffects/receivedMessage.wav"
    }
    //number animation for apearing effect for IP
    NumberAnimation {
        id: animationForIP
        targets: serverIP
        properties: "opacity"
        duration: 1000
        running: false
        from: serverIP.opacity == 0.0 ? 0.0 : 1.0
        to: serverIP.opacity == 0.0 ? 1.0 : 0.0
    }
    //number animation for apearing effect for PORT
    NumberAnimation {
        id: animationForPort
        targets: portServer
        properties: "opacity"
        duration: 1000
        running: false
        from: portServer.opacity == 0.0 ? 0.0 : 1.0
        to: portServer.opacity == 0.0 ? 1.0 : 0.0
    }
    //splitter
    SplitView{
        anchors.fill: parent
        orientation: ListView.Vertical
        //list view for all client messages
        ListView{
            id: listViewMessages
            width: 300
            height: 560
            spacing: 1.3
            model: ListModel{
                id:listModelData
                ListElement{msg: "Welcome to Chatter"}
            }
            //vertical ScrollBar
            ScrollBar.vertical: ScrollBar{}
            //delegate for data UI
            delegate: Rectangle{
                width: textRectangle.width + 10
                height: 40
                radius: 25
                color: "lightslategray"
                Text {
                    id: textRectangle
                    anchors.centerIn: parent
                    text: msg
                    color: "LightSkyBlue"
                    font.bold: true
                }
            }
            MouseArea{
                id:mouseAreaListView
                anchors.fill: parent
                onDoubleClicked: {
                    if(! serverIP.enabled) {
                        serverIP.enabled = true
                        portServer.enabled = true
                        //make opacity 1.0 for reapearing effect
                        animationForIP.running = true
                        animationForPort.running = true
                    }
                    else{
                        serverIP.enabled = false
                        portServer.enabled = false
                        //make opacity 0.0 for disapearing effect
                        animationForIP.running = true
                        animationForPort.running = true
                    }
                }
            }
        }//end of list view
        Row{
            spacing: 1.5
            //textfield for server
            TextField{
                id: serverIP
                text: "192.168.10.187"
                height: 40
                enabled: false
                opacity: 0.0
                //if any change in IP then disconnect
                onAccepted: networkInterface.disconnectFromServer()
            }
            //SpinBox for server
            SpinBox{
                id: portServer
                height: 40
                maximumValue: 65000
                minimumValue: 1
                enabled: false
                value: 4444
                opacity: 0.0
                //if any change in SpinBox for port then
                onValueChanged: networkInterface.disconnectFromServer()
            }
            //text field for bodymessage
            TextField{
                id: bodyMessage
                placeholderText: "body message here ..."
                width: mainFrame.width
                height: 40
                focus: true
                //event when entered
                onAccepted: {
                    if(bodyMessage.text != ""){
                        networkInterface.sendMessage(bodyMessage.text, serverIP.text, portServer.value)
                        bodyMessage.text = ""
                    }
                }
                onTextChanged: keyPressEffect.play()
            }
        }//end of row
    }//end of split view
    //Connections from backend C++
    Connections{
        target: networkInterface
        onNewMessage: {
            listModelData.append( {msg: newMsg} )
            messageReceivedEffect.play() //play sound effect for messageReceivedEffect
        }
    }
}//end of code
