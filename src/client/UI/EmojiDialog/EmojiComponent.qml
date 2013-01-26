import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "../common/js/Global.js" as Helpers
import "../common/js/settings.js" as MySettings;
import QtMobility.feedback 1.1
import "Components"
import "../common"

Item {
	id: emojiSelector
	visible: false


    property string titleText: qsTr("Select Emoji")
    property string emojiPath:"../common/images/emoji/";
    property string emojiRelativePath; //relative to textfield
    
    property variant emojiTextArea
    property bool inverted: true
    property bool backspaceButton: false
    
    signal selected()
    
    ThemeEffect {
      id: feedbackEffect
      effect: ThemeEffect.BasicButton
    }

    function get32(code){
        var c = ""+code;
        return emojiPath+"32/"+c+".png";
    }
    
    function accept() {
	emojiSelector.visible = false
    }

    function open(textarea, relativePath){
        if(!textarea){
            consoleDebug("NO TEXTAREA SPECIFIED FOR EMOJI, NOT OPENING!")
            return;
        }
        textarea.lastPosition = textarea.cursorPosition
        emojiSelector.emojiTextArea = textarea

        emojiRelativePath = relativePath?relativePath:"/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji"
	emojiSelector.visible = true
        
        emojiList.loadEmoji()
    }

ButtonRow {
    id: emojiCategory
    checkedButton: peopleEmoji
    anchors.left: parent.left
    
    width: parent.width - (backspaceButton?(parent.width/7):0)

    WAButton {
	id: recentEmoji
	property bool readyToFlush: false
	iconSource: get32("E02C");
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 0.0
	    emojiList.loadEmoji()
	}
	onPressAndHold: {
	    feedbackEffect.play()
	    if (readyToFlush){
		flushRecentEmoji()
		readyToFlush = false
		emojiList.offset = 0.0
		emojiList.loadEmoji()
		feedbackEffect.play()
	    }
	    else {
		emojiList.offset = 0.0
		emojiList.loadEmoji()
		readyToFlush = true
	    }
	}
    }

    WAButton {
	id: peopleEmoji
	iconSource: get32("E057");
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 5.0
	    emojiList.loadEmoji()
	}
    }

    WAButton {
	id: natureEmoji
	iconSource: get32("E303");
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 4.0
	    emojiList.loadEmoji()
	}
    }

    WAButton {
	id: placesEmoji
	iconSource: get32("E325")
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 3.0
	    emojiList.loadEmoji()
	}
    }

    WAButton {
	id: objectsEmoji
	iconSource: get32("E036")
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 2.0
	    emojiList.loadEmoji()
	}
    }

    WAButton {
	id: symbolsEmoji
	iconSource: get32("E210")
	exclusiveposition: "horizontal-center"
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 1.0
	    emojiList.loadEmoji()
	}
    }
}
    
WAButton {
    id: backspace
    anchors.left: emojiCategory.right
    height: emojiCategory.height
    width: (parent.width/7)
    visible: backspaceButton
    checkable: false
    inverted: emojiSelector.inverted
    iconSource: "/usr/share/themes/blanco/meegotouch/icons/icon-m-toolbar-backspace" + (inverted?"-white":"") + ".png"
    exclusiveposition: "horizontal-center"
    onClicked: {
	feedbackEffect.play()
	emojiSelector.emojiTextArea.backspace()
    }
}

Rectangle {
    id:emojiContainer
    width: parent.width
    height: emojiSelector.height-emojiCategory.height
    anchors.top:emojiCategory.bottom
    anchors.topMargin: 5
    color: inverted?"black":"white"
    
    PathView {
	property bool emojiload: false
	
	id: emojiList	
	anchors.fill: emojiContainer
	preferredHighlightBegin: 1/6
	preferredHighlightEnd: 2/6
	offset: 0.0
	model: ListModel {
	    ListElement { emjstart:0; emjend:0; recent: true }
	    ListElement { emjstart:0; emjend:188; recent: false }
	    ListElement { emjstart:189; emjend:304; recent: false }
	    ListElement { emjstart:305; emjend:534; recent: false }
	    ListElement { emjstart:535; emjend:636; recent: false }
	    ListElement { emjstart:637; emjend:845; recent: false }
	}
	delegate: EmojiView {
	    id: myDelegate
	    height: emojiList.height
	    width: emojiList.width
	    
	    start: emjstart
	    end: emjend
	    showRecent: recent
	    
	    inverted: emojiSelector.inverted
	    
	    onSelected: {
		selectEmoji(code)
		if (showRecent)
		    emojiList.loadEmoji()
	    }
	}
	
	path: Path {
	    startX: -(emojiList.width/2)
	    startY: emojiList.height/2
	    PathLine{
		x: (emojiList.model.count*emojiList.width) - (emojiList.width/2)
		y: emojiList.height/2
	    }
	}
	
	onMovementEnded: loadEmoji()
	
	function loadEmoji() {	    
	    switch (emojiList.offset) {
		    case 0: recentEmoji.checked = true; break
		    case 5: peopleEmoji.checked = true; break
		    case 4: natureEmoji.checked = true; break
		    case 3: placesEmoji.checked = true; break
		    case 2: objectsEmoji.checked = true; break
		    case 1: symbolsEmoji.checked = true; break
		}
	    recentEmoji.readyToFlush = false
	    emojiList.childAt(100, emojiList.height - 20).load()
	}
	
	MouseArea { anchors.fill: parent }
    }
    }


    function selectEmoji(emojiCode){

	var emojiImg = '<img src="'+emojiRelativePath+'/24/'+emojiCode+'.png" />'
	emojiSelector.emojiTextArea.insert(emojiImg)

	addRecentEmoji(emojiCode);

	feedbackEffect.play();
	
	selected()
    }
    
    function addRecentEmoji(emojicode) {

	var emoji = []
	var emojilist = MySettings.getSetting("RecentEmoji", "")

	if (emojilist!="")
		emoji = emojilist.split(',')

	for (var i=0; i<emoji.length; ++i) {
		if (emoji[i]==emojicode) {
			emoji.splice(i,1)
			break;
		}
	}
	emoji.push(emojicode)
	if (emoji.length > 50) {
	    emoji = emoji.slice(emoji.length - 50, emoji.length)
	}
	MySettings.setSetting("RecentEmoji", emoji.toString())
    }
    
    function flushRecentEmoji() {
	MySettings.setSetting("RecentEmoji", "")
    }
}
