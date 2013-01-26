/****************************************************************************
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

Item {
	id: container

	property bool selected
	property string imagenum
	signal clicked()


	Item {
		width: parent.width -2
		height: parent.height -2
		anchors.centerIn: parent
		clip: true

		Image {
			source: "../Conversations/images/bubbles/incoming" + imagenum + "-normal.png"
			anchors.centerIn: parent
			height: 96; width: 96
			smooth: true
		}	

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			onClicked: container.clicked()
		}

		Rectangle {
			x: 1; y: 1
			border.width: 3
			height: parent.height - border.width
			width: parent.width - border.width
			color: "transparent"
			border.color: theme.inverted? "white" : "black"
			visible: mouseArea.pressed || selected
		}
	}
} 
