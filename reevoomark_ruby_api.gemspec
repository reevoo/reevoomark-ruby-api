require File.expand_path("../lib/reevoomark/version", __FILE__)

Gem::Specification.new do |s|
  s.name              = "reevoomark-ruby-api"
  s.version           = ReevooMark::VERSION
  s.summary           = "Implement ReevooMark on your ruby-based website."
  s.description       = "Reevoo's ReevooMark & Traffic server-side ruby implementation. This API is free to use but requires you to be a Reevoo customer."
  s.author            = "Reevoo Developers"
  s.date              = '2012-06-06'
  s.homepage          = "http://www.reevoo.com"

  s.has_rdoc          = false

  s.files             = Dir.glob("{lib,example,spec}/**/*")
  s.require_paths     = ["lib"]
  s.add_dependency    'httpclient'
end
