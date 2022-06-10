

const mqtt = require('mqtt')
const client  = mqtt.connect('mqtt://'+process.env.HOST+':'+process.env.PORT)
 
var PROTO_PATH = __dirname + '../protos/general.proto';

var grpc = require('@grpc/grpc-js');
var protoLoader = require('@grpc/proto-loader');
var packageDefinition = protoLoader.loadSync(
    PROTO_PATH,
    {keepCase: true,
     longs: String,
     enums: String,
     defaults: true,
     oneofs: true
    });
var generalInfoPackage = grpc.loadPackageDefinition(packageDefinition).generalInfoPackage;



var parseArgs = require('minimist');

var registroSlaves = []

/*SERVICE THAT OFFERS MASTER*/ 
function registerToMaster(call, callback) {
    
    var newRegistry = {ipAddress: call.request.ipAddress , name: call.request.name}
    registroSlaves.push(newRegistry)
    callback(null);
}

/*SERVICE THAT OFFERS SLAVES
 */
function searchFileFromMaster(fileToSearch) {

    registroSlaves.forEach(element => {
        const client = new generalInfoPackage.GeneralService(element.ipAddress+':50051', grpc.credentials.createInsecure());
        client.searchFile({ 'fileName': fileToSearch , 'book': 'Cracking the Interview' }, (err, response) => {
          if (err) {
              console.log(err);
          } else {
              console.log(`From server-slaves`, JSON.stringify(response));
          }
      });
    });

    
}
function getFilesInfo(){
  registroSlaves.forEach(element => {
    const client = new generalInfoPackage.GeneralService(element.ipAddress+':50051', grpc.credentials.createInsecure());
      client.getFileInfo({ 'fileName': "bok.txt", 'book': 'Cracking the Interview' }, (err, response) => {
        if (err) {
          console.log(err);
        } else {
          console.log(`From server-slaves`, JSON.stringify(response));
        }

      });
  });
    
}
/*
MQTT
*/ 
function ConnectEvent() {
  client.subscribe(process.env.TOPICSUB)
  // client.publish(process.env.TOPICPUB, jsonFile)
  
}

function MessageEvent(mytopic, message) {
  console.log(mytopic + " - " + message.toString())
  if (message.toString() == "dir"){
    this.getFilesInfo();
  } 
  else {
    //es find
    this.searchFileFromMaster()
  }
}

function main() {
  var server = new grpc.Server();
  server.addService(generalInfoPackage.GeneralService.service, {registerToMaster: registerToMaster});
  
  server.bindAsync('0.0.0.0:50051', grpc.ServerCredentials.createInsecure(), () => {
    server.start();
  });


}


main();
client.on('connect', ConnectEvent)
client.on('message', MessageEvent)



