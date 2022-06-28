import time
from umqttsimple import MQTTClient
from variables import varSsid, varPassword, varKeepAliveValue, varPortNumber, varowner
import ubinascii
import machine
import micropython
import network
import esp
esp.osdebug(None)
import gc
gc.collect()

ssid = varSsid
password = varPassword
mqtt_server = 'research.upb.edu'
portNumber = varPortNumber
keepaliveValue = varKeepAliveValue
client_id = ubinascii.hexlify(machine.unique_id())
topic_sub = b'results'
topic_pub = b'verify'
topic_pub_r = b'register'
owner = varowner

station = network.WLAN(network.STA_IF)

station.active(True)
station.connect(ssid, password)

while station.isconnected() == False:
  pass

print('Connection successful, connected to %s' % ssid)
print(station.ifconfig())
