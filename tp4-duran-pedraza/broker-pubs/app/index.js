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

function getIP(){
  var data = fs.readFileSync('/etc/hosts', 'utf8');
  var lines = data.split("\n")
  var lastLine = lines[lines.length - 1] == '' ? lines[lines.length - 2] : lines[lines.length - 1]
  lastLine = lastLine.split("\t")
  return lastLine[0] 
}
function random(type){
  var num = Math.floor(Math.random() * (3 - 1)) + 1;
  var respuesta
  if(num === 1)
  { 
    if(type === "control"){
      respuesta = "ON"
    }else{
      respuesta = "TRUE"
    }
  }else{
   
    if(type === "control"){
      respuesta = "OFF"
    }else{
      respuesta = "FALSE"
    }
  }
  return respuesta
}




const iterateMessages = async(limit) => {
  for(var i = 0; i < limit; i++){
    await sleep(5000).then(() => {
      var message = {
        control: random("control"),
        forward: random("forward"),
        ip: getIP()
      }
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
  iterateMessages(200)
})
