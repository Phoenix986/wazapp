/***************************************************************************
 * *
 ** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
 **
 ** This file is part of Wazapp, an IM application for Meego Harmattan
 ** platform that allows communication with Whatsapp users.
 **
 ** Wazapp is free software: you can redistribute it and/or modify it under
 ** the terms of the GNU General Public License as published by the
 ** Free Software Foundation, either version 2 of the License, or
 ** (at your option) any later version.
 **
 ** Wazapp is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 ** See the GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with Wazapp. If not, see http://www.gnu.org/licenses/.
 **
 ****************************************************************************/
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/Global.js" as Helpers
import "."
import "WAListView"
import "../Profile"
import "js/broadcast.js" as BroadcastHelper

WAPage {
    id:container
    
    //anchors.fill: parent
    
    
    property string jid;
    property bool working: false
    property bool loaded;
    property int addedCount;
    property int removedCount;
    property bool waitForRemove;
    property bool waitForAdd;
    
    
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"
    
    states: [
    State {
	name: "landscape"
	
	PropertyChanges{target:groupInfoContainer;  parent:rowContainer;  width:rowContainer.width/2}
	PropertyChanges { target: participantsColumn;  parent:rowContainer;  height:rowContainer.height; width:rowContainer.width/2}
	
	
    },
    State {
	name: "portrait"
	PropertyChanges{target:groupInfoContainer;  parent:columnContainer; width:columnContainer.width}
	PropertyChanges { target: participantsColumn; parent:columnContainer; height:container.height-groupInfoContainer.height; width:columnContainer.width}
    }
    ]
    
    function resetEdits(){
	genericSyncedContactsSelector.resetSelections()
	genericSyncedContactsSelector.unbindSlots()
	genericSyncedContactsSelector.positionViewAtBeginning()
	
	BroadcastHelper.added = new Array();
	BroadcastHelper.removed = new Array();
	
    }
    
    onStatusChanged: {
	if(status == PageStatus.Activating){	    
	    genericSyncedContactsSelector.tools = participantsSelectorTools
	    container.resetEdits()
	}
    }
    
    tools: ToolBarLayout {
	id: toolBar
	ToolIcon {
	    platformIconId: "toolbar-back"
	    onClicked: pageStack.pop()
	}
	ToolButton
	{
	    width: 300
	    text: qsTr("Send")
	    anchors.verticalCenter: parent.verticalCenter
	    anchors.horizontalCenter: parent.horizontalCenter
	    enabled: !working && (addedCount || removedCount)
	    onClicked: {
		
		runIfOnline(function(){
		    
		    working = true
		    
		    var broadcastAtOnce = 10
		    var broadcastNumber = 0
		    
		    var toSend = broadcast_text.getCleanText();
		    var res = toSend[0].trim();
		    if (res != "") {
			for(var i=0; i<participantsModel.count; i++){
			    broadcastNumber++
			    appWindow.sendTyping(participantsModel.get(i).jid)
			    if (broadcastNumber==5){
				sleep(1)
				broadcastNumber=0
			    }
			    appWindow.sendMessage(participantsModel.get(i).jid, Helpers.unicodeEscape(res))
			    appWindow.sendPaused(participantsModel.get(i).jid)
                        }
		    }		    
		    
		    pageStack.pop()
		    working = false
		    
		}, true);
		
		
	    }
	}
	
    }
    
    Row{
	id:rowContainer
	anchors.fill: parent
	anchors.margins: 5
    }
    
    Column{
	id: columnContainer
	anchors.fill: parent
	anchors.margins: 5
	spacing:10
    }
    
    Column {
	id:groupInfoContainer
	anchors.leftMargin: 16
	anchors.rightMargin: 16
	spacing: 12
	
	WAHeader{
	    title: qsTr("Broadcast message")
	    anchors.top:parent.top
	    width:parent.width
	    height: 73
	}
	
	WATextArea {
	    id: broadcast_text
	    width:parent.width
	    wrapMode: TextEdit.Wrap
	    textFormat: Text.RichText
	    textColor: "black"
	    onActiveFocusChanged: { 
		lastPosition = broadcast_text.cursorPosition 
		consoleDebug("LAST POSITION: " + lastPosition)
	    }
	}
	
	WAButton
	{
	    id:emoji_button
	    width:50
	    height:50
	    iconSource: "../common/images/emoji/32/E415.png"
	    onClicked: {
		emojiDialog.openDialog(broadcast_text);
	    }
	}
	
	Separator {
            width: parent.width
            height: 10
        }
    }    
    
    Item{
	id:participantsColumn
	//  width:parent.width
	
	Rectangle {
            x: 16
            width: parent.width - 32
            height: partText.height
            color: "transparent"
            id:participantsHeader

            Label {
                id: partText
                width: parent.width
                color: theme.inverted ? "white" : "black"
                text: qsTr("Broadcast to:")
                font.bold: true
                anchors.verticalCenter: addButton.verticalCenter
            }

            BorderImage {
                id: addButton
                visible: !working
                width: labelText.paintedWidth + 30
                height: 42
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
                        "background" + (bcArea.pressed? "-pressed" : "")
                border { left: 22; right: 22; bottom: 22; top: 22; }
                Label {
                    id: labelText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 22; font.bold: true
                    text: qsTr("Add")
                }
                MouseArea {
                    id: bcArea
                    anchors.fill: parent
                    onClicked: {

                        genericSyncedContactsSelector.resetSelections()
                        genericSyncedContactsSelector.unbindSlots()
                        genericSyncedContactsSelector.positionViewAtBeginning()
                        genericSyncedContactsSelector.setMixedModel()

                        for(var i=0; i<participantsModel.count; i++){
                           var p = participantsModel.get(i)

                            if(p.relativeIndex >= 0)
                                genericSyncedContactsSelector.select(participantsModel.get(i).jid)
                        }

                        genericSyncedContactsSelector.multiSelectmode = true
                        genericSyncedContactsSelector.title = qsTr("Broadcast to")
                        pageStack.push(genericSyncedContactsSelector);
                    }
                }
            }
	}
	
	
	WAListView{
		id:groupParticipants
		defaultPicture:defaultProfilePicture
		anchors.top:participantsHeader.bottom
		anchors.topMargin: 5
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		allowRemove: true
		allowSelect: false
		allowFastScroll: false
		emptyLabelText: qsTr("Select partiicipants broadcast to")
		
		onRemoved: {
		    
		    var rmItem = participantsModel.get(index)
		    
		    genericSyncedContactsSelector.unSelect(rmItem.jid)
		    
		    
		    if(BroadcastHelper.currentParticipantsJids.indexOf(rmItem.jid) >= 0 ) {
			BroadcastHelper.removed.push(rmItem.jid)
			removedCount=BroadcastHelper.removed.length
		    }
		    else {
			
			BroadcastHelper.added.splice(BroadcastHelper.added.indexOf(rmItem.jid),1)
			addedCount = BroadcastHelper.added.length
		    }
		    groupParticipants._removedCount--;
		    participantsModel.remove(index);
		}
		
		model:participantsModel
		
	}
	
	
    }
    
    ListModel {
	id: participantsModel
    }
    
    
    ToolBarLayout {
	id:participantsSelectorTools
	visible:false
	
	ToolIcon{
	    platformIconId: "toolbar-back"
	    onClicked: pageStack.pop()
	}
	
	ToolButton
	{
	    anchors.horizontalCenter: parent.horizontalCenter
	    anchors.centerIn: parent
	    width: 300
	    text: qsTr("Done")
	    onClicked: {
		consoleDebug("GEtting selected")
		var selected = genericSyncedContactsSelector.getSelected()
		consoleDebug("Selected count: "+selected.length)
		participantsModel.clear()
		groupParticipants.reset()
		
		BroadcastHelper.added.length = 0
		BroadcastHelper.removed.length = 0
		var found;
		for(var i=0; i<BroadcastHelper.currentParticipantsJids.length; i++){
		    found = false;
		    for(var j=0; j<selected.length; j++){
			if(BroadcastHelper.currentParticipantsJids[i] == selected[j].data.jid) {
			    found = true;
			    break;
			}
		    }
		    
		    if(!found){
			BroadcastHelper.removed.push(BroadcastHelper.currentParticipantsJids[i])
		    }
		}
		
		for(var i=0; i<selected.length; i++){
		    
		    if(BroadcastHelper.currentParticipantsJids.indexOf(selected[i].data.jid) == -1)
			BroadcastHelper.added.push(selected[i].data.jid)
		}
		
		console.log("Added: "+BroadcastHelper.added.join(","))
		console.log("Removed:"+BroadcastHelper.removed.join(","))
		
		addedCount = BroadcastHelper.added.length
		removedCount = BroadcastHelper.removed.length
		var modelData;
		for(var i=0; i<selected.length; i++) {
		    consoleDebug("Appending")
		    if (selected[i].data.jid != myAccount && i<25) {
			modelData = {name:selected[i].data.name, picture:selected[i].data.picture, jid:selected[i].data.jid, relativeIndex:selected[i].selectedIndex};
			participantsModel.append(modelData)
		    }
		}
		
		pageStack.pop()
	    }
	}
	
    }
    
}
