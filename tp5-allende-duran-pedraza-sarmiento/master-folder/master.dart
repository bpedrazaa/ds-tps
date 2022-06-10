import 'package:grpc/grpc.dart';
// import 'package:helloworld/src/generated/helloworld.pbgrpc.dart';
import 'lib/src/generated/master-folder.pb.dart';
import 'package:lib/src/generated/master-folder.pbgrpc.dart';


/*
PARTE DE SERVIDOR DONDE ESPERA A QUE SE REGISTREN
 */

class generalService extends generalServiceBase {
  
  @override
  Future<Empty> registerToMaster(ServiceCall call, registerInfo request) async {
    return Empty;
  }


  @override
  Future<Book> createBook(ServiceCall call, Book request) async {
    var book = Book();
    book.title = request.title;
    book.id = request.id;
    books.books.add(book);
    return book;
  }

}

Future<void> main(List<String> args) async {
  final server = Server(
    [GreeterService()],
    const <Interceptor>[],
    CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
  );
  await server.serve(port: 50051);
  print('Server listening on port ${server.port}...');
}



/// Dart implementation of the gRPC helloworld.Greeter client.



Future<void> main(List<String> args) async {
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry:
          CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );
  final stub = GreeterClient(channel);

  final name = args.isNotEmpty ? args[0] : 'world';

  try {
    final response = await stub.sayHello(
      HelloRequest()..name = name,
      options: CallOptions(compression: const GzipCodec()),
    );
    print('Greeter client received: ${response.message}');
  } catch (e) {
    print('Caught error: $e');
  }
  await channel.shutdown();
}



// void main() {
//     print('hello, world');
// }





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