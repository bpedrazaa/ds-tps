/*
 * Copyright 2015 The gRPC Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.grpc.examples.helloworld;

//import generalInfoPackage.GeneralServiceGrpc;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.Channel;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.StatusRuntimeException;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.InetAddress;
import java.io.IOException;
import io.grpc.stub.StreamObserver;
//import io.grpc.examples.helloworld.GeneralServiceGrpc;

/**
 * A simple client that requests a greeting from the {@link HelloWorldServer}.
 */
public class HelloWorldClient {
  private static final Logger logger = Logger.getLogger(HelloWorldClient.class.getName());

  private final GeneralServiceGrpc.GeneralServiceBlockingStub blockingStub;
  private Server server;

  /** Construct client for accessing HelloWorld server using the existing channel. */
  public HelloWorldClient(Channel channel) {
    blockingStub = GeneralServiceGrpc.newBlockingStub(channel);
  }

  /** Say hello to server. */
  public void greet(String ip, String name) {
    logger.info("Will try to greet ========== " + " .......");

   RegistryInfo mensaje = RegistryInfo.newBuilder().setIpAddress(ip).setName(name).build();
    
    try {
      blockingStub.registerToMaster(mensaje);
    } catch (StatusRuntimeException e) {
      logger.log(Level.WARNING, "RPC failed: {0}", e.getStatus());
      return;
    }
    logger.info("Registry enviado al master..");
  }

  private void start() throws IOException {
    /* The port on which the server should run */
    int port = 50052;
    server = ServerBuilder.forPort(port)
        .addService(new GeneralServiceImpl())
        .build()
        .start();
    logger.info("Server started, listening on " + port);
    Runtime.getRuntime().addShutdownHook(new Thread() {
      @Override
      public void run() {
        // Use stderr here since the logger may have been reset by its JVM shutdown hook.
        System.err.println("*** shutting down gRPC server since JVM is shutting down");
        try {
          HelloWorldClient.this.stop();
        } catch (InterruptedException e) {
          e.printStackTrace(System.err);
        }
        System.err.println("*** server shut down");
      }
    });
  }

  private void stop() throws InterruptedException {
    if (server != null) {
      server.shutdown().awaitTermination(30, TimeUnit.SECONDS);
    }
  }

  /**
   * Await termination on the main thread since the grpc library uses daemon threads.
   */
  private void blockUntilShutdown() throws InterruptedException {
    if (server != null) {
      server.awaitTermination();
    }
  }


  public static void main(String[] args) throws Exception {
    String user = "Tefy-Slave-Java";
    // Access a service running on the local machine on port 50051
    //logger.info("Variable de entorno broker:" + System.getenv("SERVER"));
    //logger.log("Variable de entorno puerto: {0}", System.getenv("PORT"));
    //logger.info("Conexion hecha a:" + System.getenv("SERVER"));
    String target = "localhost:50051";
    //String target = System.getenv("SERVER") + ":50051";
    logger.info("hola");
    System.out.println(InetAddress.getLocalHost());
    String string = String.valueOf(InetAddress.getLocalHost());
    String[] parts = string.split("/");
    String name = parts[0]; 
    String ipAddress= parts[1];
    logger.info("name: " + name);
    logger.info("ipAddress: "+ ipAddress);
    logger.info("El target :" + target);
    
    ManagedChannel channel = ManagedChannelBuilder.forTarget(target)
        .usePlaintext()
        .build();
    logger.info("El channel es..."+channel);
    HelloWorldClient client = new HelloWorldClient(channel);
    try {
    //logger.info("El channel es..."+channel);
    //HelloWorldClient client = new HelloWorldClient(channel);
      System.out.println("Me registro con el servidor");
      client.greet(ipAddress, name);
      //System.out.println("Espero a que me pida un servicio");
      //client.service();
      //System.out.println("Encontra al sistem");
     // channel.shutdownNow();
     

    } finally {
      System.out.println("finally");
      channel.shutdownNow().awaitTermination(5, TimeUnit.SECONDS);
    }
    System.out.println("Inicio del servicio");
    client.start();
    client.blockUntilShutdown();

    




  }

  static class GeneralServiceImpl extends GeneralServiceGrpc.GeneralServiceImplBase {
       
    @Override
    public void searchFile(FileName req, StreamObserver<FileInfo> responseObserver){
     FileInfo response = FileInfo.newBuilder().setFileName("hola").setSize(23).setFileId("hola2").build();
      
      responseObserver.onNext(response);
      responseObserver.onCompleted();
    }
    
    

  }


}
