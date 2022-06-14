#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'general_services_pb'
require 'socket'
include GeneralInfoPackage

def getIpAddress()
  ip = Socket.ip_address_list.find {
    |a| a.ipv4_private? && !a.ipv4_loopback?
  }.ip_address
  return ip
end

def getSlaveId()
  lastLine = IO.readlines("/etc/hosts")[-1..-1][0].split(' ')
  slaveId = lastLine.last
  return slaveId
end
# Client implementation
def run_register_to_master(stub)
  print 'Registering to the server'
  print'----------'

  registryInfo = RegistryInfo.new(
    ipAddress: getIpAddress,
    name: "Ruby-Slave"
  )
  stub.register_to_master(registryInfo)
end

# ServerImpl of the General Service.
class ServerImpl < GeneralService::Service

  def get_file_info(empty, _unused_call)
    files = []
    Dir.each_child(".") {
      |x|
      file = FileInfo.new(
        fileName: x,
        size: File.size?(x),
        SlaveId: getSlaveId
      )
      files << file
    }
    finalFiles = FileInfoList.new(
      fileInfoList: files
    )
    #print finalFiles, "\n\n\n"
    return finalFiles
  end

  def search_file(fileName, _unused_call)
    file = ""
    Dir.each_child(".") {
      |x|
      if x == fileName.fileName
        file = FileInfo.new(
          fileName: x,
          size: File.size?(x),
          SlaveId: getSlaveId
        )
      end
    }
    return file
    #print file, "\n\n\n"
  end
end

# Act as a client and start the server
def main
  masterAddress = ENV["SERVER"]
  # Client Part
  stub = GeneralService::Stub.new("#{masterAddress}:50051", :this_channel_is_insecure)
  run_register_to_master(stub)

  ## Server Part
  port = "#{getIpAddress}:50052"
  s = GRPC::RpcServer.new
  s.add_http2_port(port, :this_port_is_insecure)
  GRPC.logger.info("... running insecurely on #{port}")
  s.handle(ServerImpl)
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end
main
