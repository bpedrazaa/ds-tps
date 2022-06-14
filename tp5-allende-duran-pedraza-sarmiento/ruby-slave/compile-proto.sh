#!/bin/bash

# Run this to compile the proto
grpc_tools_ruby_protoc -I ../protos --ruby_out=lib --grpc_out=lib ../protos/general.proto
echo ".proto file compiled"

# helloworld.proto compilation
grpc_tools_ruby_protoc -I . --ruby_out=lib --grpc_out=lib ./helloworld.proto
echo "helloworld.proto file compiled"

