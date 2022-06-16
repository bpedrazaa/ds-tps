const mqtt = require("mqtt");
const clientMqtt = mqtt.connect(
  "mqtt://" + process.env.HOST + ":" + process.env.PORT
);

const add = require("address");


var PROTO_PATH = __dirname + "../protos/general.proto";

var grpc = require("@grpc/grpc-js");
var protoLoader = require("@grpc/proto-loader");
var packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});
var generalInfoPackage =
  grpc.loadPackageDefinition(packageDefinition).generalInfoPackage;

var parseArgs = require("minimist");

var registroSlaves = [];

var armadoResultado = [];

/*SERVICE THAT OFFERS MASTER*/
function registerToMaster(call, callback) {
  var newRegistry = {
    ipAddress: call.request.ipAddress,
    name: call.request.name,
  };
  console.log("Se conecto un slave");
  console.log(newRegistry);
  registroSlaves.push(newRegistry);
  callback(null);
}

/*SERVICE THAT OFFER SLAVES
 */
function searchFileFromMaster(fileToSearch) {
  registroSlaves.forEach((element) => {
    const client = new generalInfoPackage.GeneralService(
      element.ipAddress + ":50052",
      grpc.credentials.createInsecure()
    );
    client.searchFile({ fileName: fileToSearch }, (err, response) => {
      if (err) {
        console.log(err);
      } else {
        console.log(`From server-slaves Search file -----`);
        console.log(JSON.stringify(response));
        armadoResultado.push(response);
      }
    });
  });
}
function getFilesInfo(fileName) {
  registroSlaves.forEach((element) => {
    const client = new generalInfoPackage.GeneralService(
      element.ipAddress + ":50052",
      grpc.credentials.createInsecure()
    );
    client.getFileInfo({ fileName: fileName }, (err, response) => {
      if (err) {
        console.log(err);
      } else {
        console.log(`From server-slaves get files `);
        console.log( JSON.stringify(response));
        response.forEach(element => {
          armadoResultado.push(element);
        });
        
      }
    });
  });
}
/*
MQTT
*/
function ConnectEvent() {
  clientMqtt.subscribe(process.env.TOPICSUB);
  
}

function MessageEvent(mytopic, message) {
  armadoResultado = [];
  console.log(mytopic + " - " + message.toString());
  if (message.toString() == "dir") {
    getFilesInfo();
    
    setTimeout(function() {
      clientMqtt.publish(process.env.TOPICPUB,"Get Files Result:\n"+ armadoResultado)
    }, 4000);
    
  } else {
    var text = message.toString();
    const myMessages = text.split(" ");
    var order = myMessages[0];
    var toFind = myMessages[1];
    console.log("Order:", order, " To Find:", toFind);
    
    //es find

    searchFileFromMaster(toFind);
    
    setTimeout(function() {
      clientMqtt.publish(process.env.TOPICPUB, "Search File Result:\n"+ armadoResultado)
    }, 4000);
  }
}

function main() {
  var server = new grpc.Server();
  server.addService(generalInfoPackage.GeneralService.service, {
    registerToMaster: registerToMaster,
  });

  server.bindAsync(
    add.ip() + ":50051",
    grpc.ServerCredentials.createInsecure(),
    () => {
      console.log("Escuchando la ip y puerto ", add.ip(), ":50051");
      server.start();
    }
  );
}

main();
clientMqtt.on("connect", ConnectEvent);
clientMqtt.on("message", MessageEvent);
