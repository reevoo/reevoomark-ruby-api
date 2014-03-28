# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "reevoomark-ruby-api"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Reevoo Developers"]
  s.date = "2012-06-06"
  s.description = "Reevoo's ReevooMark & Traffic server-side ruby implementation. This API is free to use but requires you to be a Reevoo customer."
  s.homepage = "http://www.reevoo.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Implement ReevooMark on your ruby-based website."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 0"])
    else
      s.add_dependency(%q<httpclient>, [">= 0"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 0"])
  end
end
