
dart pub global activate protoc_plugin

export PATH="$PATH:$HOME/.pub-cache/bin"

mkdir lib
mkdir lib/src
mkdir lib/src/generated

# protoc -I protos/ protos/todo.proto --dart_out=grpc:lib/src/generated

protoc --dart_out=grpc:lib/src/generated -Iprotos ../protos/general.proto

dart pub get

dart master.dart