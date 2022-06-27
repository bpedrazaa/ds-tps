const mqtt = require('mqtt');

const host = process.env.BROKER;
const port = process.env.PORT
const topic = process.env.TOPIC


const connectUrl = `mqtt://${host}:${port}`

const client = mqtt.connect(connectUrl);

function EventoConectar() {
	console.log('Connected')
	client.subscribe(topic, () => {
			console.log('Suscribe to topic: ',topic)
	})
}	
function EventoMensaje(topic,message){
	console.log(message.toString())
}

client.on('connect',EventoConectar)
client.on('message', EventoMensaje)
