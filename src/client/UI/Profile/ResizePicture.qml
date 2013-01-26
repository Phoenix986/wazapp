import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/settings.js" as MySettings
import "../common/js/Global.js" as Helpers
import "../common"

WAPage {
    id: container
    
    property string picture
    property int maximumSize
    property int minimumSize
    property bool avatar: true
    
    property string filename
    
    signal selected()

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: {
		pageStack.pop();
	    }
        }
        
        ToolIcon {
            platformIconId: "toolbar-refresh4"
            onClicked: {
		pinch.rotate()
	    }
        }
        
	ToolIcon {
            id: doneButton
            platformIconId: "toolbar-done"
	    onClicked: {
	      transformPicture(picture, WAConstants.CACHE_PATH+"/"+filename, pinch.rectX, pinch.rectY, pinch.rectW, pinch.rectH, maximumSize, pinch.angle)
	      selected()
	    }
	}
    }

    InteractionArea {
	id: pinch
	anchors.fill: parent
	anchors.topMargin: avatar?header.height:-appWindow.__statusBarHeight
	anchors.bottomMargin: avatar?0:-appWindow.platformToolBarHeight
	avatar: container.avatar
	source: picture
	bucketMinSize: minimumSize
    }
    
    WAHeader{
	id: header
	title: qsTr("Change picture")
	anchors.top:parent.top
	width:parent.width
	height: 73
    }
}
