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

package com.tp.greeting;

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
import java.io.File;
import java.util.ArrayList;
import java.util.List;

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

  /** To registry with master */
  public void registry() {
    System.out.println("Act as a client and init registry with master");
    
    try{  
      InetAddress ipAddress=InetAddress.getLocalHost();

      String string = String.valueOf(ipAddress);
      String[] parts = string.split("/");
      String name = parts[0]; 
      String ip= parts[1];
      System.out.println("name: " + name);
      System.out.println("ipAddress: "+ ip);
      RegistryInfo mensaje = RegistryInfo.newBuilder().setIpAddress(ip).setName("Java-Slave").build();
      blockingStub.registerToMaster(mensaje);

    } catch (Exception e)
    {      
      logger.log(Level.WARNING, "RPC failed");
      System.out.println(e);
      return;
    }  
    
    logger.info("Registry end with master..");
  }

  //To start, run, stop and shutdown the service
  private void start() throws IOException {
    /* The port on which the server should run */
    int port = 50051;
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
    //logger.info("Conexion hecha a:" + System.getenv("SERVER"));
    //String target = "localhost:50051";
    String target = System.getenv("SERVER") + ":50051";
    logger.info("El target :" + target);
    
    ManagedChannel channel = ManagedChannelBuilder.forTarget(target)
        .usePlaintext()
        .build();
    logger.info("El channel es..."+channel);
    HelloWorldClient client = new HelloWorldClient(channel);
    try {
      System.out.println("Me registro con el servidor");
      client.registry();     
    } finally {
      System.out.println("finally");
      channel.shutdownNow().awaitTermination(5, TimeUnit.SECONDS);
    }

    System.out.println("Init like a service");
    client.start();
    client.blockUntilShutdown();

  }

  //Services of the client
  static class GeneralServiceImpl extends GeneralServiceGrpc.GeneralServiceImplBase {
       
    @Override
    public void searchFile(FileName req, StreamObserver<FileInfo> responseObserver){
      
     File root = new File(".");
     File[] list = root.listFiles();

     String name = "";
     int size = 0;
 
     if (list != null) {  // In case of access error, list is null
         for (File f : list) {
            if (f.getName() == req.toString()){
              System.out.println("name: "+ f.getName());
              System.out.println("size: "+ f.length());
              name = f.getName();
              size = (int) f.length();
            }
         }
     }
     FileInfo response = FileInfo.newBuilder().setFileName(name).setSize(size).setSlaveId("Java-Slave").build();
     responseObserver.onNext(response);
     responseObserver.onCompleted();


    }

    @Override
    public void getFileInfo(Empty req, StreamObserver<FileInfoList> responseObserver){

     File root = new File(".");
     File[] list = root.listFiles();
 
     if (list != null) {  // In case of access error, list is null
         for (File f : list) {
             System.out.println("name: "+ f.getName());
             System.out.println("size: "+ f.length());
             FileInfoList response = FileInfoList.newBuilder().addFileInfoList(FileInfo.newBuilder().setFileName(f.getName()).setSize((int) f.length()).setSlaveId("Java-Slave").build()).build();
             responseObserver.onNext(response);
         }
     }else{
        FileInfoList resp = FileInfoList.newBuilder().build();
        responseObserver.onNext(resp);
     }
      responseObserver.onCompleted();
    }
  }


}
