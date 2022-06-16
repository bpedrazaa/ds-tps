# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: general.proto for package 'generalInfoPackage'

require 'grpc'
require 'general_pb'

module GeneralInfoPackage
  module GeneralService
    class Service

      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'generalInfoPackage.GeneralService'

      # from slave to master
      rpc :RegisterToMaster, ::GeneralInfoPackage::RegistryInfo, ::GeneralInfoPackage::Empty
      # from master to slave
      rpc :GetFileInfo, ::GeneralInfoPackage::Empty, ::GeneralInfoPackage::FileInfoList
      rpc :SearchFile, ::GeneralInfoPackage::FileName, ::GeneralInfoPackage::FileInfo
    end

    Stub = Service.rpc_stub_class
  end
end