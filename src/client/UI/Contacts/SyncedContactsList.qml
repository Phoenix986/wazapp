// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common"
import "../common/WAListView"

WAPage{
    id:contactsSelectorPage
    property alias title:header.title
    property alias multiSelectmode:contactlist.multiSelectMode
    
    signal selected(variant selectedItem);
    
    function getSelected(){
	return contactlist.getSelected()
    }
    
    function resetSelections(){
	contactlist.resetSelections()
    }
    
    function positionViewAtBeginning (){
	contactlist.positionViewAtBeginning()
    }
    
    function unbindSlots(){
	selected.disconnect()
	contactlist.model = getContacts()
    }
    
    function setMixedModel(){
	consoleDebug("setMixedModel called")
	mixedModel.clear()
	var contactsmodel = getContacts()
	var groupsmodel = getGroups()
	for (var i=0; i<contactsmodel.count; i++){
	    mixedModel.append(contactsmodel.get(i))
	}
	for (var i=0; i<groupsmodel.count; i++){
	    mixedModel.append(groupsmodel.get(i))
	}
	contactlist.model = mixedModel;
    }
    
    function select(ind){return contactlist.select(ind);}
    function unSelect(ind){return contactlist.unSelect(ind);}
    
    ListModel{
	id: mixedModel
    }    
    
    WAHeader{
	id:header
	anchors.top:parent.top
	width:parent.width
	height: 73
    }
    
    WAListView{
	id: contactlist
	defaultPicture: defaultProfilePicture
	anchors.top:header.bottom
	useRoundedImages: false
	
	onSelected:{ consoleDebug("from contacts"); contactsSelectorPage.selected(selectedItem);}
    }
    
}
