import 'package:grpc/grpc.dart';
// import 'package:helloworld/src/generated/helloworld.pbgrpc.dart';
import 'lib/src/generated/master-folder.pb.dart';
import 'package:lib/src/generated/master-folder.pbgrpc.dart';


//para la lista de registro slaves
import 'dart:convert';
/*
PARTE DE SERVIDOR DONDE ESPERA A QUE SE REGISTREN
 */

class GeneralService extends GeneralServiceBase {
  
  RegisterInfoList registerInfoList = RegisterInfoList()

  @override
  Future<Empty> registerToMaster(ServiceCall call, RegisterInfo request) async {
    // arrayRegistry.add(request)
    var register = RegisterInfo();
    register.ipAddress = request.ipAddress;
    register.name = request.name;
    registerInfoList.registerInfoList.add(register)
    return Empty();
  }

}

class GeneralServer {  
    Future<void> main(List<String> args) async {  
        final server = Server([GeneralService()]);  // Create a new server from the TodoService
        await server.serve(port: 9000); // Start the server on port 9000
        print('Server listening on port ${server.port}...');  
    }
} 


class Client {
  ClientChannel channel;
  GeneralClient stub;

  var listFileInfo = new List();
  var searchFileInfo = SearchFileInfo();
  
  Future<void> getFileInfoAll() async{
    channel = ClientChannel('localhost',
            port: 50051,
            options: // No credentials in this example
                const ChannelOptions(credentials: ChannelCredentials.insecure()));
    stub = GeneralClient(channel,
        options: CallOptions(timeout: Duration(seconds: 30)));
    try {
      var rootPath = "/"
      var fileInfoList = await stub.getFIleInfo(rootPath);
      print(fileInfoList)
      listFileInfo.add(fileInfoList);
    }catch (e) {
      print(e);
    }
    await channel.shutdown();

  }


  Future<void> searchFileAll(Filename fname) async{
    channel = ClientChannel('localhost',
            port: 50051,
            options: // No credentials in this example
                const ChannelOptions(credentials: ChannelCredentials.insecure()));
    stub = GeneralClient(channel,
        options: CallOptions(timeout: Duration(seconds: 30)));
    try {
      
      searchFileInfo = await stub.searchFile(fname);
      print(searchFileInfo)
      
    }catch (e) {
      print(e);
    }
    await channel.shutdown();
    searchFileInfo = null

  }

    
}

main() {  

  //servidor
  print('hello from main')
  GeneralServer generalServer = new GeneralServer();  
  generalServer.main([]);  

  //cliente
  var client = Client();
  
}








 

