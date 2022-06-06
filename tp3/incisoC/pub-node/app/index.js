const mqtt = require('mqtt');
const fs = require('fs');

const host = process.env.BROKER;
const port = process.env.PORT
const topic = process.env.TOPIC

const connectUrl = `mqtt://${host}:${port}`

// Connection
const client = mqtt.connect(connectUrl);

// Publish
function sleep(ms){
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getData(){
  var data = fs.readFileSync('/etc/hosts', 'utf8');
  var lines = data.split("\n")
  var lastLine = lines[lines.length - 1] == '' ? lines[lines.length - 2] : lines[lines.length - 1]
  lastLine = lastLine.split("\t")
  return lastLine 
}

const data = getData()
var message = {
  time: new Date(),
  container: data[1],
  ip: data[0]
}

const iterateMessages = async(limit) => {
  client.publish(topic, JSON.stringify(message), (error) => {
    if(error){
      console.error(error)
    }
  })
  for(var i = 0; i < limit; i++){
    await sleep(5000).then(() => {
      message["time"] = new Date()
      client.publish(topic, JSON.stringify(message), (error) => {
        if(error){
          console.error(error)
        }
      })
   })
  }
}

client.on('connect', () => {
  console.log("Connected")
  iterateMessages(50)
})
