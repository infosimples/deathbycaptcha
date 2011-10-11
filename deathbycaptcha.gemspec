# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deathbycaptcha/version"

Gem::Specification.new do |s|
  s.add_dependency 'rest-client', '~> 1.6.1'
  s.add_dependency 'json', '~> 1.4.6'
  
  s.name        = "deathbycaptcha"
  s.version     = DeathByCaptcha::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rafael Barbolo Lopes, Rafael Ivan Garcia"]
  s.email       = ["tech@infosimples.com.br"]
  s.homepage    = "http://www.infosimples.com.br/en/open-source/captcha-solving-api/"
  s.summary     = %q{Ruby API for DeathByCaptcha (Captcha Solver as a Service)}
  s.description = %q{Ruby API for DeathByCaptcha (Captcha Solver as a Service)}

  s.rubyforge_project = "deathbycaptcha"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end