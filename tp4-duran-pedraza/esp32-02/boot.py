import time
from umqttsimple import MQTTClient
import ubinascii
import machine
import micropython
import network
import esp
esp.osdebug(None)
import gc
gc.collect()

ssid = 'CONECTATE SALA'
password = 'FLIADURAN'
mqtt_server = 'research.upb.edu'
portNumber = 21192
keepaliveValue = 60
client_id = ubinascii.hexlify(machine.unique_id())
topic_sub = b'forward'

station = network.WLAN(network.STA_IF)

station.active(True)
station.connect(ssid, password)

while station.isconnected() == False:
  pass

print('Connection successful, connected to %s' % ssid)
print(station.ifconfig())
