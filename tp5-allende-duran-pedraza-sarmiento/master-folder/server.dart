

// import 'package:grpc/grpc.dart';
import 'package:master-folder/generated/master-folder.pbgrpc.dart';

/**
* gRPC Server
**/
class TodoServer {  
    Future<void> main(List<String> args) async {  
        final server = Server([TodoService()]);  // Create a new server from the TodoService
        await server.serve(port: 9000); // Start the server on port 9000
        print('Server listening on port ${server.port}...');  
 }} 


 

main() {  
  TodoServer todoServer = new TodoServer();  
  todoServer.main([]);  
}