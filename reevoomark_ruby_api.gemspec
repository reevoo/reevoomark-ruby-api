Gem::Specification.new do |s|
  s.name              = "reevoomark_ruby_api"
  s.version           = "0.0.1"
  s.summary           = "Implement ReevooMark on your ruby-based website."
  s.author            = "Reevoo Developers"
  s.date              = '2012-06-06'
  s.homepage          = "http://www.reevoo.com"

  s.has_rdoc          = false

  s.files             = Dir.glob("{lib,example,spec}/**/*")
  s.require_paths     = ["lib"]
  s.add_dependency 'httpclient'
end
