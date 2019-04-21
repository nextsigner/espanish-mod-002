import QtQuick 2.0
import QtQuick.Controls 1.2
import QtWebEngine 1.4
import Qt.labs.settings 1.0
import  "../../../"
import '../../../Silabas.js' as Sil
Item {
    id: r
    width: app.an
    height: app.al
    property string uSilPlayed: ''
    property int uYContent: 0
    property bool showFailTools: false

    Settings{
        id: settingsMod002
        category: 'espanish-mod-002'
        property string uText: ''
    }
    Column{
        width: r.width-app.fs
        height: r.height-app.fs*2
        anchors.centerIn: r
        spacing: app.fs*0.5
        Rectangle {
            color: "transparent"
            radius: app.fs*0.1
            border.width: app.fs*0.1
            border.color: app.c2
            width: parent.width-app.fs
            height: app.fs*6
            anchors.horizontalCenter:  r.horizontalCenter
            Flickable{
                id: flickableTextEditor
                width: parent.width
                height: parent.height
                contentWidth: textEditor.width
                contentHeight: textEditor.height
                clip: true

                TextEdit{
                    id: textEditor
                    width: parent.width-app.fs
                    height: contentHeight
                    font.pixelSize: app.fs
                    color: app.c2
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        BotonUX{
            id: botPlay
            text: 'Escuchar las Sìlabas'
            c1:app.c3
            c2:app.c2
            speed: 100
            clip: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClick: {
                settingsMod002.uText=textEditor.text
                prepArrayWord(textEditor.text)
            }
        }
        Rectangle {
            color: "transparent"
            radius: app.fs*0.1
            border.width: app.fs*0.1
            border.color: app.c2
            width: parent.width
            height: r.height-flickableTextEditor.height-botPlay.height-app.fs*2
            clip: true
            anchors.horizontalCenter:  r.horizontalCenter
            Flickable{
                id: flickableSetSil
                width: parent.width
                height: parent.height
                anchors.horizontalCenter:  r.horizontalCenter
                anchors.top: xRowSetSil.bottom
                anchors.topMargin: app.fs
                contentWidth: flowSil.width
                contentHeight: flowSil.height
                Flow{
                    id: flowSil
                    spacing: app.fs*0.1
                    width:  parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int widthSil: app.fs*4
                    Repeater{
                        id: repSil
                        Item{
                            width: modelData!=='|'?botSil.width:app.fs*0.5
                            height: app.fs*2+app.fs*0.5
                            BotonUX{
                                id: botSil
                                anchors.centerIn: parent
                                text: modelData
                                c1:parseInt(app.jsonSilabas[modelData][0])===-1?'red':app.c3
                                c2:parseInt(app.jsonSilabas[modelData][0])===-1?'yellow':app.c2
                                speed: 250
                                clip: false
                                visible: modelData!=='|'
                                onClick: {
                                    r.uSilPlayed=modelData
                                    tReqAbierto.v++
                                    tReqAbierto.restart()
                                    focus= true
                                    ms.arrayWord=[]
                                    ms.playSil(modelData)
                                }
                                Timer{
                                    id: tReqAbierto
                                    running: false
                                    repeat: false
                                    interval: 500
                                    property int v: 0
                                    onTriggered: {
                                        if(v>=2){
                                            parent.abierto=!parent.abierto
                                        }
                                        v=0
                                    }
                                }
                                property bool abierto: false
                                focus: true
                                Keys.onSpacePressed: {
                                    r.addSilFail(modelData)
                                }
                                Keys.onRightPressed: {
                                    ms.mp.stop()
                                }
                                Keys.onLeftPressed: {
                                    ms.mp.stop()
                                }
                                Keys.onUpPressed: {
                                    ms.mp.stop()
                                }
                                Keys.onDownPressed: {
                                    ms.mp.stop()
                                }
                                Keys.onReturnPressed:  {
                                    ms.mp.play()
                                }
                                Rectangle{
                                    id: rect
                                    width: parent.width
                                    height: parent.height
                                    color: 'transparent'
                                    border.width: 4
                                    border.color: 'yellow'
                                    anchors.centerIn: parent
                                    visible: parent.abierto
                                }
                                Component.onCompleted: {
                                    if((''+modelData).indexOf('!')>0){
                                        c1='red'
                                        c2='yellow'
                                        parent.visible=false
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
    WebEngineView{
        id: wv
        width: r.width/2
        height: r.height
        anchors.right: r.right
        visible: false
        zoomFactor: 1.5
        onLoadProgressChanged:{
            xApp.focus=true
            if(loadProgress===100){
                wv.runJavaScript('function aaa(){var datos= document.body.innerHTML;return datos;};aaa();', function(result) {
                    var t1=(''+result).replace(/\n/g,'')
                    var t2=(''+t1).replace(/ /g,'')
                    var narraySils=t2.split('#@#')
                    var sils=[]
                    for(var i=0; i<narraySils.length;i++){
                        var s=narraySils[i]
                        if(s!==':'&&s!==';'&&s!=='?'){
                            if((''+narraySils[i]).indexOf(',')>=0){
                                sils.push((narraySils[i]).replace(/\,/g,''))
                                sils.push('|')
                                sils.push('|')
                            }else if((''+narraySils[i]).indexOf('.')>=0){
                                sils.push((narraySils[i]).replace(/\./g,''))
                                sils.push('|')
                                sils.push('|')
                                sils.push('|')
                                sils.push('|')
                            }else{
                                sils.push(narraySils[i])
                            }
                        }
                    }
                    repSil.model=sils
                    ms.uNumSilPlay=0
                    ms.arrayWord=sils
                    ms.playSil(ms.arrayWord[0])
                });
            }
        }
    }

    function prepArrayWord(t){
        var html='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
    "http://www.w3.org/TR/html4/strict.dtd">
<html lang="es">
    <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">

    </head>
    <body>
        <script src="silabajs.js"></script>
        <script>
            var silabas = [];
            var msil=[];
'
        var tc1=t.replace(/á/g, 'a')
        tc1=tc1.replace(/é/g, 'e')
        tc1=tc1.replace(/í/g, 'i')
        tc1=tc1.replace(/ó/g, 'o')
        tc1=tc1.replace(/ú/g, 'u')
        tc1=tc1.replace(/\n/g, ' ')
        tc1=tc1.replace(/(/g, ' ( ')
        tc1=tc1.replace(/)/g, ' ) ')
        tc1=tc1.replace(/{/g, ' { ')
        tc1=tc1.replace(/}/g, ' } ')
        tc1=tc1.replace(/\|/g, ' | ')
        tc1=tc1.replace(/\?/g, ' ? ')
        tc1=tc1.replace(/\¿/g, ' ¿ ')
        tc1=tc1.replace(/\@/g, ' @ ')
        tc1=tc1.replace(/\#/g, ' # ')
        tc1=tc1.replace(/\!/g, ' ! ')
        tc1=tc1.replace(/;/g, ' ; ')
        tc1=tc1.replace(/:/g, ' : ')
        var m0=tc1.split(' ')
        for(var i=0;i<m0.length;i++){
            html+='var w'+i+' = silabaJS.getSilabas(\''+m0[i]+'\');\n'

            html+='for(var i=0; i<w'+i+'.silabas.length;i++){\n';
            html+='     msil.push(w'+i+'.silabas[i].silaba);\n';
            html+='}\n';
            html+='     msil.push(\'|\');\n';
        }
        html+='     document.body.innerHTML=msil.join(\"#@#\");\n';

        html+='</script></body>
    </html>'
        if(!unik.fileExist('m2000/s3/espanish-mod-002/htmls')){
            unik.mkdir('m2000/s3/espanish-mod-002/htmls')
        }
        var js=unik.getFile('m2000/s3/espanish-mod-002/silabajs.js')
        unik.setFile('m2000/s3/espanish-mod-002/htmls/silabajs.js', js)
        var d=new Date(Date.now())
        unik.setFile('m2000/s3/espanish-mod-002/htmls/'+d.getTime()+'.html', html)
        wv.url='./htmls/'+d.getTime()+'.html'
        //textEditor.text=wv.url
    }
    Component.onCompleted: {
        if(!settingsMod002.uText||settingsMod002.uText===''){
            settingsMod002.uText='Escriba aquì un texto'
        }
        textEditor.text=settingsMod002.uText
        controles.visible=false
    }
}
