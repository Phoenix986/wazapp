#from QtMobility.SystemInfo import QSystemDeviceInfo,QSystemNetworkInfo
#from QtMobility.Messaging import QMessageManager, QMessage, QMessageFilter
from PySide.QtCore import QObject
from PySide import QtCore
from wadebug import WADebug
import dbus
import dbus.mainloop
import dbus.glib
import re

class SMSHandler(QObject):
    
    gotCode = QtCore.Signal(str)
    
    def __init__(self):
        WADebug.attach(self)
        super(SMSHandler, self).__init__()
        
    def initManager(self):
        self._d("INIT MANAGER!")        
        dbus_main_loop = dbus.glib.DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SessionBus(dbus_main_loop)
        commhistorybus = self.bus.get_object('com.nokia.CommHistory', '/CommHistoryModel')
        self.commhistorynface = dbus.Interface(commhistorybus, 'com.nokia.commhistory')
        self.commhistorynface.connect_to_signal("eventsAdded", self.messageStored)
        
        telepathybus = self.bus.get_object('org.freedesktop.Telepathy.ConnectionManager.ring', '/org/freedesktop/Telepathy/Connection/ring/tel/ring')
        self.requestsnface = dbus.Interface(telepathybus, 'org.freedesktop.Telepathy.Connection.Interface.Requests')
        self.requestsnface.connect_to_signal("NewChannels", self.pathReceived)
        
    def messageStored(self, arrayData):
        self._d("MESSAGE STORED!")
        try:
            arrayData[0].index("/org/freedesktop/Telepathy/Account/ring/tel/ring")
            message=arrayData[0][15]
            message.lower().index("whatsapp code")
            result=re.search('\d{3}-\d{3}', message)
            if result!=None:
                code=result.group(0).replace("-","")
                self._d("GOT CODE!")
                self._d(code)
                #self.gotCode.emit(code)
        except:
            return

    def pathReceived(self, arrayData):
        self._d("PATH RECEIVED!")
        self._d(arrayData[0][0])
        
        channelbus = self.bus.get_object('org.freedesktop.Telepathy.ConnectionManager.ring', arrayData[0][0])
        self.channelnface = dbus.Interface(channelbus, 'org.freedesktop.Telepathy.Channel.Interface.Messages')
        self.channelnface.connect_to_signal("MessageReceived", self.messageReceived)

    def messageReceived(self, arrayData):
        self._d("MESSAGE RECEIVED!")
        try:
            if arrayData[1].has_key('content'):
                message=arrayData[1]['content'].title()
                message.lower().index("whatsapp code")
                result=re.search('\d{3}-\d{3}', message)
                if result!=None:
                    code=result.group(0).replace("-","")
                    self._d("GOT CODE!")
                    self._d(code)
                    self.gotCode.emit(code)
        except:
            return

    def stopListener(self):
        pass
    
    def run(self):
        pass