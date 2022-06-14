#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'general_services_pb'
require 'socket'
include GeneralInfoPackage

# Client implementation
def run_get_file_info(stub)
  print "\n\nRunning method: run_get_file_info\n"
  resp = stub.get_file_info(Empty.new()).fileInfoList
  resp.each{ |fileInfo|
    print "Name: #{fileInfo.fileName}, Size: #{fileInfo.size}, SlaveId: #{fileInfo.SlaveId} \n"
  }
end

def run_search_file(stub, fileName)
  print "\n\nRunning method: run_search_file\n"
  print "Searching for #{fileName}\n"

  resp = stub.search_file(FileName.new(fileName: fileName))
  print "Name: #{resp.fileName}, Size: #{resp.size}, SlaveId: #{resp.SlaveId} \n"
end

# Act as a client and start the server
def main
  # Client Part
  stub =  GeneralService::Stub.new('localhost:50051', :this_channel_is_insecure)
  run_get_file_info(stub)
  run_search_file(stub, "Gemfile")
end
main
