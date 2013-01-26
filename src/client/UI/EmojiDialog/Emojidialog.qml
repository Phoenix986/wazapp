import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.feedback 1.1

Dialog {
	id: emojiSelector
	
	width: parent.width
	height: parent.height


    property string titleText: qsTr("Select Emoji")
    property string emojiRelativePath; //relative to textfield

    function openDialog(textarea, relativePath){
        if(!textarea){
            consoleDebug("NO TEXTAREA SPECIFIED FOR EMOJI, NOT OPENING!")
            return;
        }
        textarea.lastPosition = textarea.cursorPosition

        emojiRelativePath = relativePath?relativePath:"/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji"

        emojiComponent.open(textarea,emojiRelativePath);
	emojiSelector.open()
    }
    
	SelectionDialogStyle { id: selectionDialogStyle }

    title: Item {
    	id: header
        height: selectionDialogStyle.titleBarHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Item {
            id: labelField
            anchors.fill:  parent

            Item {
                id: labelWrapper
                anchors.left: labelField.left
                anchors.right: closeButton.left
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin
                height: titleLabel.height

                Label {
                    id: titleLabel
                    x: selectionDialogStyle.titleBarIndent
                    width: parent.width - closeButton.width
                    font: selectionDialogStyle.titleBarFont
                    color: selectionDialogStyle.commonLabelColor
                    elide: selectionDialogStyle.titleElideMode
                    text: emojiSelector.titleText
                }

            }

            Image {
                id: closeButton
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin-6
                anchors.right: labelField.right
                opacity: closeButtonArea.pressed ? 0.5 : 1.0
                source: "image://theme/icon-m-common-dialog-close"

                MouseArea {
                    id: closeButtonArea
                    anchors.fill: parent
                    onClicked:  {emojiSelector.reject();}
                }
            }
        }

        Rectangle {
            id: headerLine
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom:  header.bottom
            height: 1
            color: "#4D4D4D"
        }

    }
    
    content: EmojiComponent {
		id: emojiComponent
		width: parent.width
		height: emojiSelector.height-200

		inverted: true
		visible: false
		
		onSelected: {
		    emojiComponent.accept()
		    emojiTextArea.forceActiveFocus();
		    emojiSelector.accept()
		}
	    }
}
