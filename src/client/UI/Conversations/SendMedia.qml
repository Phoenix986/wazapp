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
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Item {

	signal selected(string value)

	Rectangle {
		id: panel
		anchors.fill: parent
		color: theme.inverted? "#1A1A1A" : "white"
		
		Rectangle {
			height: 1
			width: parent.width
			x:0; y:0
			color: "gray"
			opacity: 0.4
		}

		MouseArea {
			anchors.fill: parent
			//onClicked: selected("nothing")
		}

		ListView {
			anchors.fill: parent
			orientation: ListView.Horizontal
			clip: true

			model: ListModel {
				ListElement { name: "Picture"; value: "pic"; usable: true;}
				ListElement { name: "Picture2"; value: "campic"; usable: true;}
				ListElement { name: "Video"; value: "vid"; usable: true;}
				ListElement { name: "Video2"; value: "camvid"; usable: true;}
				ListElement { name: "Audio"; value: "audio"; usable: true;}
				ListElement { name: "Audio2"; value: "rec"; usable: false;}
				ListElement { name: "Location"; value: "location"; usable: true;}
				ListElement { name: "Contact"; value: "vcard"; usable: true;}
			}

			delegate: Item {
				width: 64
				height: 80
				
				Rectangle {
				    id: background
				    anchors.centerIn: parent
				    width: 64
				    height: 64
				    visible: mouseArea.pressed && usable
				    
				    color: "lightgray"
				}				

				Image {
					id: image
					source: "../common/images/send-" + value + (theme.inverted? "-white" : "") + ".png"
					width: 48
					height: 48
					smooth: true
					anchors.centerIn: parent
					opacity: usable? 1 : 0.5
				}

				MouseArea {
				    id: mouseArea
				    anchors.fill: parent
				    onClicked: {
						if (usable) selected(value)
				    }
				}
			}


		}

	}

}

