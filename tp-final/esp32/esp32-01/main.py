from machine import Pin, SoftI2C
import ssd1306
from time import sleep
import json

global client_id, mqtt_server, topic_sub, portNumber, keepaliveValue

# Set up OLED
i2c = SoftI2C(scl=Pin(15), sda=Pin(4))
rst = Pin(16, Pin.OUT)
rst.value(1)

oled_width = 128
oled_height = 64
oled = ssd1306.SSD1306_I2C(oled_width, oled_height, i2c)

def sub_cb(topic, msg):
  global esp32_id
  oled.fill(0)
  oled.show()
  msg = msg.decode()
  print(msg)

  # Restrucutration of message
  newMsg = msg.split(',')
  idString = newMsg[0].split(':')
  ownerString = newMsg[1].split(':')

  # Show message in OLED
  oled.text(idString[0].replace(" ", "")+ ':', 0, 0)
  oled.text(idString[1].replace(" ", "") + ',', 0, 10)
  oled.text(ownerString[0].replace(" ", "") + ':', 0, 20)
  oled.text(ownerString[1].replace(" ", ""), 0, 30)
  oled.show();


def connect_and_subscribe():
  client = MQTTClient(client_id, mqtt_server, port=portNumber, keepalive=keepaliveValue)
  client.set_callback(sub_cb)
  client.connect()
  client.subscribe(topic_sub)
  print('Connected to %s MQTT broker, subscribed to %s topic' % (mqtt_server, topic_sub))
  return client


def restart_and_reconnect():
  print('Failed to connect to MQTT broker. Reconnecting...')
  time.sleep(10)
  machine.reset()

try:
  client = connect_and_subscribe()
except OSError as e:
  restart_and_reconnect()

while True:
  try:
    client.check_msg()
    if (time.time() - last_message) > message_interval:
      print('Tiempo de publicar...')
      newMsg = {"ID": client_id}
      msg = json.dumps(newMsg)
      client.publish(topic_pub,msg)
      last_message = time.time()
      counter += 1
  except OSError as e:
    restart_and_reconnect()
