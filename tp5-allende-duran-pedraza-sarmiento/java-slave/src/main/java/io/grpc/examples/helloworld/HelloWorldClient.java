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

import io.grpc.Channel;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.StatusRuntimeException;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.InetAddress;
//import io.grpc.examples.helloworld.GeneralServiceGrpc;

/**
 * A simple client that requests a greeting from the {@link HelloWorldServer}.
 */
public class HelloWorldClient {
  private static final Logger logger = Logger.getLogger(HelloWorldClient.class.getName());

  private final GeneralServiceGrpc.GeneralServiceBlockingStub blockingStub;

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

  public void service(){
    blockingStub.getFileInfo(new StreamObserver<>)
    @Override
    public void registerToMaster(RegistryInfo req, StreamObserver<Empty> responseObserver){}
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
    try {
      logger.info("El channel es..."+channel);
      HelloWorldClient client = new HelloWorldClient(channel);
      System.out.println("Me registro con el servidor");
      client.greet(ipAddress, name);
      System.out.println("Espero a que me pida un servicio");
      client.service();

    } finally {
      channel.shutdownNow().awaitTermination(5, TimeUnit.SECONDS);
    }
  }

  static class GeneralServiceImpl extends GeneralServiceGrpc.GeneralServiceImplBase {
    
 }


}
