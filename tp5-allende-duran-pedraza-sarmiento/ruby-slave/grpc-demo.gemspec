# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'grpc-ruby-slave'
  s.version       = '1.0.0'
  s.authors       = ['Gabriela Allende', 'Stephany Duran', 'Boris Pedraza', 'Andrea Sarmiento']
  s.summary       = 'gRPC Ruby implementation'

  s.files         = `git ls-files -- ruby/*`.split("\n")
  s.executables   = `git ls-files -- ruby/greeter*.rb ruby/route_guide/*.rb`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ['lib']
  s.platform      = Gem::Platform::RUBY

  s.add_dependency 'grpc', '~> 1.0'
  s.add_development_dependency 'bundler', '>= 1.9'
end
