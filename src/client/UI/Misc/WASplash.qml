// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common"
import com.nokia.meego 1.0
WAPage {

    property string operation:qsTr("Initializing")
    property string subOperation:""
    property string version
    property int stage: 0
    orientationLock: PageOrientation.LockPortrait
    property int curProgress
    property int maximumValue
    property bool showSubProgress: true
    property int position: 0

    function setCurrentOperation(op) {
		subOperation = ""
		operation = qsTr(op)
    }
    
    function nextStage() {
	curProgress=1
	stage++
	position=1
	console.log("nextStage: " + stage)
    }

    function setSubOperation(subop) {
        subOperation = subop
    }

    function setProgressMax(val) {
	maximumValue = val
    }
    
    function step() {
	if (position+1 <= maximumValue) {
	    position++
	    setProgress(position)
	    setOpacity(position)
	}
    }

    function setProgress(val) {
	    var part = 100/maximumValue
	    curProgress = parseInt(part*val /10)
	    console.log("setProgress: " + curProgress)
    }

    function setOpacity(val) {
	    var part = myBackgroundOpacity/maximumValue/10.0
	    background.opacity = part*val
    }

    onStatusChanged: {
      /*  if(status == PageStatus.Activating){
            appWindow.showStatusBar = false
            appWindow.showToolBar = false
        } else if(status == PageStatus.Deactivating) {
              appWindow.showStatusBar = true
              appWindow.showToolBar = true
        }*/
    }
    
    Rectangle {
	id: name
	anchors.fill: parent
	color: theme.inverted?"black":"white"
	
	Image {
	    id: background
	    anchors.fill: parent
	    source: myBackgroundImage!="none" ? WAConstants.CACHE_PATH+"/"+"background.jpg" + "?ran=" + Math.random() : ""
	    fillMode: Image.PreserveAspectCrop
	    opacity: 0
	}
	
	Image {
	    id: progress
	    width: 180
	    height: 180
	    anchors.left: parent.left
	    anchors.top: parent.top
	    anchors.topMargin: 246
	    anchors.leftMargin: 150
	    source: getSource()
	    
	    function getSource() {
		var img = "images/" + stage + curProgress + "0.png"
		console.log(img)
		return img
	    }
	}
    }

    Column{
	id: textColumn
        width:parent.width
	spacing: 20
        y:450

        Label{
            text:operation
            color: "gray"
            horizontalAlignment: Text.AlignHCenter
            //font.bold: true
            width:parent.width
        }

        Label{
            text:subOperation
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            width:parent.width
            visible: showSubProgress
        }
    }

    Label{
	id: verlabel
        text:version
        width:parent.width
        horizontalAlignment: Text.AlignHCenter
        color:"#269f1a"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
	opacity: 0.8
    }

}
