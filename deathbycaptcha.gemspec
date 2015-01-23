# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deathbycaptcha/version'

Gem::Specification.new do |spec|
  spec.name          = "deathbycaptcha"
  spec.version       = Deathbycaptcha::VERSION
  spec.authors       = ["Débora Setton Fernandes, Rafael Barbolo, Rafael Ivan Garcia"]
  spec.email         = ["team@infosimples.com.br"]
  spec.summary       = %q{Ruby API for DeathByCaptcha (Captcha Solver as a Service)}
  spec.description   = %q{DeathByCaptcha allows you to solve captchas with manual labor}
  spec.homepage      = "https://github.com/infosimples/deathbycaptcha"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
