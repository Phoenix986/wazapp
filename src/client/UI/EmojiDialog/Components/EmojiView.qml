import "../js/emojihelper.js" as EmojiHelper;
import "../../common/js/Global.js"as Helpers;
import "../../common/js/settings.js" as MySettings;
import QtQuick 1.1
import com.nokia.meego 1.0

GridView{
    id: emojiView

    property int start;
    property int end;
    
    property bool showRecent: false
    property int recentCount: 0
    
    property bool inverted: true
    
    signal selected(string code)

    visible:true
    clip: true
    cellWidth: 60
    cellHeight: 60
    
    model: ListModel { id: emojiModel }
    
    Component {
	id: emojiDelegate
	Rectangle {
	    width: 59
	    height: 59
	    color: emojiArea.pressed ? "#27a01b":(inverted?"#3c3c3b":"lightgray")
	    
	    Image {
		id: emojiImage
		anchors.centerIn: parent
		width: 32
		height: 32
		smooth: false
		cache: true
		asynchronous: true
		source: emote
	    }
	    
	    MouseArea {
		id: emojiArea
		anchors.fill: parent
		onClicked: emojiView.selected(code)
	    }
	}
	
    }
    
    delegate: emojiDelegate
    
    function get32(code){
        var c = ""+code;
        return "../../common/images/emoji/32/"+c+".png";
    }
     
    function loadRecentEmoji(){	
	var emojilist= MySettings.getSetting("RecentEmoji", "")

	var emoji = []
	if (emojilist!="")
		emoji = emojilist.split(',')
	recentCount = emoji.length
	    
	while (emoji.length > 0)
	{
	    var code = emoji.pop()
	    emojiModel.append({"emote":get32(code), "code":code});
	}
    }
     
    function loadEmojiPage() {
	var myend = end+1
	for (var i=start; i<myend; i++)
	{
	    var code = Helpers.emoji_code[i]
	    emojiModel.append({"emote":get32(code), "code":code})
	}
    }
    
    function load() {
	var oldY = emojiView.contentY
	emojiModel.clear()
	if (showRecent)
	    loadRecentEmoji()
	else
	    loadEmojiPage()

	visible = true
	emojiView.contentY = oldY
    }
    
    function hide() {
	visible = false
    }
}

