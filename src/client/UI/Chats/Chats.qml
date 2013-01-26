/***************************************************************************
**
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
import QtQuick 1.1
import com.nokia.meego 1.0

import "js/chats.js" as ChatScript
import "../common/js/classes.js" as Components
import "../common/js/Global.js" as Helpers
import "../common"
import "../Menu"

WAPage {
    id: chatsContainer
    property alias indicator_state:wa_notifier.state

	property string contactNumber
	property bool contactNumberGroup

    signal deleteConversation(string jid);

    function getOrCreateConversation(jid){


        var conversation = findConversation(jid);
        if(conversation)
            return conversation;

        consoleDebug("CONV: NOT FOUND")
        conversation = new Components.Conversation(appWindow).view;
        conversation.jid = jid;


        //consoleDebug("APPENDING");
        conversationsModel.append({conversation:conversation})

        //consoleDebug("RETURNING")
        return conversation;
    }

    function moveToCorrectIndex(jid) { 
		ChatScript.moveToCorrectIndex(jid);
		//chatsList.positionViewAtBeginning()
	}

    function getConversation(jid){

        //consoleDebug("FIND");
        var conversation = findConversation(jid);
        if(conversation)
            return conversation;

        return false;
    }
    function removeChatItem(jid){

        var chatItemIndex = findChatIem(jid);
        consoleDebug("deleting")
        if(chatItemIndex >= 0){
            var conversation = conversationsModel.get(chatItemIndex).conversation;
            var contacts = conversation.getContacts();

            for(var i=0; i<contacts.length; i++){

                contacts[i].unsetConversation();
            }

            delete conversation;

            conversationsModel.remove(chatItemIndex);
			checkUnreadMessages()
        }
    }

    function findChatIem(jid){
        for (var i=0; i<conversationsModel.count;i++)
        {
            var chatItem = conversationsModel.get(i);

            if(chatItem.conversation.jid == jid)
                   return  i;
        }
        return -1;
    }

    function findConversation(jid){

        var chatItemIndex = findChatIem(jid);

        if(chatItemIndex >= 0)
            return conversationsModel.get(chatItemIndex).conversation;

        return 0
    }
    
    Item { id: dummy }

    function hideSearchBar() {
        searchbar.height = 0
        searchInput.enabled = false
        sbutton.enabled = false
        searchInput.text = ""
        searchInput.platformCloseSoftwareInputPanel()
	searchInput.enabled = false
        timer.stop()
    }
    
    Timer {
        id: timer
        interval: 5000
        onTriggered: {
            if (searchInput.text==="") hideSearchBar()
        }
    }

    function showSearchBar() {
        searchbar.height = 71
        searchInput.enabled = true
        sbutton.enabled = true
        searchInput.text = ""
        searchInput.enabled = true
        dummy.focus = true
        timer.start()
    }

    //ListModel{id:conversationsModel}


    Component{
        id:chatsDelegate;

        Chat{
	    id: chatsDelegateItem
	    property bool filtered: Helpers.getCode(title)[0].match(new RegExp(searchInput.text,"i")) != null
	    Component.onCompleted: {
                setConversation(model.conversation);
            }
	    height: filtered ? 102 : 0
	    visible: height!=0
            width:chatsContainer.width
            onOptionsRequested: {
                chatMenu.jid = getConversation().jid;

                if(!isGroup){
                    chatMenu.number = getConversation().getContacts()[0].contactNumber;
                    chatMenu.name =  getConversation().getContacts()[0].contactName;
                }
                else
                    chatMenu.number = "";

				contactNumber = chatMenu.jid.split('-')[0].split('@')[0]
				contactNumberGroup = isGroup

				profileUser = chatMenu.jid
                chatMenu.open();
            }

       }
    }


	WAHeader{
		id: header
        title: qsTr("Chats")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

    Column{
        anchors.top: header.bottom
		anchors.left: parent.left
        spacing: 0
        width: parent.width
        height: parent.height - header.height
        WANotify{
            id:wa_notifier
        }
        
        Rectangle {
		id: searchbar
		width: parent.width
		height: 0
		anchors.top: parent.top
		anchors.topMargin: wa_notifier.height
		color: "transparent"
		clip: true

		Rectangle {

			id: srect
			anchors.fill: searchbar
			anchors.leftMargin: 12
			anchors.rightMargin: 12
			anchors.top: searchbar.top
			anchors.topMargin: searchbar.height - 62
			anchors.bottomMargin: 2
			color: "transparent"
            opacity: searchbar.height==0 ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 400 } }

			TextField {
			    id: searchInput
			    inputMethodHints: Qt.ImhNoPredictiveText
			    placeholderText: qsTr("Quick search")
			    anchors.top: srect.top
			    anchors.left: srect.left
			    width: parent.width
			    enabled: false
			    onTextChanged: timer.restart()
			}

			Image {
			    id: sbutton
			    smooth: true
			    anchors.top: srect.top
			    anchors.topMargin: 1
			    anchors.right: srect.right
			    anchors.rightMargin: 4
			    height: 52
			    width: 52
			    enabled: false
			    source: searchInput.text==="" ? "image://theme/icon-m-common-search" : "image://theme/icon-m-input-clear"
			    MouseArea {
			        anchors.fill: parent
			        onClicked: {
			            searchInput.text = ""
			            searchInput.forceActiveFocus()
			        }
			    }
			}

		}

        Behavior on height { NumberAnimation { duration: 200 } }

	}
        
        Item{
            width:parent.width
            height:parent.height-wa_notifier.height
            visible:chatsList.count==0

            Label{
                anchors.centerIn: parent;
                text: qsTr("No conversations yet")
                font.pointSize: 26
				color: "gray"
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: chatsList
            //anchors.fill: parent
            width:parent.width
            height:parent.height-wa_notifier.height
            model: conversationsModel
            delegate: chatsDelegate
            spacing: 1
            clip:true
            cacheBuffer: 10000
			//onCountChanged: chatsList.positionViewAtBeginning()
			
	    onContentYChanged:  {
                if ( chatsList.visibleArea.yPosition < 0)
                {
                    if ( searchbar.height==0 )
                        showSearchBar()
                }
            }
        }
    }

	Menu {
        id: chatMenu
        property string name;
        property string jid;
        property string number;

        MenuLayout {

            WAMenuItem {
                height: 80
                //singleItem: !detailsMenuItem.visible
                text: contactNumberGroup? qsTr("Delete and exit group") : qsTr("Delete Conversation")
                onClicked: {
					if (contactNumberGroup) {
						chatDelAndExitConfirm.open()
					} else {
						chatDelConfirm.open()
					}
				}
            }

			WAMenuItem {
				id: profileMenuItem
				height: visible ? 80 : 0
				//visible: !contactNumberGroup
				text: contactNumberGroup? qsTr("View group information") : qsTr("View contact profile")
				onClicked: {
					if (contactNumberGroup)
                    {
                        //mainPage.pageStack.push (Qt.resolvedUrl("../Groups/GroupProfile.qml"))
                        var conversation = waChats.getOrCreateConversation(chatMenu.jid)

                        conversation.openProfile();
                    }
                    else {
                        var contact = waContacts.getOrCreateContact({"jid":chatMenu.jid});
                        contact.openProfile();
                        //mainPage.pageStack.push (Qt.resolvedUrl("../Contacts/ContactProfile.qml"))

                    }
				}
			}

        }
	}

    QueryDialog {
        id: chatDelConfirm
        titleText: qsTr("Confirm Delete")
        message: qsTr("Are you sure you want to delete this conversation and all its messages?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: {
            deleteConversation(chatMenu.jid)
            removeChatItem(chatMenu.jid)
        }
    }

    QueryDialog {
        id: chatDelAndExitConfirm
        titleText: qsTr("Confirm Delete and Exit")
        message: qsTr("Are you sure you want to delete this conversation and exit this group?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: endGroupChat(chatMenu.jid)
    }

	Connections {
		target: appWindow
		onGroupEnded: {
            deleteConversation(chatMenu.jid)
            removeChatItem(chatMenu.jid)
		}
		onUpdateChatItemList: {
			chatsList.positionViewAtBeginning()
		}
	}

}
